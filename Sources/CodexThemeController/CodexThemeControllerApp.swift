import SwiftUI

@main
struct CodexThemeControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppViewModel()

    var body: some Scene {
        WindowGroup("Codex Theme Controller") {
            ContentView(
                model: model,
                onWindowReady: appDelegate.registerMainWindow
            )
        }

        MenuBarExtra {
            MenuBarContentView(
                model: model,
                openMainWindow: appDelegate.showMainWindow
            )
        } label: {
            Label("Codex Theme", systemImage: "paintpalette.fill")
        }
        .menuBarExtraStyle(.menu)
    }
}
