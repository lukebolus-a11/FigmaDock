import AppKit
import CoreGraphics

enum AutomationError: LocalizedError {
    case figmaNotRunning
    case accessibilityNotTrusted

    var errorDescription: String? {
        switch self {
        case .figmaNotRunning:
            "Figma is not running. Please open Figma first."
        case .accessibilityNotTrusted:
            "Accessibility permission required. Open Settings to grant access."
        }
    }
}

struct FigmaAutomation: Sendable {
    let settings: AppSettings

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
        try await Task.sleep(for: .milliseconds(Int(settings.activationDelay * 1000)))

        KeySimulator.tap(keyCode: settings.quickActionsKeyCode, flags: settings.quickActionsModifiers)
        try await Task.sleep(for: .milliseconds(Int(settings.commandSlashDelay * 1000)))

        await KeySimulator.typeString(pluginName, characterDelay: settings.typingDelay)
        try await Task.sleep(for: .milliseconds(Int(settings.enterDelay * 1000)))

        KeySimulator.tap(keyCode: 0x24)
    }
}
