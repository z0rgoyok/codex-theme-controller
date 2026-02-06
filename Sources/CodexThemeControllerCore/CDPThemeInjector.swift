import Foundation

public struct InjectionResult: Equatable, Sendable {
    public let targetID: String
    public let targetTitle: String
    public let action: String

    public init(targetID: String, targetTitle: String, action: String) {
        self.targetID = targetID
        self.targetTitle = targetTitle
        self.action = action
    }
}

public enum CDPThemeInjectorError: Error, LocalizedError {
    case badEndpoint
    case requestFailed(String)
    case noPageTargets
    case websocketError(String)
    case malformedResponse

    public var errorDescription: String? {
        switch self {
        case .badEndpoint:
            return "Invalid CDP endpoint URL."
        case .requestFailed(let reason):
            return "CDP request failed: \(reason)"
        case .noPageTargets:
            return "No active page targets found for this Codex instance."
        case .websocketError(let reason):
            return "CDP websocket failed: \(reason)"
        case .malformedResponse:
            return "Malformed response from CDP target."
        }
    }
}

public actor CDPThemeInjector {
    struct Target: Decodable, Sendable {
        let id: String
        let title: String
        let type: String
        let webSocketDebuggerURL: String?

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case type
            case webSocketDebuggerUrl
            case webSocketDebuggerURL
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
            self.type = try container.decode(String.self, forKey: .type)
            self.webSocketDebuggerURL =
                try container.decodeIfPresent(String.self, forKey: .webSocketDebuggerUrl)
                ?? container.decodeIfPresent(String.self, forKey: .webSocketDebuggerURL)
        }
    }

    private let session: URLSession
    private let maxTargetWaitAttempts: Int
    private let targetWaitDelayNanos: UInt64

    public init(
        session: URLSession = .shared,
        maxTargetWaitAttempts: Int = 12,
        targetWaitDelayNanos: UInt64 = 250_000_000
    ) {
        self.session = session
        self.maxTargetWaitAttempts = max(1, maxTargetWaitAttempts)
        self.targetWaitDelayNanos = targetWaitDelayNanos
    }

    public func applyTheme(port: Int, theme: CodexTheme) async throws -> [InjectionResult] {
        try await run(port: port, expression: theme.injectExpression, action: "injected")
    }

    public func applyDarcula(port: Int) async throws -> [InjectionResult] {
        try await applyTheme(port: port, theme: .darcula)
    }

    public func removeTheme(port: Int) async throws -> [InjectionResult] {
        try await run(port: port, expression: CodexTheme.removeExpression, action: "removed")
    }

    public func removeDarcula(port: Int) async throws -> [InjectionResult] {
        try await removeTheme(port: port)
    }

    private func run(port: Int, expression: String, action: String) async throws -> [InjectionResult] {
        let targets = try await fetchInjectableTargets(port: port)

        guard !targets.isEmpty else {
            throw CDPThemeInjectorError.noPageTargets
        }

        var results: [InjectionResult] = []
        for target in targets {
            guard let wsURLString = target.webSocketDebuggerURL,
                  let wsURL = URL(string: wsURLString)
            else {
                continue
            }

            _ = try await evaluate(on: wsURL, expression: expression)
            results.append(InjectionResult(targetID: target.id, targetTitle: target.title, action: action))
        }

        if results.isEmpty {
            throw CDPThemeInjectorError.noPageTargets
        }

        return results
    }

    private func fetchInjectableTargets(port: Int) async throws -> [Target] {
        var lastError: Error?
        for attempt in 1...maxTargetWaitAttempts {
            do {
                let targets = try await fetchTargets(port: port)
                    .filter { $0.type == "page" && $0.webSocketDebuggerURL != nil }

                if !targets.isEmpty {
                    return targets
                }
            } catch {
                lastError = error
            }

            if attempt < maxTargetWaitAttempts {
                try? await Task.sleep(nanoseconds: targetWaitDelayNanos)
            }
        }

        if let lastError {
            throw lastError
        }

        return []
    }

    private func fetchTargets(port: Int) async throws -> [Target] {
        guard let url = URL(string: "http://127.0.0.1:\(port)/json/list") else {
            throw CDPThemeInjectorError.badEndpoint
        }

        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw CDPThemeInjectorError.requestFailed("HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            }
            return try JSONDecoder().decode([Target].self, from: data)
        } catch {
            throw CDPThemeInjectorError.requestFailed(error.localizedDescription)
        }
    }

    private func evaluate(on wsURL: URL, expression: String) async throws -> String {
        let socket = session.webSocketTask(with: wsURL)
        socket.resume()
        defer {
            socket.cancel(with: .goingAway, reason: nil)
        }

        _ = try await send(method: "Runtime.enable", params: [:], id: 1, socket: socket)
        let response = try await send(
            method: "Runtime.evaluate",
            params: [
                "expression": expression,
                "returnByValue": true
            ],
            id: 2,
            socket: socket
        )

        if let result = (response["result"] as? [String: Any])?["result"] as? [String: Any] {
            if let value = result["value"] as? String {
                return value
            }
            if let description = result["description"] as? String {
                return description
            }
        }

        return "ok"
    }

    private func send(
        method: String,
        params: [String: Any],
        id: Int,
        socket: URLSessionWebSocketTask
    ) async throws -> [String: Any] {
        let payload: [String: Any] = [
            "id": id,
            "method": method,
            "params": params
        ]

        let data = try JSONSerialization.data(withJSONObject: payload)
        guard let text = String(data: data, encoding: .utf8) else {
            throw CDPThemeInjectorError.malformedResponse
        }

        do {
            try await socket.send(.string(text))

            while true {
                let message = try await socket.receive()
                switch message {
                case .string(let raw):
                    guard let rawData = raw.data(using: .utf8),
                          let json = try JSONSerialization.jsonObject(with: rawData) as? [String: Any]
                    else {
                        continue
                    }

                    if let responseID = json["id"] as? Int, responseID == id {
                        if let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            throw CDPThemeInjectorError.websocketError(message)
                        }
                        return json
                    }
                case .data(let rawData):
                    guard let json = try JSONSerialization.jsonObject(with: rawData) as? [String: Any] else {
                        continue
                    }
                    if let responseID = json["id"] as? Int, responseID == id {
                        if let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            throw CDPThemeInjectorError.websocketError(message)
                        }
                        return json
                    }
                @unknown default:
                    continue
                }
            }
        } catch {
            if let cdpError = error as? CDPThemeInjectorError {
                throw cdpError
            }
            throw CDPThemeInjectorError.websocketError(error.localizedDescription)
        }
    }
}
