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
            Self.onLaunch()
        }
    }

    private static func onLaunch() {
        if !AccessibilityManager.isTrusted {
            AccessibilityManager.requestTrust()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var store: PluginStore?
    var dockController: DockPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let store, let dockController else { return }

        if store.settings.showDockOnLaunch {
            dockController.show(store: store)
        }

        GlobalHotkeyManager.shared.registerAll(plugins: store.plugins) { plugin in
            Task {
                try? await FigmaAutomation(settings: store.settings).launchPlugin(named: plugin.name)
            }
        }
    }
}
