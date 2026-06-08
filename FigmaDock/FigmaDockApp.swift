import SwiftUI

@main
struct FigmaDockApp: App {
    @StateObject private var store = PluginStore()
    @StateObject private var dockController = DockPanelController()

    var body: some Scene {
        MenuBarExtra("FigmaDock", systemImage: "square.grid.3x3.fill") {
            MenuBarView(store: store, dockController: dockController)
        }

        Settings {
            SettingsView(store: store)
                .environmentObject(dockController)
        }
    }

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !AccessibilityManager.isTrusted {
                AccessibilityManager.requestTrust()
            }
        }
    }
}
