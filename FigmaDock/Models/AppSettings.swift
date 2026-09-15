import Foundation
import CoreGraphics

struct AppSettings: Codable, Sendable {
    var activationDelay: TimeInterval = 0.3
    var commandSlashDelay: TimeInterval = 0.35
    var typingDelay: TimeInterval = 0.03
    // Recent Figma loads Quick Actions plugin results asynchronously; Enter must
    // wait for the plugin to become the top result, otherwise a built-in menu
    // command matching the typed text runs instead.
    var enterDelay: TimeInterval = 1.0
    var dockOrientation: DockOrientation = .horizontal
    var showDockOnLaunch: Bool = true
    var alwaysOnTop: Bool = true
    var iconSize: Double = 44
    var dockOpacity: Double = 1.0
    var dockTint: Float = 0.0

    var dockTintDouble: Double {
        get { Double(dockTint) }
        set { dockTint = Float(newValue) }
    }

    var quickActionsKeyCode: UInt16 { 0x2C }
    var quickActionsModifiers: CGEventFlags { .maskCommand }

    enum DockOrientation: String, Codable, CaseIterable, Sendable {
        case horizontal
        case vertical
    }
}
