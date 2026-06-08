import SwiftUI

struct MenuBarView: View {
    @ObservedObject var store: PluginStore
    @ObservedObject var dockController: DockPanelController

    var body: some View {
        if store.plugins.isEmpty {
            Text("No plugins configured")
                .foregroundStyle(.secondary)
        } else {
            ForEach(store.plugins) { plugin in
                Button {
                    launchPlugin(plugin)
                } label: {
                    HStack {
                        pluginIconView(plugin.icon, size: 16)
                        Text(plugin.displayName)
                        Spacer()
                        if let hotkey = plugin.hotkey {
                            Text(hotkey.displayString)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }

        Divider()

        Button(dockController.isVisible ? "Hide Dock" : "Show Dock") {
            dockController.toggle(store: store)
        }
        .keyboardShortcut("d", modifiers: [.command, .shift])

        Divider()

        SettingsLink {
            Text("Settings...")
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Quit FigmaDock") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }

    private func launchPlugin(_ plugin: PluginShortcut) {
        Task {
            do {
                try await FigmaAutomation(settings: store.settings).launchPlugin(named: plugin.name)
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }
}
