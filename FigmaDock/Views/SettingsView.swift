import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var store: PluginStore

    var body: some View {
        TabView {
            PluginListTab(store: store)
                .tabItem { Label("Plugins", systemImage: "puzzlepiece") }

            AppearanceTab(store: store)
                .tabItem { Label("Appearance", systemImage: "paintbrush") }

            AutomationTab(store: store)
                .tabItem { Label("Automation", systemImage: "gearshape.2") }
        }
        .frame(width: 540, height: 480)
    }
}

// MARK: - Plugins Tab

struct PluginListTab: View {
    @ObservedObject var store: PluginStore
    @State private var isShowingEditor = false
    @State private var isShowingBulkImport = false
    @State private var editingPlugin: PluginShortcut?

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(store.plugins) { plugin in
                    PluginRow(plugin: plugin)
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) { editingPlugin = plugin }
                        .contextMenu {
                            Button("Edit...") { editingPlugin = plugin }
                            Divider()
                            Button("Delete", role: .destructive) { store.deletePlugin(plugin) }
                        }
                }
                .onMove { store.movePlugins(from: $0, to: $1) }
                .onDelete { store.deletePlugins(at: $0) }
            }

            Divider()

            HStack {
                Button { isShowingEditor = true } label: {
                    Image(systemName: "plus")
                }
                Button { isShowingBulkImport = true } label: {
                    Image(systemName: "list.bullet.clipboard")
                }
                .help("Bulk import plugins")
                Spacer()
                Text("\(store.plugins.count) plugin\(store.plugins.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
        }
        .sheet(isPresented: $isShowingEditor) {
            PluginEditorView(store: store, plugin: nil)
        }
        .sheet(isPresented: $isShowingBulkImport) {
            BulkImportView(store: store)
        }
        .sheet(item: $editingPlugin) { plugin in
            PluginEditorView(store: store, plugin: plugin)
        }
    }
}

private struct PluginRow: View {
    let plugin: PluginShortcut

    var body: some View {
        HStack(spacing: 12) {
            PluginIconView(icon: plugin.icon, size: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(plugin.displayName).font(.body)
                Text(plugin.name).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            if let hotkey = plugin.hotkey {
                Text(hotkey.displayString)
                    .font(.system(.caption, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            }
        }
    }
}

// MARK: - Plugin Icon View

struct PluginIconView: View {
    let icon: PluginShortcut.PluginIcon
    let size: CGFloat

    var body: some View {
        switch icon {
        case .emoji(let emoji):
            Text(emoji).font(.system(size: size * 0.8))
        case .sfSymbol(let name):
            Image(systemName: name).font(.system(size: size * 0.65))
        case .customImage(let filename):
            if let nsImage = IconStorage.loadImage(filename: filename) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
            } else {
                Image(systemName: "photo")
                    .font(.system(size: size * 0.6))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Plugin Editor

struct PluginEditorView: View {
    @ObservedObject var store: PluginStore
    let plugin: PluginShortcut?
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var displayName = ""
    @State private var iconType: IconType = .emoji
    @State private var iconEmoji = "🔌"
    @State private var sfSymbolName = "puzzlepiece.extension"
    @State private var customImageFilename: String?
    @State private var customImagePreview: NSImage?
    @State private var isHotkeyEnabled = false
    @State private var hotkey: PluginShortcut.HotkeyCombo = .default

    private var isEditing: Bool { plugin != nil }

    enum IconType: String, CaseIterable {
        case emoji = "Emoji"
        case sfSymbol = "SF Symbol"
        case customImage = "Custom Image"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(isEditing ? "Edit Plugin" : "Add Plugin")
                .font(.headline)

            Form {
                Section("Plugin Shortcut") {
                    TextField("Shortcut name", text: $name)
                    TextField("Figma plugin or action name", text: $displayName)
                        .help("Friendly name for the dock (defaults to plugin name)")
                }

                Section("Icon") {
                    Picker("Source", selection: $iconType) {
                        ForEach(IconType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    switch iconType {
                    case .emoji:
                        HStack {
                            TextField("Emoji", text: $iconEmoji)
                                .frame(width: 60)
                            Button("Choose Emoji…") {
                                NSApp.orderFrontCharacterPalette(nil)
                            }
                            Spacer()
                            Text(iconEmoji).font(.title)
                        }

                    case .sfSymbol:
                        TextField("SF Symbol icon", text: $sfSymbolName)
                        HStack {
                            Text("Preview")
                            Image(systemName: sfSymbolName)
                                .font(.system(size: 28))
                                .frame(width: 44, height: 44)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
                        }

                    case .customImage:
                        HStack {
                            if let preview = customImagePreview {
                                Image(nsImage: preview)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.quaternary)
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(systemName: "photo").foregroundStyle(.secondary)
                                    }
                            }

                            Button("Choose Image...") { chooseImage() }

                            if customImageFilename != nil {
                                Button("Remove", role: .destructive) {
                                    customImageFilename = nil
                                    customImagePreview = nil
                                }
                            }
                        }
                    }
                }

                Section("Global Hotkey") {
                    Toggle("Enable hotkey", isOn: $isHotkeyEnabled)

                    if isHotkeyEnabled {
                        Picker("Key", selection: $hotkey.keyCode) {
                            ForEach(KeyCodeMap.allKeys, id: \.code) { key in
                                Text(key.name).tag(key.code)
                            }
                        }
                        .frame(width: 100)

                        Toggle("Command", isOn: $hotkey.useCommand)
                        Toggle("Option", isOn: $hotkey.useOption)
                        Toggle("Control", isOn: $hotkey.useControl)
                        Toggle("Shift", isOn: $hotkey.useShift)

                        Text("Current shortcut: \(hotkey.displayString)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(isEditing ? "Save" : "Add") {
                    save()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(width: 440, height: 560)
        .onAppear { loadPlugin() }
    }

    private func loadPlugin() {
        guard let p = plugin else { return }
        name = p.name
        displayName = p.displayName
        isHotkeyEnabled = p.hotkey != nil
        hotkey = p.hotkey ?? .default

        switch p.icon {
        case .emoji(let e):
            iconType = .emoji
            iconEmoji = e
        case .sfSymbol(let s):
            iconType = .sfSymbol
            sfSymbolName = s
        case .customImage(let filename):
            iconType = .customImage
            customImageFilename = filename
            customImagePreview = IconStorage.loadImage(filename: filename)
        }
    }

    private func chooseImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .svg, .image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        let targetID = plugin?.id ?? UUID()
        if let filename = IconStorage.saveImage(from: url, for: targetID) {
            customImageFilename = filename
            customImagePreview = IconStorage.loadImage(filename: filename)
        }
    }

    private func save() {
        let icon: PluginShortcut.PluginIcon
        switch iconType {
        case .emoji: icon = .emoji(iconEmoji)
        case .sfSymbol: icon = .sfSymbol(sfSymbolName)
        case .customImage:
            icon = customImageFilename.map { .customImage($0) } ?? .emoji(iconEmoji)
        }

        if var existing = plugin {
            existing.name = name
            existing.displayName = displayName.isEmpty ? name : displayName
            existing.icon = icon
            existing.hotkey = isHotkeyEnabled ? hotkey : nil
            store.updatePlugin(existing)
        } else {
            store.addPlugin(PluginShortcut(
                name: name,
                displayName: displayName.isEmpty ? nil : displayName,
                icon: icon,
                hotkey: isHotkeyEnabled ? hotkey : nil
            ))
        }
    }
}

// MARK: - Appearance Tab

struct AppearanceTab: View {
    @ObservedObject var store: PluginStore
    @EnvironmentObject private var dockController: DockPanelController

    var body: some View {
        Form {
            Picker("Dock Orientation", selection: $store.settings.dockOrientation) {
                Text("Horizontal").tag(AppSettings.DockOrientation.horizontal)
                Text("Vertical").tag(AppSettings.DockOrientation.vertical)
            }

            Slider(value: $store.settings.iconSize, in: 32...64, step: 4) {
                Text("Icon Size: \(Int(store.settings.iconSize))pt")
            }

            Toggle("Show dock on launch", isOn: $store.settings.showDockOnLaunch)

            Toggle("Always on top", isOn: $store.settings.alwaysOnTop)
                .help("Keep the dock floating above all other windows")
        }
        .formStyle(.grouped)
        .onChange(of: store.settings.dockOrientation) { _, _ in store.save() }
        .onChange(of: store.settings.iconSize) { _, _ in store.save() }
        .onChange(of: store.settings.showDockOnLaunch) { _, _ in store.save() }
        .onChange(of: store.settings.alwaysOnTop) { _, newValue in
            store.save()
            dockController.updateAlwaysOnTop(newValue)
        }
    }
}

// MARK: - Automation Tab

struct AutomationTab: View {
    @ObservedObject var store: PluginStore
    @State private var testResult: String?

    var body: some View {
        Form {
            Section("Timing Delays") {
                DelaySlider(label: "Activation Delay", value: $store.settings.activationDelay, range: 0.1...1.0)
                DelaySlider(label: "Quick Actions Delay", value: $store.settings.commandSlashDelay, range: 0.1...1.0)
                DelaySlider(label: "Typing Delay", value: $store.settings.typingDelay, range: 0.01...0.1)
                DelaySlider(label: "Enter Delay", value: $store.settings.enterDelay, range: 0.1...1.0)
            }

            Section("Accessibility") {
                HStack {
                    Image(systemName: AccessibilityManager.isTrusted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(AccessibilityManager.isTrusted ? .green : .red)
                    Text(AccessibilityManager.isTrusted ? "Accessibility access granted" : "Accessibility access required")
                    Spacer()
                    if !AccessibilityManager.isTrusted {
                        Button("Open Settings") { AccessibilityManager.openSystemSettings() }
                    }
                }
            }

            Section {
                Button("Test Automation") { testAutomation() }
                    .help("Opens Figma Quick Actions and types 'test' — cancel with Escape")

                if let result = testResult {
                    Text(result)
                        .font(.caption)
                        .foregroundStyle(result.contains("✓") ? .green : .red)
                }
            }
        }
        .formStyle(.grouped)
        .onChange(of: store.settings.activationDelay) { _, _ in store.save() }
        .onChange(of: store.settings.commandSlashDelay) { _, _ in store.save() }
        .onChange(of: store.settings.typingDelay) { _, _ in store.save() }
        .onChange(of: store.settings.enterDelay) { _, _ in store.save() }
    }

    private func testAutomation() {
        Task {
            guard AccessibilityManager.isTrusted else {
                testResult = "✗ Accessibility not trusted"
                return
            }
            guard NSWorkspace.shared.runningApplications.contains(where: {
                $0.bundleIdentifier == Constants.figmaBundleID
            }) else {
                testResult = "✗ Figma not running"
                return
            }
            do {
                try await FigmaAutomation(settings: store.settings).launchPlugin(named: "test")
                testResult = "✓ Automation sent successfully"
            } catch {
                testResult = "✗ \(error.localizedDescription)"
            }
        }
    }
}

private struct DelaySlider: View {
    let label: String
    @Binding var value: TimeInterval
    let range: ClosedRange<Double>

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value * 1000))ms")
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        Slider(value: $value, in: range, step: 0.01)
    }
}

// MARK: - Bulk Import

struct BulkImportView: View {
    @ObservedObject var store: PluginStore
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var importedCount = 0

    private var parsedNames: [String] {
        text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private var duplicateCount: Int {
        let existing = Set(store.plugins.map { $0.name.lowercased() })
        return parsedNames.filter { existing.contains($0.lowercased()) }.count
    }

    private var newCount: Int {
        parsedNames.count - duplicateCount
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Bulk Import Plugins")
                .font(.headline)

            Text("Paste plugin names below, one per line. These should match exactly how they appear in Figma's Quick Actions (⌘/).")
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $text)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 200)
                .border(.quaternary)

            HStack {
                if !parsedNames.isEmpty {
                    Text("\(parsedNames.count) plugin\(parsedNames.count == 1 ? "" : "s") found")
                    if duplicateCount > 0 {
                        Text("(\(duplicateCount) already exist)")
                            .foregroundStyle(.orange)
                    }
                }
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if importedCount > 0 {
                Label("Imported \(importedCount) plugin\(importedCount == 1 ? "" : "s")", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Import \(newCount) Plugin\(newCount == 1 ? "" : "s")") {
                    importPlugins()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(newCount == 0)
            }
        }
        .padding()
        .frame(width: 480, height: 420)
    }

    private func importPlugins() {
        let existing = Set(store.plugins.map { $0.name.lowercased() })
        var count = 0

        for name in parsedNames where !existing.contains(name.lowercased()) {
            store.addPlugin(PluginShortcut(name: name))
            count += 1
        }

        importedCount = count
        if count > 0 {
            text = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { dismiss() }
        }
    }
}
