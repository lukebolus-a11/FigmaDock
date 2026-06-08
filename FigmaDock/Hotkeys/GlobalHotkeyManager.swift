import Carbon
import AppKit

@MainActor
class GlobalHotkeyManager {
    private var registeredHotkeys: [(id: EventHotKeyID, ref: EventHotKeyRef?, handler: () -> Void)] = []
    private var handlerRef: EventHandlerRef?

    static let shared = GlobalHotkeyManager()

    private init() {
        installHandler()
    }

    func registerAll(plugins: [PluginShortcut], action: @escaping (PluginShortcut) -> Void) {
        unregisterAll()

        for (index, plugin) in plugins.enumerated() {
            guard let combo = plugin.hotkey else { continue }

            var hotKeyID = EventHotKeyID()
            hotKeyID.signature = OSType(0x4644_4B00) // "FDK\0"
            hotKeyID.id = UInt32(index)

            var hotKeyRef: EventHotKeyRef?
            let status = RegisterEventHotKey(
                combo.keyCode,
                combo.modifiers,
                hotKeyID,
                GetApplicationEventTarget(),
                0,
                &hotKeyRef
            )

            if status == noErr {
                let pluginCopy = plugin
                registeredHotkeys.append((
                    id: hotKeyID,
                    ref: hotKeyRef,
                    handler: { action(pluginCopy) }
                ))
            }
        }
    }

    func unregisterAll() {
        for entry in registeredHotkeys {
            if let ref = entry.ref {
                UnregisterEventHotKey(ref)
            }
        }
        registeredHotkeys.removeAll()
    }

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { _, event, _ -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            guard status == noErr else { return OSStatus(eventNotHandledErr) }

            Task { @MainActor in
                let mgr = GlobalHotkeyManager.shared
                if let entry = mgr.registeredHotkeys.first(where: { $0.id.id == hotKeyID.id }) {
                    entry.handler()
                }
            }
            return noErr
        }

        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, &handlerRef)
    }
}
