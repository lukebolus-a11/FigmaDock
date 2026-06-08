import Foundation

enum Constants {
    static let appName = "FigmaDock"
    static let figmaBundleID = "com.figma.Desktop"

    static let appSupportDir: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("FigmaDock")
    }()

    static let pluginsFileURL = appSupportDir.appendingPathComponent("plugins.json")
    static let settingsFileURL = appSupportDir.appendingPathComponent("settings.json")

    static func ensureAppSupportDir() {
        try? FileManager.default.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
    }
}

extension Notification.Name {
    static let openSettings = Notification.Name("FigmaDock.openSettings")
}
