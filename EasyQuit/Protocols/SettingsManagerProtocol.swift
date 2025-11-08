//
//  SettingsManagerProtocol.swift
//  EasyQuit
//
//  Protocol for managing application settings

import Foundation
import Combine

/// Protocol for managing application settings
protocol SettingsManagerProtocol {
    /// Publisher for update interval changes
    var updateIntervalPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher for global shortcut changes
    var globalShortcutPublisher: AnyPublisher<KeyboardShortcut?, Never> { get }

    /// Publisher for ignored apps changes
    var ignoredAppsPublisher: AnyPublisher<Set<String>, Never> { get }

    /// Publisher for included apps changes
    var includedAppsPublisher: AnyPublisher<Set<String>, Never> { get }

    /// Get the update interval in seconds
    var updateInterval: Double { get set }

    /// Get the global keyboard shortcut
    var globalShortcut: KeyboardShortcut? { get set }

    /// Get the set of ignored app bundle identifiers
    var ignoredApps: Set<String> { get set }

    /// Get the set of included app bundle identifiers
    var includedApps: Set<String> { get set }

    /// Reset all settings to defaults
    func resetToDefaults()
}
