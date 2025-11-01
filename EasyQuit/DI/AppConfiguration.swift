//
//  AppConfiguration.swift
//  EasyQuit
//
//  Application configuration and constants

import Foundation

/// Configuration values for the application
struct AppConfiguration {
    // MARK: - App List

    /// Default update interval for refreshing the app list (in seconds)
    let defaultUpdateInterval: Double = 2.0

    /// Number of columns in the app grid
    let gridColumns: Int = 3

    /// Protected system apps that cannot be quit
    let protectedBundleIdentifiers: Set<String> = [
        "com.apple.finder",
        "com.apple.dock",
        "com.apple.systemuiserver",
        "com.apple.loginwindow",
        "com.apple.WindowManager",
        "com.apple.Spotlight",
    ]

    // MARK: - Settings

    /// Default action for quitting apps
    let defaultAction: DefaultAction = .gracefulQuit

    /// Minimum update interval (in seconds)
    let minUpdateInterval: Double = 0.5

    /// Maximum update interval (in seconds)
    let maxUpdateInterval: Double = 10.0

    // MARK: - UI

    /// Icon size for app icons in the grid
    let appIconSize: CGFloat = 64

    /// Spacing between app icons
    let appIconSpacing: CGFloat = 16

    // MARK: - Logging

    /// App subsystem for logging
    let loggingSubsystem: String = "com.cipher-shadow.EasyQuit"

    // MARK: - Init

    init() {}
}
