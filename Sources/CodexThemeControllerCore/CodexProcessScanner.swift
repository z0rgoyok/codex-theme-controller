import Foundation

public struct CodexProcessScanner: Sendable {
    public enum ScanError: Error {
        case psFailed(String)
        case outputDecodingFailed
    }

    public let codexBinaryPath: String

    public init(codexBinaryPath: String = "/Applications/Codex.app/Contents/MacOS/Codex") {
        self.codexBinaryPath = codexBinaryPath
    }

    public func scanRunningInstances() throws -> [CodexInstance] {
        // Read from pipe before waiting to avoid deadlock on full stdout/stderr buffers.
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-axo", "pid=,command="]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        try process.run()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let stderr = String(data: outputData, encoding: .utf8) ?? "Unknown error"
            throw ScanError.psFailed(stderr)
        }

        guard let output = String(data: outputData, encoding: .utf8) else {
            throw ScanError.outputDecodingFailed
        }

        return Self.parsePSOutput(output, codexBinaryPath: codexBinaryPath)
    }

    public static func parsePSOutput(_ output: String, codexBinaryPath: String) -> [CodexInstance] {
        output
            .split(separator: "\n")
            .compactMap { parsePSLine(String($0), codexBinaryPath: codexBinaryPath) }
            .sorted { $0.pid < $1.pid }
    }

    public static func parsePSLine(_ line: String, codexBinaryPath: String) -> CodexInstance? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(maxSplits: 1, whereSeparator: { $0.isWhitespace })
        guard parts.count == 2, let pid = Int(parts[0]) else { return nil }

        let command = String(parts[1]).trimmingCharacters(in: .whitespaces)
        guard command.contains(codexBinaryPath) else { return nil }

        let port = extractRemoteDebuggingPort(from: command)
        return CodexInstance(pid: pid, command: command, remoteDebuggingPort: port)
    }

    public static func extractRemoteDebuggingPort(from command: String) -> Int? {
        let marker = "--remote-debugging-port="
        guard let markerRange = command.range(of: marker) else { return nil }

        let suffix = command[markerRange.upperBound...]
        let digits = suffix.prefix { $0.isNumber }
        return Int(digits)
    }
}
