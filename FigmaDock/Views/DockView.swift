import SwiftUI
import AppKit

struct DockView: View {
    @ObservedObject var store: PluginStore
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Group {
            if store.settings.dockOrientation == .horizontal {
                HStack(spacing: 6) {
                    buttons
                    settingsButton
                }
            } else {
                VStack(spacing: 6) {
                    buttons
                    settingsButton
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .brightness(store.settings.dockBrightness)
        .opacity(store.settings.dockOpacity)
    }

    @ViewBuilder
    private var buttons: some View {
        if store.plugins.isEmpty {
            Text("No plugins")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 80, height: 30)
        } else {
            ForEach(store.plugins) { plugin in
                DockIconButton(plugin: plugin, size: store.settings.iconSize) {
                    launchPlugin(plugin)
                }
            }
        }
    }

    private var settingsButton: some View {
        Button {
            NSApp.activate(ignoringOtherApps: true)
            openSettings()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: store.settings.iconSize * 0.35))
                .foregroundStyle(.secondary)
                .frame(width: store.settings.iconSize * 0.7, height: store.settings.iconSize * 0.7)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Settings")
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

struct DockIconButton: View {
    let plugin: PluginShortcut
    let size: Double
    let action: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            iconContent
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .fill(isPressed ? Color.white.opacity(0.2) : isHovered ? Color.white.opacity(0.1) : Color.clear)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .help(plugin.displayName)
    }

    @ViewBuilder
    private var iconContent: some View {
        switch plugin.icon {
        case .emoji(let emoji):
            Text(emoji).font(.system(size: size * 0.55))
        case .sfSymbol(let name):
            Image(systemName: name)
                .font(.system(size: size * 0.45))
                .foregroundStyle(.primary)
        case .customImage(let filename):
            if let nsImage = IconStorage.loadImage(filename: filename) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.65, height: size * 0.65)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.12))
            } else {
                Image(systemName: "photo")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
