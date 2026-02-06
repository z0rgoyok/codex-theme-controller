import Foundation
import CodexThemeControllerCore

@MainActor
final class AppViewModel: ObservableObject {
    enum ViewModelError: Error, LocalizedError {
        case launchFailed(String)

        var errorDescription: String? {
            switch self {
            case .launchFailed(let reason):
                return "Launch failed: \(reason)"
            }
        }
    }

    @Published private(set) var instances: [CodexInstance] = []
    @Published var statusMessage: String = ""
    @Published var busyPIDs: Set<Int> = []
    @Published var launchPortText: String = "9222"
    @Published var selectedTheme: CodexTheme
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var isLaunching: Bool = false

    private static let selectedThemeKey = "codex-theme-controller.selected-theme"

    private let scanner: CodexProcessScanner
    private let injector: CDPThemeInjector
    private let defaults: UserDefaults
    private var refreshTask: Task<Void, Never>?

    init(
        scanner: CodexProcessScanner = CodexProcessScanner(),
        injector: CDPThemeInjector = CDPThemeInjector(),
        defaults: UserDefaults = .standard
    ) {
        self.scanner = scanner
        self.injector = injector
        self.defaults = defaults

        if let saved = defaults.string(forKey: Self.selectedThemeKey),
           let restored = CodexTheme(rawValue: saved) {
            self.selectedTheme = restored
        } else {
            self.selectedTheme = .darcula
        }
    }

    var availableThemes: [CodexTheme] {
        CodexTheme.allCases
    }

    var injectableCount: Int {
        instances.filter(\.isInjectable).count
    }

    var isWorking: Bool {
        isScanning || isLaunching || !busyPIDs.isEmpty
    }

    func refresh() {
        refreshTask?.cancel()
        isScanning = true

        refreshTask = Task { [weak self] in
            guard let self else { return }
            defer { self.isScanning = false }
            do {
                let scanned = try await scanRunningInstances()
                guard !Task.isCancelled else { return }
                self.instances = scanned
                self.statusMessage = "Found \(scanned.count) Codex instance(s)."
            } catch {
                guard !Task.isCancelled else { return }
                self.statusMessage = "Scan failed: \(error.localizedDescription)"
            }
        }
    }

    func selectTheme(_ theme: CodexTheme) {
        guard selectedTheme != theme else { return }
        selectedTheme = theme
        defaults.set(theme.rawValue, forKey: Self.selectedThemeKey)
        statusMessage = "Selected \(theme.displayName). Applying to running Codex..."
        applyThemeToAll(theme)
    }

    func applySelectedTheme(_ instance: CodexInstance) {
        applyTheme(selectedTheme, to: instance)
    }

    func removeTheme(_ instance: CodexInstance) {
        guard let port = instance.remoteDebuggingPort else {
            statusMessage = "PID \(instance.pid): no --remote-debugging-port."
            return
        }

        Task {
            busyPIDs.insert(instance.pid)
            defer { busyPIDs.remove(instance.pid) }

            do {
                let results = try await injector.removeTheme(port: port)
                statusMessage = "PID \(instance.pid): removed from \(results.count) page target(s)."
            } catch {
                statusMessage = "PID \(instance.pid): \(error.localizedDescription)"
            }
        }
    }

    func applySelectedThemeToAll() {
        applyThemeToAll(selectedTheme)
    }

    func launchCodexWithPort() {
        guard let port = Int(launchPortText), port > 0 else {
            statusMessage = "Invalid debug port."
            return
        }

        let theme = selectedTheme
        statusMessage = "Launching Codex on port \(port)..."
        isLaunching = true

        Task {
            defer { isLaunching = false }
            do {
                try await Self.runOpenCommand(port: port)
                statusMessage = "Launched Codex on \(port). Applying \(theme.displayName)..."

                let results = try await injector.applyTheme(port: port, theme: theme)
                statusMessage = "Launched and applied \(theme.displayName) to \(results.count) page target(s) on \(port)."
                refresh()
            } catch {
                statusMessage = error.localizedDescription
                refresh()
            }
        }
    }

    private func applyTheme(_ theme: CodexTheme, to instance: CodexInstance) {
        guard let port = instance.remoteDebuggingPort else {
            statusMessage = "PID \(instance.pid): no --remote-debugging-port."
            return
        }

        Task {
            busyPIDs.insert(instance.pid)
            defer { busyPIDs.remove(instance.pid) }

            do {
                let results = try await injector.applyTheme(port: port, theme: theme)
                statusMessage = "PID \(instance.pid): \(theme.displayName) applied in \(results.count) page target(s)."
            } catch {
                statusMessage = "PID \(instance.pid): \(error.localizedDescription)"
            }
        }
    }

    private func applyThemeToAll(_ theme: CodexTheme) {
        Task {
            do {
                let scanned = try await scanRunningInstances()
                instances = scanned

                let injectable = scanned.filter { $0.remoteDebuggingPort != nil }
                guard !injectable.isEmpty else {
                    statusMessage = "No injectable instances (missing --remote-debugging-port)."
                    return
                }

                let pids = Set(injectable.map(\.pid))
                busyPIDs.formUnion(pids)
                defer { busyPIDs.subtract(pids) }

                var appliedCount = 0
                var failedCount = 0
                var firstError: String?

                for instance in injectable {
                    guard let port = instance.remoteDebuggingPort else { continue }
                    do {
                        _ = try await injector.applyTheme(port: port, theme: theme)
                        appliedCount += 1
                    } catch {
                        failedCount += 1
                        if firstError == nil {
                            firstError = "PID \(instance.pid): \(error.localizedDescription)"
                        }
                    }
                }

                if failedCount == 0 {
                    statusMessage = "Applied \(theme.displayName) to \(appliedCount) instance(s)."
                } else {
                    statusMessage = "Applied \(theme.displayName) to \(appliedCount)/\(injectable.count). First error: \(firstError ?? "unknown")."
                }
            } catch {
                statusMessage = "Apply failed: \(error.localizedDescription)"
            }
        }
    }

    private func scanRunningInstances() async throws -> [CodexInstance] {
        let scanner = self.scanner
        return try await Task.detached(priority: .userInitiated) {
            try scanner.scanRunningInstances()
        }.value
    }

    private static func runOpenCommand(port: Int) async throws {
        try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = [
                "-na",
                "/Applications/Codex.app",
                "--args",
                "--remote-debugging-port=\(port)"
            ]

            let errorPipe = Pipe()
            process.standardError = errorPipe

            try process.run()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let message = String(data: errorData, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                throw ViewModelError.launchFailed(message?.isEmpty == false ? message! : "open exited with code \(process.terminationStatus)")
            }
        }.value
    }
}
