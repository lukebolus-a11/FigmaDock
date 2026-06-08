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

## Installation

### From DMG (recommended for team distribution)

1. Download `FigmaDock.dmg` from [Releases](../../releases)
2. Double-click to mount
3. Drag **FigmaDock** into **Applications**
4. Launch FigmaDock — it appears in the menu bar (not the Dock)
5. Grant **Accessibility** permission when prompted (System Settings → Privacy & Security → Accessibility)

> **macOS Gatekeeper note:** Since the app is ad-hoc signed (no Apple Developer ID), you may see _"can't be opened because Apple cannot check it for malicious software"_. To bypass this:
> - **Right-click** the app → **Open**, or
> - Go to **System Settings → Privacy & Security** → click **Open Anyway**
>
> This only needs to be done once.

### Build from source

**Requirements:** macOS 14+, Xcode 15+, [xcodegen](https://github.com/yonaskolb/XcodeGen)

```bash
# Install xcodegen if you don't have it
brew install xcodegen

# Clone and build
git clone https://github.com/lukebolus-a11/FigmaDock.git
cd FigmaDock
xcodegen generate
open FigmaDock.xcodeproj
# Build and run in Xcode (⌘R)
```

### Build a DMG for distribution

```bash
./scripts/build-dmg.sh
# Output: build/FigmaDock.dmg
```

## Usage

1. **Click the menu bar icon** (grid icon) to see your plugins and settings
2. **Add plugins** via Settings → Plugins tab → click **+**
   - Enter the exact plugin name as it appears in Figma's Quick Actions
   - Choose an icon (emoji, SF Symbol, or upload an image)
   - Optionally assign a global hotkey
3. **Click a dock button** or use the menu bar dropdown to launch a plugin
4. **Drag the dock** to reposition it on screen
5. **Adjust timing** in Settings → Automation if plugins aren't launching reliably

## Settings

| Tab | What it controls |
|-----|-----------------|
| **Plugins** | Add, edit, remove, and reorder plugin shortcuts |
| **Appearance** | Dock orientation (horizontal/vertical), icon size, always-on-top, show on launch |
| **Automation** | Timing delays (activation, quick actions, typing, enter), accessibility status, test button |

## Project Structure

```
FigmaDock/
├── Models/
│   ├── PluginShortcut.swift      # Plugin data model with icon and hotkey support
│   └── AppSettings.swift         # App preferences (delays, appearance, etc.)
├── Store/
│   └── PluginStore.swift         # JSON persistence for plugins and settings
├── Automation/
│   ├── FigmaAutomation.swift     # Core automation sequence
│   ├── KeySimulator.swift        # CGEvent keystroke simulation
│   └── AccessibilityManager.swift # macOS Accessibility permission handling
├── Hotkeys/
│   └── GlobalHotkeyManager.swift # Carbon global hotkey registration
├── Views/
│   ├── DockPanel.swift           # NSPanel subclass (floating, non-activating)
│   ├── DockView.swift            # SwiftUI dock strip with icon buttons
│   ├── MenuBarView.swift         # Menu bar dropdown
│   ├── SettingsView.swift        # Preferences window (tabbed)
│   └── AccessibilityPromptView.swift
├── Utilities/
│   ├── Constants.swift           # App constants and paths
│   └── IconStorage.swift         # Custom icon image storage
├── FigmaDockApp.swift            # App entry point
├── Info.plist                    # LSUIElement (menu bar only app)
└── FigmaDock.entitlements        # No sandbox (required for Accessibility)
```

## Requirements

- macOS 14 (Sonoma) or later
- Figma desktop app
- Accessibility permission (granted on first launch)

## License

Internal tool — not for public distribution.
