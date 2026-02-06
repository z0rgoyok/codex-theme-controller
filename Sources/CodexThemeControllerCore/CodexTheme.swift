import Foundation

public enum CodexTheme: String, CaseIterable, Codable, Sendable, Identifiable {
    case darcula
    case dracula
    case nord
    case monokai

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .darcula: "Darcula"
        case .dracula: "Dracula"
        case .nord: "Nord"
        case .monokai: "Monokai"
        }
    }

    public static let styleElementID = "codex-theme-controller-style"

    // MARK: - Token palette

    private struct Palette {
        let bg: String
        let surface: String
        let surfaceAlt: String
        let text: String
        let accent: String
        let selection: String
        let green: String
        let red: String
        let yellow: String
        let orange: String
        let purple: String
    }

    private var palette: Palette {
        switch self {
        case .darcula:
            Palette(
                bg: "#2b2b2b", surface: "#3c3f41", surfaceAlt: "#313335",
                text: "#a9b7c6", accent: "#589df6", selection: "#214283",
                green: "#6a8759", red: "#cc7832", yellow: "#ffc66d",
                orange: "#cc7832", purple: "#9876aa"
            )
        case .dracula:
            Palette(
                bg: "#282a36", surface: "#44475a", surfaceAlt: "#21222c",
                text: "#f8f8f2", accent: "#8be9fd", selection: "#44475a",
                green: "#50fa7b", red: "#ff5555", yellow: "#f1fa8c",
                orange: "#ffb86c", purple: "#bd93f9"
            )
        case .nord:
            Palette(
                bg: "#2e3440", surface: "#3b4252", surfaceAlt: "#434c5e",
                text: "#d8dee9", accent: "#88c0d0", selection: "#434c5e",
                green: "#a3be8c", red: "#bf616a", yellow: "#ebcb8b",
                orange: "#d08770", purple: "#b48ead"
            )
        case .monokai:
            Palette(
                bg: "#272822", surface: "#3e3d32", surfaceAlt: "#1e1f1c",
                text: "#f8f8f2", accent: "#66d9ef", selection: "#49483e",
                green: "#a6e22e", red: "#f92672", yellow: "#e6db74",
                orange: "#fd971f", purple: "#ae81ff"
            )
        }
    }

    // MARK: - CSS generation (token overrides)

    public var css: String {
        let p = palette
        return """
        :root, html {
          color-scheme: dark !important;

          /* ── backgrounds ── */
          --color-token-bg-primary: \(p.bg) !important;
          --color-token-bg-secondary: \(p.bg) !important;
          --color-token-bg-tertiary: \(p.bg) !important;
          --color-token-bg-fog: color-mix(in oklab, \(p.text) 3%, transparent) !important;
          --color-token-main-surface-primary: \(p.bg) !important;
          --color-token-side-bar-background: \(p.surface) !important;
          --color-background-surface: \(p.bg) !important;
          --color-background-surface-under: \(p.bg) !important;
          --color-background-elevated-primary-opaque: \(p.surface) !important;
          --color-background-elevated-primary: \(p.surface) !important;
          --color-background-elevated-secondary-opaque: \(p.surfaceAlt) !important;
          --color-background-elevated-secondary: color-mix(in oklab, \(p.text) 3%, transparent) !important;
          --color-token-dropdown-background: \(p.surface) !important;
          --color-token-menu-background: \(p.surface) !important;
          --color-token-terminal-background: \(p.bg) !important;
          --color-token-editor-background: \(p.surfaceAlt) !important;
          --color-token-input-background: \(p.surface) !important;
          --color-token-checkbox-background: \(p.surface) !important;
          --color-token-text-code-block-background: \(p.surfaceAlt) !important;

          /* ── button backgrounds ── */
          --color-token-button-background: \(p.accent) !important;
          --color-background-button-primary: \(p.accent) !important;
          --color-background-button-primary-hover: color-mix(in oklab, \(p.accent) 85%, transparent) !important;
          --color-background-button-primary-active: color-mix(in oklab, \(p.accent) 75%, transparent) !important;
          --color-background-button-primary-inactive: color-mix(in oklab, \(p.accent) 50%, transparent) !important;
          --color-token-button-secondary-background: color-mix(in oklab, \(p.text) 8%, transparent) !important;
          --color-token-button-secondary-hover-background: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-background-button-secondary: color-mix(in oklab, \(p.text) 8%, transparent) !important;
          --color-background-button-secondary-hover: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-background-button-secondary-active: color-mix(in oklab, \(p.text) 6%, transparent) !important;
          --color-background-button-secondary-inactive: color-mix(in oklab, \(p.text) 4%, transparent) !important;
          --color-background-button-tertiary: transparent !important;
          --color-background-button-tertiary-hover: color-mix(in oklab, \(p.text) 10%, transparent) !important;
          --color-background-button-tertiary-active: color-mix(in oklab, \(p.text) 20%, transparent) !important;
          --color-background-danger: color-mix(in oklab, \(p.red) 15%, transparent) !important;
          --color-background-danger-hover: color-mix(in oklab, \(p.red) 25%, transparent) !important;

          /* ── accent backgrounds ── */
          --color-background-accent: color-mix(in oklab, \(p.accent) 15%, transparent) !important;
          --color-background-accent-hover: color-mix(in oklab, \(p.accent) 20%, transparent) !important;
          --color-background-accent-active: color-mix(in oklab, \(p.accent) 25%, transparent) !important;
          --color-background-status-error: color-mix(in oklab, \(p.red) 15%, transparent) !important;
          --color-background-status-warning: color-mix(in oklab, \(p.orange) 15%, transparent) !important;
          --color-background-status-success: color-mix(in oklab, \(p.green) 10%, transparent) !important;

          /* ── foregrounds ── */
          --color-token-foreground: \(p.text) !important;
          --color-text-foreground: \(p.text) !important;
          --color-token-text-primary: \(p.text) !important;
          --color-token-editor-foreground: \(p.text) !important;
          --color-token-input-foreground: \(p.text) !important;
          --color-token-icon-foreground: \(p.text) !important;
          --color-icon-primary: \(p.text) !important;
          --color-token-terminal-foreground: \(p.text) !important;
          --color-token-checkbox-foreground: \(p.text) !important;
          --color-token-radio-active-foreground: \(p.text) !important;
          --color-text-button-secondary: \(p.text) !important;
          --color-token-editor-group-drop-into-prompt-foreground: \(p.text) !important;

          --color-token-text-secondary: color-mix(in srgb, \(p.text) 70%, transparent) !important;
          --color-token-text-tertiary: color-mix(in oklab, \(p.text) 55%, transparent) !important;
          --color-text-foreground-secondary: color-mix(in oklab, \(p.text) 70%, transparent) !important;
          --color-text-foreground-tertiary: color-mix(in oklab, \(p.text) 55%, transparent) !important;
          --color-text-button-tertiary: color-mix(in oklab, \(p.text) 70%, transparent) !important;
          --color-token-description-foreground: color-mix(in oklab, \(p.text) 55%, transparent) !important;
          --color-token-disabled-foreground: color-mix(in oklab, \(p.text) 45%, transparent) !important;
          --color-token-input-placeholder-foreground: color-mix(in oklab, \(p.text) 45%, transparent) !important;
          --color-icon-secondary: color-mix(in oklab, \(p.text) 70%, transparent) !important;
          --color-icon-tertiary: color-mix(in oklab, \(p.text) 55%, transparent) !important;
          --color-token-badge-foreground: color-mix(in oklab, \(p.text) 70%, transparent) !important;

          /* ── button foregrounds ── */
          --color-token-button-foreground: #fff !important;
          --color-text-button-primary: #fff !important;
          --color-icon-inverted: \(p.bg) !important;

          /* ── borders ── */
          --color-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-border-heavy: color-mix(in oklab, \(p.text) 18%, transparent) !important;
          --color-border-light: color-mix(in oklab, \(p.text) 8%, transparent) !important;
          --color-token-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-border-default: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-button-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-input-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-checkbox-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-menu-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-terminal-border: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-border-error: color-mix(in oklab, \(p.red) 25%, transparent) !important;
          --color-border-warning: color-mix(in oklab, \(p.orange) 25%, transparent) !important;

          /* ── accents & links ── */
          --color-accent-blue: \(p.accent) !important;
          --color-text-accent: \(p.accent) !important;
          --color-token-link: \(p.accent) !important;
          --color-token-text-link-foreground: \(p.accent) !important;
          --color-token-text-link-active-foreground: \(p.accent) !important;
          --color-token-focus-border: \(p.accent) !important;
          --color-border-focus: \(p.accent) !important;
          --color-icon-accent: \(p.accent) !important;
          --color-token-charts-blue: \(p.accent) !important;

          /* ── semantic colors ── */
          --color-accent-green: \(p.green) !important;
          --color-accent-red: \(p.red) !important;
          --color-accent-yellow: \(p.yellow) !important;
          --color-accent-orange: \(p.orange) !important;
          --color-accent-purple: \(p.purple) !important;
          --color-text-error: \(p.red) !important;
          --color-text-success: \(p.green) !important;
          --color-text-warning: \(p.orange) !important;
          --color-icon-error: \(p.red) !important;
          --color-icon-success: \(p.green) !important;
          --color-icon-warning: \(p.orange) !important;
          --color-token-error-foreground: \(p.red) !important;
          --color-token-editor-error-foreground: \(p.red) !important;
          --color-token-editor-warning-foreground: \(p.orange) !important;
          --color-token-charts-green: \(p.green) !important;
          --color-token-charts-red: \(p.red) !important;
          --color-token-charts-orange: \(p.orange) !important;
          --color-token-charts-purple: \(p.purple) !important;
          --color-decoration-added: \(p.green) !important;
          --color-decoration-deleted: \(p.red) !important;
          --color-decoration-modified: \(p.orange) !important;
          --color-token-git-decoration-added-resource-foreground: \(p.green) !important;
          --color-token-git-decoration-deleted-resource-foreground: \(p.red) !important;
          --color-editor-added: color-mix(in oklab, \(p.green) 15%, transparent) !important;
          --color-editor-deleted: color-mix(in oklab, \(p.red) 15%, transparent) !important;
          --color-editor-modified: color-mix(in oklab, \(p.orange) 15%, transparent) !important;

          /* ── selection & hover ── */
          --color-token-terminal-selection-background: \(p.selection) !important;
          --color-token-terminal-inactive-selection-background: color-mix(in oklab, \(p.selection) 60%, transparent) !important;
          --color-token-list-active-selection-background: color-mix(in oklab, \(p.text) 8%, transparent) !important;
          --color-token-list-hover-background: color-mix(in oklab, \(p.text) 5%, transparent) !important;
          --color-token-toolbar-hover-background: color-mix(in oklab, \(p.text) 7%, transparent) !important;
          --color-token-badge-background: color-mix(in oklab, \(p.text) 8%, transparent) !important;
          --color-token-editor-group-drop-background: color-mix(in oklab, \(p.accent) 15%, transparent) !important;
          --color-token-editor-group-drop-into-prompt-background: color-mix(in oklab, \(p.accent) 15%, transparent) !important;

          /* ── scrollbar ── */
          --color-token-scrollbar-slider-background: color-mix(in oklab, \(p.text) 12%, transparent) !important;
          --color-token-scrollbar-slider-hover-background: color-mix(in oklab, \(p.text) 18%, transparent) !important;
          --color-token-scrollbar-slider-active-background: color-mix(in oklab, \(p.text) 24%, transparent) !important;

          /* ── terminal ANSI ── */
          --color-token-terminal-ansi-black: color-mix(in oklab, \(p.text) 40%, transparent) !important;
          --color-token-terminal-ansi-bright-black: color-mix(in oklab, \(p.text) 60%, transparent) !important;
          --color-token-terminal-ansi-white: \(p.text) !important;
          --color-token-terminal-ansi-bright-white: \(p.text) !important;
          --color-token-terminal-ansi-red: \(p.red) !important;
          --color-token-terminal-ansi-bright-red: \(p.red) !important;
          --color-token-terminal-ansi-green: \(p.green) !important;
          --color-token-terminal-ansi-bright-green: \(p.green) !important;
          --color-token-terminal-ansi-yellow: \(p.yellow) !important;
          --color-token-terminal-ansi-bright-yellow: \(p.yellow) !important;
          --color-token-terminal-ansi-blue: \(p.accent) !important;
          --color-token-terminal-ansi-bright-blue: \(p.accent) !important;
          --color-token-terminal-ansi-magenta: \(p.purple) !important;
          --color-token-terminal-ansi-bright-magenta: \(p.purple) !important;
          --color-token-terminal-ansi-cyan: \(p.accent) !important;
          --color-token-terminal-ansi-bright-cyan: \(p.accent) !important;

          /* ── misc ── */
          --color-simple-scrim: rgba(0,0,0,0.4) !important;
          --color-token-input-validation-error-background: color-mix(in oklab, \(p.red) 15%, transparent) !important;
          --color-token-input-validation-error-border: color-mix(in oklab, \(p.red) 25%, transparent) !important;
          --color-token-input-validation-info-background: color-mix(in oklab, \(p.accent) 15%, transparent) !important;
          --color-token-input-validation-warning-background: color-mix(in oklab, \(p.orange) 15%, transparent) !important;
          --color-token-input-validation-warning-border: color-mix(in oklab, \(p.orange) 25%, transparent) !important;
        }

        /* Fallback element overrides */
        html, body, #root { background: \(p.bg) !important; color: \(p.text) !important; }
        .main-surface { background-color: \(p.bg) !important; }
        ::selection { background: \(p.selection) !important; color: \(p.text) !important; }
        ::-webkit-scrollbar-thumb { background: color-mix(in oklab, \(p.text) 15%, transparent) !important; border-radius: 8px !important; }
        ::-webkit-scrollbar-track { background: \(p.bg) !important; }
        """
    }

    // MARK: - JS expressions

    public var injectExpression: String {
        let idJSON = Self.jsonString(Self.styleElementID)
        let cssJSON = Self.jsonString(css)
        return """
        (() => {
          const el = document.documentElement;
          el.classList.remove('electron-light');
          el.classList.add('electron-dark');

          const id = \(idJSON);
          let style = document.getElementById(id);
          if (!style) {
            style = document.createElement('style');
            style.id = id;
            el.appendChild(style);
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
          const el = document.documentElement;
          el.classList.remove('electron-dark');
          el.classList.add('electron-light');

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

    // MARK: - Helpers

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
