import AppKit
import CoreGraphics

enum AutomationError: LocalizedError {
    case figmaNotRunning
    case accessibilityNotTrusted

    var errorDescription: String? {
        switch self {
        case .figmaNotRunning: return "Figma is not running. Please open Figma first."
        case .accessibilityNotTrusted: return "Accessibility permission required. Open Settings to grant access."
        }
    }
}

class FigmaAutomation {
    let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func launchPlugin(named pluginName: String) async throws {
        guard AccessibilityManager.isTrusted else {
            throw AutomationError.accessibilityNotTrusted
        }

        guard let figma = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleIdentifier == Constants.figmaBundleID
        }) else {
            throw AutomationError.figmaNotRunning
        }

        figma.activate()
        try await sleep(settings.activationDelay)

        KeySimulator.tap(keyCode: settings.quickActionsKeyCode, flags: settings.quickActionsModifiers)
        try await sleep(settings.commandSlashDelay)

        await KeySimulator.typeString(pluginName, delay: settings.typingDelay)
        try await sleep(settings.enterDelay)

        KeySimulator.tap(keyCode: 0x24) // Return
    }

    private func sleep(_ duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
    }
}
