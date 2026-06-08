import Foundation
import CoreGraphics

enum KeySimulator {
    static func tap(keyCode: CGKeyCode, flags: CGEventFlags = []) {
        let source = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let up = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        down?.flags = flags
        up?.flags = flags
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    static func typeString(_ string: String, characterDelay: TimeInterval) async {
        for char in string {
            let source = CGEventSource(stateID: .hidSystemState)
            var unichars = Array(char.utf16)

            let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
            down?.keyboardSetUnicodeString(stringLength: unichars.count, unicodeString: &unichars)
            down?.post(tap: .cghidEventTap)

            let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
            up?.keyboardSetUnicodeString(stringLength: unichars.count, unicodeString: &unichars)
            up?.post(tap: .cghidEventTap)

            if characterDelay > 0 {
                try? await Task.sleep(for: .milliseconds(Int(characterDelay * 1000)))
            }
        }
    }
}
