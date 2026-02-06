import SwiftUI
import AppKit
import CodexThemeControllerCore

struct ContentView: View {
    @ObservedObject var model: AppViewModel
    let onWindowReady: (NSWindow?) -> Void

    var body: some View {
        VStack(spacing: 0) {
            themeSection
            Divider()
            launchSection
            Spacer(minLength: 0)
            statusBar
        }
        .frame(minWidth: 520, minHeight: 300)
        .animation(.easeInOut(duration: 0.15), value: model.selectedTheme)
        .onAppear {
            model.refresh()
        }
        .background(
            WindowAccessor(onResolve: onWindowReady)
                .frame(width: 0, height: 0)
        )
    }

    // MARK: - Theme

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Theme")
                .font(.title3.weight(.semibold))

            HStack(spacing: 10) {
                ForEach(model.availableThemes) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: model.selectedTheme == theme
                    ) {
                        model.selectTheme(theme)
                    }
                }
            }
        }
        .padding(20)
    }

    // MARK: - Launch

    private var launchSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.secondary)

            Text("Launch Codex on port")
                .font(.subheadline)

            TextField("Port", text: $model.launchPortText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 72)

            Button(model.isLaunching ? "Launching\u{2026}" : "Launch & Apply") {
                model.launchCodexWithPort()
            }
            .disabled(model.isLaunching)

            if model.isLaunching {
                ProgressView()
                    .controlSize(.small)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: - Status bar

    private var statusBar: some View {
        HStack(spacing: 8) {
            if model.isScanning {
                ProgressView()
                    .controlSize(.small)
            } else {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
            }

            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            if model.injectableCount > 0 {
                Text("\(model.injectableCount) injectable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button("Apply to All") {
                model.applySelectedThemeToAll()
            }
            .controlSize(.small)
            .disabled(model.injectableCount == 0 || model.isWorking)

            Button {
                model.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .controlSize(.small)
            .disabled(model.isScanning)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.25))
    }

    // MARK: - Helpers

    private var statusText: String {
        model.statusMessage.isEmpty ? "Ready" : model.statusMessage
    }

    private var statusColor: Color {
        let message = statusText.lowercased()
        if message.contains("fail") || message.contains("error") || message.contains("invalid") {
            return .orange
        }
        if message.contains("launch") || message.contains("applied") || message.contains("found") {
            return .green
        }
        return .secondary
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {
    let theme: CodexTheme
    let isSelected: Bool
    let action: () -> Void

    private struct Palette {
        let bg: UInt32
        let surface: UInt32
        let accent: UInt32
        let text: UInt32
        let secondary: UInt32
    }

    private var palette: Palette {
        switch theme {
        case .darcula:
            Palette(bg: 0x2B2B2B, surface: 0x3C3F41, accent: 0x589DF6, text: 0xA9B7C6, secondary: 0x214283)
        case .dracula:
            Palette(bg: 0x282A36, surface: 0x44475A, accent: 0x8BE9FD, text: 0xF8F8F2, secondary: 0x50FA7B)
        case .nord:
            Palette(bg: 0x2E3440, surface: 0x3B4252, accent: 0x88C0D0, text: 0xE5E9F0, secondary: 0x5E81AC)
        case .monokai:
            Palette(bg: 0x272822, surface: 0x3E3D32, accent: 0x66D9EF, text: 0xF8F8F2, secondary: 0xA6E22E)
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Window chrome
                HStack(spacing: 4) {
                    Circle().fill(Color(hex: 0xFF5F56)).frame(width: 6, height: 6)
                    Circle().fill(Color(hex: 0xFFBD2E)).frame(width: 6, height: 6)
                    Circle().fill(Color(hex: 0x27C93F)).frame(width: 6, height: 6)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(hex: palette.surface))

                // Faux code lines
                VStack(alignment: .leading, spacing: 6) {
                    codeLine(segments: [
                        (palette.accent, 24), (palette.text, 44),
                    ])
                    codeLine(segments: [
                        (palette.text, 16), (palette.secondary, 36), (palette.text, 20),
                    ])
                    codeLine(segments: [
                        (palette.accent, 20), (palette.text, 30),
                    ])
                    codeLine(segments: [
                        (palette.text, 12), (palette.secondary, 28),
                    ])
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: palette.bg))

                // Name
                Text(theme.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(hex: palette.text))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Color(hex: palette.surface))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isSelected ? Color.accentColor : .clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.35) : .black.opacity(0.15),
                radius: isSelected ? 6 : 2,
                y: 1
            )
        }
        .buttonStyle(.plain)
    }

    private func codeLine(segments: [(UInt32, CGFloat)]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, seg in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: seg.0).opacity(0.85))
                    .frame(width: seg.1, height: 4)
            }
        }
    }
}

// MARK: - Color hex init

private extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
