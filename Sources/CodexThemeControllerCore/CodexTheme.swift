import Foundation

public enum CodexTheme: String, CaseIterable, Codable, Sendable, Identifiable {
    case darcula
    case dracula
    case nord
    case monokai

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .darcula:
            return "Darcula"
        case .dracula:
            return "Dracula"
        case .nord:
            return "Nord"
        case .monokai:
            return "Monokai"
        }
    }

    public static let styleElementID = "codex-theme-controller-style"

    public var css: String {
        switch self {
        case .darcula:
            return """
            :root, html, body, #root {
              color-scheme: dark !important;
              background: #2b2b2b !important;
              color: #a9b7c6 !important;
            }
            * { border-color: #4e5254 !important; }
            main, section, article, aside, header, footer, nav, div[data-panel], [data-theme="dark"] {
              background-color: #2b2b2b !important;
              color: #a9b7c6 !important;
            }
            aside, nav, [data-sidebar], [role="complementary"] { background-color: #3c3f41 !important; }
            button, input, textarea, select, [role="button"] {
              background-color: #3c3f41 !important;
              color: #a9b7c6 !important;
              border-color: #5c6164 !important;
            }
            button:hover, [role="button"]:hover { background-color: #4b5052 !important; }
            a { color: #589df6 !important; }
            a:hover { color: #73b1ff !important; }
            pre, code { background-color: #313335 !important; color: #a9b7c6 !important; }
            ::selection { background: #214283 !important; color: #dfe6ee !important; }
            ::-webkit-scrollbar-thumb { background: #5c6164 !important; border-radius: 8px !important; }
            ::-webkit-scrollbar-track { background: #2b2b2b !important; }
            """
        case .dracula:
            return """
            :root, html, body, #root {
              color-scheme: dark !important;
              background: #282a36 !important;
              color: #f8f8f2 !important;
            }
            * { border-color: #44475a !important; }
            main, section, article, aside, header, footer, nav, div[data-panel], [data-theme="dark"] {
              background-color: #282a36 !important;
              color: #f8f8f2 !important;
            }
            aside, nav, [data-sidebar], [role="complementary"] { background-color: #21222c !important; }
            button, input, textarea, select, [role="button"] {
              background-color: #44475a !important;
              color: #f8f8f2 !important;
              border-color: #6272a4 !important;
            }
            button:hover, [role="button"]:hover { background-color: #505674 !important; }
            a { color: #8be9fd !important; }
            a:hover { color: #50fa7b !important; }
            pre, code { background-color: #21222c !important; color: #f8f8f2 !important; }
            ::selection { background: #6272a4 !important; color: #f8f8f2 !important; }
            ::-webkit-scrollbar-thumb { background: #6272a4 !important; border-radius: 8px !important; }
            ::-webkit-scrollbar-track { background: #282a36 !important; }
            """
        case .nord:
            return """
            :root, html, body, #root {
              color-scheme: dark !important;
              background: #2e3440 !important;
              color: #d8dee9 !important;
            }
            * { border-color: #4c566a !important; }
            main, section, article, aside, header, footer, nav, div[data-panel], [data-theme="dark"] {
              background-color: #2e3440 !important;
              color: #d8dee9 !important;
            }
            aside, nav, [data-sidebar], [role="complementary"] { background-color: #3b4252 !important; }
            button, input, textarea, select, [role="button"] {
              background-color: #3b4252 !important;
              color: #d8dee9 !important;
              border-color: #4c566a !important;
            }
            button:hover, [role="button"]:hover { background-color: #434c5e !important; }
            a { color: #88c0d0 !important; }
            a:hover { color: #8fbcbb !important; }
            pre, code { background-color: #3b4252 !important; color: #e5e9f0 !important; }
            ::selection { background: #5e81ac !important; color: #eceff4 !important; }
            ::-webkit-scrollbar-thumb { background: #4c566a !important; border-radius: 8px !important; }
            ::-webkit-scrollbar-track { background: #2e3440 !important; }
            """
        case .monokai:
            return """
            :root, html, body, #root {
              color-scheme: dark !important;
              background: #272822 !important;
              color: #f8f8f2 !important;
            }
            * { border-color: #49483e !important; }
            main, section, article, aside, header, footer, nav, div[data-panel], [data-theme="dark"] {
              background-color: #272822 !important;
              color: #f8f8f2 !important;
            }
            aside, nav, [data-sidebar], [role="complementary"] { background-color: #1e1f1c !important; }
            button, input, textarea, select, [role="button"] {
              background-color: #3e3d32 !important;
              color: #f8f8f2 !important;
              border-color: #75715e !important;
            }
            button:hover, [role="button"]:hover { background-color: #4a493e !important; }
            a { color: #66d9ef !important; }
            a:hover { color: #a6e22e !important; }
            pre, code { background-color: #1e1f1c !important; color: #f8f8f2 !important; }
            ::selection { background: #75715e !important; color: #f8f8f2 !important; }
            ::-webkit-scrollbar-thumb { background: #75715e !important; border-radius: 8px !important; }
            ::-webkit-scrollbar-track { background: #272822 !important; }
            """
        }
    }

    public var injectExpression: String {
        let idJSON = Self.jsonString(Self.styleElementID)
        let cssJSON = Self.jsonString(css)
        return """
        (() => {
          const id = \(idJSON);
          let style = document.getElementById(id);
          if (!style) {
            style = document.createElement('style');
            style.id = id;
            document.documentElement.appendChild(style);
          }
          style.textContent = \(cssJSON);
          return 'injected';
        })()
        """
    }

    public static var removeExpression: String {
        let idJSON = jsonString(styleElementID)
        return """
        (() => {
          const id = \(idJSON);
          const style = document.getElementById(id);
          if (style) {
            style.remove();
            return 'removed';
          }
          return 'not-found';
        })()
        """
    }

    private static func jsonString(_ value: String) -> String {
        let data = try? JSONSerialization.data(withJSONObject: [value])
        guard
            let data,
            let json = String(data: data, encoding: .utf8),
            json.count >= 2
        else {
            return "\"\""
        }

        let start = json.index(after: json.startIndex)
        let end = json.index(before: json.endIndex)
        return String(json[start..<end])
    }
}

public enum DarculaTheme {
    public static let styleElementID = CodexTheme.styleElementID
    public static let css = CodexTheme.darcula.css
    public static var injectExpression: String { CodexTheme.darcula.injectExpression }
    public static var removeExpression: String { CodexTheme.removeExpression }
}
