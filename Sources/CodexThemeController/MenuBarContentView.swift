import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @ObservedObject var model: AppViewModel
    let openMainWindow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Codex Theme Controller")
                .font(.headline)

            Text("Instances: \(model.instances.count), injectable: \(model.injectableCount)")
                .font(.subheadline)

            Text(model.statusMessage.isEmpty ? "Ready" : model.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Divider()

            Button("Open Window") {
                openMainWindow()
            }

            Button("Refresh") {
                model.refresh()
            }
            .disabled(model.isScanning)

            Picker(
                "Theme",
                selection: Binding(
                    get: { model.selectedTheme },
                    set: { model.selectTheme($0) }
                )
            ) {
                ForEach(model.availableThemes) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }

            Button("Apply to All") {
                model.applySelectedThemeToAll()
            }
            .disabled(model.injectableCount == 0 || model.isWorking)

            Button("Launch Codex (port \(model.launchPortText))") {
                model.launchCodexWithPort()
            }
            .disabled(model.isLaunching)

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding(12)
        .frame(minWidth: 300)
        .onAppear {
            model.refresh()
        }
    }
}
