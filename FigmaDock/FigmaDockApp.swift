import SwiftUI

@main
struct FigmaDockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenSettings),
            name: .openSettings,
            object: nil
        )
    }

    @objc private func handleOpenSettings() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
