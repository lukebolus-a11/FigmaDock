import Foundation
import CoreGraphics

struct AppSettings: Codable {
    var activationDelay: TimeInterval = 0.3
    var commandSlashDelay: TimeInterval = 0.3
    var typingDelay: TimeInterval = 0.03
    var enterDelay: TimeInterval = 0.4
    var dockOrientation: DockOrientation = .horizontal
    var showDockOnLaunch: Bool = true
    var alwaysOnTop: Bool = true
    var iconSize: Double = 44
    var quickActionsKeyCode: UInt16 = 0x2C
    var quickActionsModifiers: CGEventFlags = .maskCommand

    enum DockOrientation: String, Codable, CaseIterable {
        case horizontal
        case vertical
    }

    enum CodingKeys: String, CodingKey {
        case activationDelay, commandSlashDelay, typingDelay, enterDelay
        case dockOrientation, showDockOnLaunch, alwaysOnTop, iconSize
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        activationDelay = try c.decodeIfPresent(TimeInterval.self, forKey: .activationDelay) ?? 0.3
        commandSlashDelay = try c.decodeIfPresent(TimeInterval.self, forKey: .commandSlashDelay) ?? 0.3
        typingDelay = try c.decodeIfPresent(TimeInterval.self, forKey: .typingDelay) ?? 0.03
        enterDelay = try c.decodeIfPresent(TimeInterval.self, forKey: .enterDelay) ?? 0.4
        dockOrientation = try c.decodeIfPresent(DockOrientation.self, forKey: .dockOrientation) ?? .horizontal
        showDockOnLaunch = try c.decodeIfPresent(Bool.self, forKey: .showDockOnLaunch) ?? true
        alwaysOnTop = try c.decodeIfPresent(Bool.self, forKey: .alwaysOnTop) ?? true
        iconSize = try c.decodeIfPresent(Double.self, forKey: .iconSize) ?? 44
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activationDelay, forKey: .activationDelay)
        try c.encode(commandSlashDelay, forKey: .commandSlashDelay)
        try c.encode(typingDelay, forKey: .typingDelay)
        try c.encode(enterDelay, forKey: .enterDelay)
        try c.encode(dockOrientation, forKey: .dockOrientation)
        try c.encode(showDockOnLaunch, forKey: .showDockOnLaunch)
        try c.encode(alwaysOnTop, forKey: .alwaysOnTop)
        try c.encode(iconSize, forKey: .iconSize)
    }
}
