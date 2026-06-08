# FigmaDock

A native macOS menu bar app for launching Figma plugins with a single click. No more digging through Figma's menus — just click a button or press a hotkey.

## Features

- **Floating dock** — draggable, always-on-top strip of plugin buttons that stays above all windows
- **Menu bar dropdown** — access all your plugins from the macOS menu bar
- **Custom icons** — emoji, SF Symbols, or upload your own PNG/JPEG/SVG images
- **Global hotkeys** — assign keyboard shortcuts (e.g. ⌥⌘1) to launch plugins from anywhere
- **Configurable timing** — adjustable delays for different Figma setups
- **Always on top** — toggle to keep the dock floating above other windows
- **Unlimited plugins** — add as many shortcuts as you need
- **Drag to reorder** — rearrange plugins in the settings

## How It Works

FigmaDock automates a simple sequence using macOS Accessibility:

1. Brings the Figma desktop app to the foreground
2. Opens Quick Actions (⌘/)
3. Types the plugin name
4. Presses Enter to launch it

## Quick Start (Install the DMG)

The fastest way to get running — no Xcode or command line needed.

1. Go to [**Releases**](../../releases) and download **FigmaDock.dmg**
2. Double-click the DMG to mount it
3. Drag **FigmaDock** into the **Applications** folder
4. Open **FigmaDock** from Applications — it appears in the **menu bar** (not the Dock)
5. Grant **Accessibility** permission when prompted:
   - System Settings → Privacy & Security → Accessibility → enable FigmaDock

### First launch — Gatekeeper warning

Since the app is ad-hoc signed (no Apple Developer ID), macOS may show:

> _"FigmaDock can't be opened because Apple cannot check it for malicious software"_

To fix this (one-time only):
- **Right-click** FigmaDock.app → click **Open**, then click **Open** again in the dialog
- Or: System Settings → Privacy & Security → scroll down → click **Open Anyway**

## Usage

1. **Click the menu bar icon** (grid icon) to see your plugins and access settings
2. **Add plugins** — menu bar → Settings → Plugins tab → click **+**
   - **Shortcut name**: this is the label you see in the dock
   - **Figma plugin or action name**: the exact text Figma uses in Quick Actions (⌘/)
   - **Icon**: choose emoji, SF Symbol, or upload a custom image
   - **Global hotkey** (optional): assign a keyboard shortcut like ⌥⌘1
3. **Launch a plugin** — click its button in the floating dock, or use the menu bar dropdown, or press its hotkey
4. **Drag the dock** anywhere on screen to reposition it
5. **Gear icon** in the dock opens Settings directly
6. **Adjust timing** in Settings → Automation if plugins aren't launching reliably (increase delays for slower machines)

## Settings

| Tab | What it controls |
|-----|-----------------|
| **Plugins** | Add, edit, remove, and reorder plugin shortcuts. Double-click to edit. |
| **Appearance** | Dock orientation (horizontal/vertical), icon size, always-on-top, show on launch |
| **Automation** | Timing delays, accessibility permission status, test automation button |

## Build from Source

If you want to modify FigmaDock or build it yourself.

### Prerequisites

- macOS 14 (Sonoma) or later
- Xcode 15+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Clone and run

```bash
git clone https://github.com/lukebolus-a11/FigmaDock.git
cd FigmaDock
xcodegen generate        # generates FigmaDock.xcodeproj from project.yml
open FigmaDock.xcodeproj # open in Xcode
# Press ⌘R to build and run
```

### Build a DMG for distribution

```bash
./scripts/build-dmg.sh
# Creates build/FigmaDock.dmg ready to share
```

## Contributing (Internal Team)

### Branching

```bash
# Create a feature branch
git checkout -b feature/my-new-thing

# Make changes, then commit
git add -A
git commit -m "Add my new thing"

# Push your branch
git push -u origin feature/my-new-thing

# Open a PR on GitHub
gh pr create --title "Add my new thing" --body "Description of changes"
```

### After pulling changes

The Xcode project file is gitignored (it's generated). After pulling, regenerate it:

```bash
xcodegen generate
```

Then open `FigmaDock.xcodeproj` as normal.

## Project Structure

```
FigmaDock/
├── Models/
│   ├── PluginShortcut.swift        # Plugin data model (name, icon, hotkey)
│   └── AppSettings.swift           # Preferences (delays, appearance)
├── Store/
│   └── PluginStore.swift           # JSON persistence (~/.config/FigmaDock/)
├── Automation/
│   ├── FigmaAutomation.swift       # Core: activate Figma → ⌘/ → type → Enter
│   ├── KeySimulator.swift          # CGEvent keystroke posting
│   └── AccessibilityManager.swift  # macOS Accessibility permission
├── Hotkeys/
│   └── GlobalHotkeyManager.swift   # Carbon global hotkey registration
├── Views/
│   ├── DockPanel.swift             # Floating NSPanel (non-activating, always-on-top)
│   ├── DockView.swift              # SwiftUI dock strip with icon buttons + gear
│   ├── MenuBarView.swift           # Menu bar dropdown
│   ├── SettingsView.swift          # Tabbed preferences (Plugins, Appearance, Automation)
│   └── AccessibilityPromptView.swift
├── Utilities/
│   ├── Constants.swift             # Bundle IDs, file paths
│   └── IconStorage.swift           # Custom icon image storage
├── FigmaDockApp.swift              # @main app entry point
├── Info.plist                      # LSUIElement = true (menu bar only)
├── FigmaDock.entitlements          # App Sandbox disabled (required for Accessibility)
├── project.yml                     # XcodeGen project definition
└── scripts/
    └── build-dmg.sh                # Builds release DMG for distribution
```

## Requirements

- macOS 14 (Sonoma) or later
- Figma desktop app (must be running)
- Accessibility permission

## License

Internal tool — Monzo team use only.
