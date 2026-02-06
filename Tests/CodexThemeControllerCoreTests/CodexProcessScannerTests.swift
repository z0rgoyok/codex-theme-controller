import Foundation
import Testing
@testable import CodexThemeControllerCore

struct CodexProcessScannerTests {
    @Test
    func extractsPortFromCommand() {
        let command = "/Applications/Codex.app/Contents/MacOS/Codex --remote-debugging-port=9333"
        #expect(CodexProcessScanner.extractRemoteDebuggingPort(from: command) == 9333)
    }

    @Test
    func parsesPSOutputAndFiltersOnlyCodex() {
        let input = """
          100 /usr/bin/some-other-process
          101 /Applications/Codex.app/Contents/MacOS/Codex --remote-debugging-port=9222
          102 /Applications/Codex.app/Contents/MacOS/Codex
        """

        let result = CodexProcessScanner.parsePSOutput(
            input,
            codexBinaryPath: "/Applications/Codex.app/Contents/MacOS/Codex"
        )

        #expect(result.count == 2)
        #expect(result[0].pid == 101)
        #expect(result[0].remoteDebuggingPort == 9222)
        #expect(result[1].pid == 102)
        #expect(result[1].remoteDebuggingPort == nil)
    }

    @Test
    func darculaExpressionsContainStyleIdentifier() {
        #expect(DarculaTheme.injectExpression.contains(DarculaTheme.styleElementID))
        #expect(DarculaTheme.removeExpression.contains(DarculaTheme.styleElementID))
    }

    @Test
    func allThemesContainStyleIdentifierAndCSS() {
        for theme in CodexTheme.allCases {
            #expect(!theme.css.isEmpty)
            #expect(theme.injectExpression.contains(CodexTheme.styleElementID))
        }
        #expect(CodexTheme.removeExpression.contains(CodexTheme.styleElementID))
    }

    @Test
    func cdpTargetsDecodeWebSocketDebuggerUrl() throws {
        let json = """
        [
          {
            "id": "target-1",
            "title": "Codex",
            "type": "page",
            "webSocketDebuggerUrl": "ws://127.0.0.1:9333/devtools/page/target-1"
          }
        ]
        """

        let data = try #require(json.data(using: .utf8))
        let targets = try JSONDecoder().decode([CDPThemeInjector.Target].self, from: data)
        #expect(targets.count == 1)
        #expect(targets[0].webSocketDebuggerURL == "ws://127.0.0.1:9333/devtools/page/target-1")
    }
}
