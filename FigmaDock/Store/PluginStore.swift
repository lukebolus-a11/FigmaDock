import Foundation
import SwiftUI

@MainActor
class PluginStore: ObservableObject {
    @Published var plugins: [PluginShortcut] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isDockVisible: Bool = true

    init() {
        Constants.ensureAppSupportDir()
        load()
    }

    func load() {
        plugins = Self.decode(from: Constants.pluginsFileURL) ?? []
        settings = Self.decode(from: Constants.settingsFileURL) ?? AppSettings()
        plugins.sort { $0.sortOrder < $1.sortOrder }
    }

    func save() {
        for i in plugins.indices {
            plugins[i].sortOrder = i
        }
        Self.encode(plugins, to: Constants.pluginsFileURL)
        Self.encode(settings, to: Constants.settingsFileURL)
    }

    func addPlugin(_ plugin: PluginShortcut) {
        var p = plugin
        p.sortOrder = plugins.count
        plugins.append(p)
        save()
    }

    func updatePlugin(_ plugin: PluginShortcut) {
        if let idx = plugins.firstIndex(where: { $0.id == plugin.id }) {
            plugins[idx] = plugin
            save()
        }
    }

    func deletePlugin(_ plugin: PluginShortcut) {
        plugins.removeAll { $0.id == plugin.id }
        save()
    }

    func deletePlugins(at offsets: IndexSet) {
        plugins.remove(atOffsets: offsets)
        save()
    }

    func movePlugins(from source: IndexSet, to destination: Int) {
        plugins.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private static func decode<T: Decodable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func encode<T: Encodable>(_ value: T, to url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(value) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
