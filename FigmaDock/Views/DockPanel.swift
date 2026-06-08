import AppKit
import SwiftUI

class DockPanel: NSPanel {
    override var canBecomeKey: Bool { false }

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 60),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        animationBehavior = .utilityWindow
    }

    func setAlwaysOnTop(_ enabled: Bool) {
        level = enabled ? .floating : .normal
    }
}

@MainActor
class DockPanelController: ObservableObject {
    private var panel: DockPanel?
    @Published var isVisible: Bool = false

    func show(store: PluginStore) {
        if panel == nil {
            let p = DockPanel()
            let hosting = NSHostingView(rootView: DockView(store: store))
            hosting.frame = p.contentView?.bounds ?? .zero
            hosting.autoresizingMask = [.width, .height]
            p.contentView?.addSubview(hosting)
            panel = p
        }

        panel?.setAlwaysOnTop(store.settings.alwaysOnTop)
        updateSize(store: store)
        if !isVisible {
            panel?.center()
        }
        panel?.orderFront(nil)
        isVisible = true
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
    }

    func toggle(store: PluginStore) {
        if isVisible {
            hide()
        } else {
            show(store: store)
        }
    }

    func updateAlwaysOnTop(_ enabled: Bool) {
        panel?.setAlwaysOnTop(enabled)
    }

    func updateSize(store: PluginStore) {
        guard let panel else { return }
        let count = max(store.plugins.count, 1)
        let iconSize = store.settings.iconSize
        let padding: CGFloat = 24
        let spacing: CGFloat = 6
        let gearSize = iconSize * 0.7

        let width: CGFloat
        let height: CGFloat

        if store.settings.dockOrientation == .horizontal {
            width = CGFloat(count) * (iconSize + spacing) + gearSize + spacing - spacing + padding * 2
            height = iconSize + padding * 2
        } else {
            width = iconSize + padding * 2
            height = CGFloat(count) * (iconSize + spacing) + gearSize + spacing - spacing + padding * 2
        }

        let origin = panel.frame.origin
        panel.setFrame(NSRect(x: origin.x, y: origin.y, width: width, height: height), display: true)
    }
}
