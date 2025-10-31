# EasyQuit

<div align="center">

![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

A lightweight and efficient macOS menu bar application for quickly quitting running applications with ease.

</div>

---

## Overview

**EasyQuit** is a simple yet powerful menu bar utility designed to help macOS users quickly manage and quit running applications. With an intuitive interface, keyboard shortcuts, and multiple quit options, EasyQuit streamlines the process of closing applications that you no longer need.

## Features

### Core Functionality
- **Menu Bar Integration**: Lives in your menu bar, always accessible with a single click
- **Grid View Interface**: Visual grid display of running applications with app icons
- **Smart Search**: Real-time search bar to quickly find applications
- **Keyboard Navigation**: Full keyboard support for hands-free operation
  - Arrow keys (↑↓←→) to navigate between apps
  - Enter to quit selected app
  - Escape to return to search
- **Global Hotkey**: Customizable system-wide keyboard shortcut to toggle the app
- **Multiple Quit Options**:
  - **Double-click**: Gracefully quit an application (normal quit)
  - **Right-click Menu**: Additional options including Force Quit
- **Auto-Refresh**: Running apps list automatically updates every 2 seconds
- **Protected System Apps**: System-critical apps (Finder, Dock, etc.) are hidden from the list

### Context Menu Actions
Right-click on any app to access additional options:
- **Quit**: Gracefully terminate the application
- **Force Quit**: Force-terminate unresponsive applications
- **Restart**: Quit and immediately relaunch the application
- **Show in Finder**: Reveal the application's location in Finder
- **Ignore**: Temporarily hide an app from the list

### Visual Features
- **Dark/Light Mode**: Automatically adapts to system appearance settings
- **Smooth Animations**: Fluid transitions when apps are added or removed
- **Clean Interface**: Minimalist design focused on functionality
- **3-Column Grid Layout**: Shows up to 6 apps at once with smooth scrolling

### Settings
Access settings via right-click on the menu bar icon:
- **Global Keyboard Shortcut**: Configure custom hotkey to open/close EasyQuit
- **Display Preferences**: Customize how apps are displayed
- **Update Interval**: Adjust how often the app list refreshes

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode 13.0+ (for building from source)

## Installation

### Using Homebrew (Recommended)

The easiest way to install EasyQuit is via Homebrew:

```bash
brew install cipher-shad0w/easyquit/easyquit
```

Then launch EasyQuit from Applications or Spotlight.

### Download Pre-built App

1. Download the latest release from the [Releases](https://github.com/cipher-shad0w/EasyQuit/releases) page
2. Open the downloaded `.dmg` file
3. Drag **EasyQuit** to your Applications folder
4. Launch EasyQuit from Applications
5. Grant necessary permissions when prompted (Accessibility access may be required)

### Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/cipher-shad0w/EasyQuit.git
   cd EasyQuit
   ```

2. Open the project in Xcode:
   ```bash
   open EasyQuit.xcodeproj
   ```

3. Select the **EasyQuit** scheme and your target device
4. Build and run (⌘R)

## Usage

### Basic Operations

1. **Launch EasyQuit**: The app icon (power symbol) appears in your menu bar
2. **Open Interface**: Click the menu bar icon to display the app list
3. **Search**: Start typing to filter applications
4. **Navigate**: Use arrow keys to select an app
5. **Quit App**: Press Enter or double-click on an app to quit it

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Navigate Up | ↑ |
| Navigate Down | ↓ |
| Navigate Left | ← |
| Navigate Right | → |
| Quit Selected App | Enter ↵ |
| Return to Search | Esc |
| Clear Search | ⌘⌫ (when in search field) |
| Toggle EasyQuit | Customizable (set in Settings) |

### Context Menu Operations

1. **Right-click** on the menu bar icon:
   - **Settings...**: Open settings window
   - **Quit EasyQuit**: Exit the application

2. **Right-click** on any app in the list:
   - **Quit**: Normal termination
   - **Force Quit**: Force-terminate the app
   - **Restart**: Quit and relaunch
   - **Show in Finder**: Open app location
   - **Ignore**: Hide from list (temporarily)

## Permissions

EasyQuit may request the following permissions:
- **Accessibility**: Required for global keyboard shortcuts
- **Automation**: Needed to quit other applications

These permissions can be granted in **System Settings > Privacy & Security**.

## Development

### Project Structure

```
EasyQuit/
├── EasyQuit/
│   ├── Models/
│   │   ├── AppSettings.swift      # Settings data model
│   │   └── RunningApp.swift       # Running app representation
│   ├── ViewModels/
│   │   └── AppListViewModel.swift # Core business logic
│   ├── Views/
│   │   ├── ContentView.swift      # Main popover interface
│   │   ├── AppRow.swift           # Individual app row view
│   │   ├── SettingsView.swift     # Settings window
│   │   └── ShortcutRecorderView.swift # Shortcut configuration
│   ├── EasyQuitApp.swift          # App entry point
│   ├── MenuBarManager.swift       # Menu bar integration
│   └── HotkeyManager.swift        # Global hotkey handling
├── EasyQuitTests/
└── EasyQuitUITests/
```

### Technologies Used

- **Swift**: Primary programming language
- **SwiftUI**: UI framework
- **AppKit**: macOS-specific functionality
- **Combine**: Reactive programming
- **Carbon**: Global hotkey registration

### Building

```bash
# Clean build
xcodebuild clean -scheme EasyQuit

# Build for release
xcodebuild -scheme EasyQuit -configuration Release

# Run tests
xcodebuild test -scheme EasyQuit
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m '✨ Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## Known Issues

- Global hotkey registration may fail if the chosen shortcut is already in use by another application
- Force quit may not work on some protected system processes

## License

This project is open source. See the LICENSE file for details.

## Acknowledgments

- Built with ❤️ by [cipher-shad0w](https://github.com/cipher-shad0w)
- Inspired by the need for a faster way to manage running applications on macOS

## Support

If you encounter any issues or have questions:
- Open an issue on [GitHub Issues](https://github.com/cipher-shad0w/EasyQuit/issues)
- Check existing issues for solutions

