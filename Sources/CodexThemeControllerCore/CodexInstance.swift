import Foundation

public struct CodexInstance: Identifiable, Equatable, Sendable {
    public let pid: Int
    public let command: String
    public let remoteDebuggingPort: Int?

    public init(pid: Int, command: String, remoteDebuggingPort: Int?) {
        self.pid = pid
        self.command = command
        self.remoteDebuggingPort = remoteDebuggingPort
    }

    public var id: Int { pid }
    public var isInjectable: Bool { remoteDebuggingPort != nil }
}
