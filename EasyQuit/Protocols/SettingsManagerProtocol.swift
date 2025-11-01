//
//  SettingsManagerProtocol.swift
//  EasyQuit
//
//  Protocol for managing application settings

import Foundation
import Combine

/// Default action for quitting applications
enum DefaultAction: String, CaseIterable, Identifiable, Codable {
    case gracefulQuit = "Graceful Quit"
    case forceQuit = "Force Quit"

    var id: String { rawValue }
}

/// Protocol for managing application settings
protocol SettingsManagerProtocol {
    /// Publisher for update interval changes
    var updateIntervalPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher for default action changes
    var defaultActionPublisher: AnyPublisher<DefaultAction, Never> { get }

    /// Publisher for global shortcut changes
    var globalShortcutPublisher: AnyPublisher<KeyboardShortcut?, Never> { get }

    /// Publisher for showBackgroundApps changes
    var showBackgroundAppsPublisher: AnyPublisher<Bool, Never> { get }

    /// Get the update interval in seconds
    var updateInterval: Double { get set }

    /// Get the default action for quitting apps
    var defaultAction: DefaultAction { get set }

    /// Get the global keyboard shortcut
    var globalShortcut: KeyboardShortcut? { get set }

    /// Get the set of ignored app bundle identifiers
    var ignoredApps: Set<String> { get set }

    /// Whether to show background apps without icons
    var showBackgroundApps: Bool { get set }

    /// Reset all settings to defaults
    func resetToDefaults()
}
