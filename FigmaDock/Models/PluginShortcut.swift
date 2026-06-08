import Foundation
import Carbon.HIToolbox

struct PluginShortcut: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var displayName: String
    var icon: PluginIcon
    var hotkey: HotkeyCombo?
    var sortOrder: Int = 0

    init(name: String, displayName: String? = nil, icon: PluginIcon = .emoji("🔌"), hotkey: HotkeyCombo? = nil, sortOrder: Int = 0) {
        self.name = name
        self.displayName = displayName ?? name
        self.icon = icon
        self.hotkey = hotkey
        self.sortOrder = sortOrder
    }

    enum PluginIcon: Codable, Hashable {
        case emoji(String)
        case sfSymbol(String)
        case customImage(String)

        var displayString: String {
            switch self {
            case .emoji(let s): return s
            case .sfSymbol(let s): return s
            case .customImage(let s): return s
            }
        }
    }

    struct HotkeyCombo: Codable, Hashable {
        var keyCode: UInt32
        var modifiers: UInt32

        var useCommand: Bool {
            get { modifiers & UInt32(cmdKey) != 0 }
            set { if newValue { modifiers |= UInt32(cmdKey) } else { modifiers &= ~UInt32(cmdKey) } }
        }
        var useOption: Bool {
            get { modifiers & UInt32(optionKey) != 0 }
            set { if newValue { modifiers |= UInt32(optionKey) } else { modifiers &= ~UInt32(optionKey) } }
        }
        var useControl: Bool {
            get { modifiers & UInt32(controlKey) != 0 }
            set { if newValue { modifiers |= UInt32(controlKey) } else { modifiers &= ~UInt32(controlKey) } }
        }
        var useShift: Bool {
            get { modifiers & UInt32(shiftKey) != 0 }
            set { if newValue { modifiers |= UInt32(shiftKey) } else { modifiers &= ~UInt32(shiftKey) } }
        }

        var displayString: String {
            var parts: [String] = []
            if useControl { parts.append("⌃") }
            if useOption { parts.append("⌥") }
            if useShift { parts.append("⇧") }
            if useCommand { parts.append("⌘") }
            parts.append(KeyCodeMap.name(for: keyCode))
            return parts.joined()
        }

        static var `default`: HotkeyCombo {
            HotkeyCombo(keyCode: 0x12, modifiers: UInt32(cmdKey) | UInt32(optionKey))
        }
    }
}

enum KeyCodeMap {
    static let allKeys: [(name: String, code: UInt32)] = [
        ("1", 0x12), ("2", 0x13), ("3", 0x14), ("4", 0x15), ("5", 0x17),
        ("6", 0x16), ("7", 0x1A), ("8", 0x1C), ("9", 0x19), ("0", 0x1D),
        ("A", 0x00), ("B", 0x0B), ("C", 0x08), ("D", 0x02), ("E", 0x0E),
        ("F", 0x03), ("G", 0x05), ("H", 0x04), ("I", 0x22), ("J", 0x26),
        ("K", 0x28), ("L", 0x25), ("M", 0x2E), ("N", 0x2D), ("O", 0x1F),
        ("P", 0x23), ("Q", 0x0C), ("R", 0x0F), ("S", 0x01), ("T", 0x11),
        ("U", 0x20), ("V", 0x09), ("W", 0x0D), ("X", 0x07), ("Y", 0x10),
        ("Z", 0x06),
    ]

    private static let names: [UInt32: String] = {
        var map: [UInt32: String] = [:]
        for key in allKeys { map[key.code] = key.name }
        return map
    }()

    static func name(for keyCode: UInt32) -> String {
        names[keyCode] ?? "Key\(keyCode)"
    }
}
