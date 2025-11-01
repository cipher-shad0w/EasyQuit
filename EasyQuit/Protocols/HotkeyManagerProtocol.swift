//
//  HotkeyManagerProtocol.swift
//  EasyQuit
//
//  Protocol for managing global hotkeys

import Foundation

/// Protocol for managing global keyboard shortcuts
protocol HotkeyManagerProtocol {
    /// Callback invoked when the registered hotkey is pressed
    var onHotkeyPressed: (() -> Void)? { get set }

    /// Register a global hotkey
    /// - Parameter shortcut: The keyboard shortcut to register
    /// - Returns: True if registration was successful
    @discardableResult
    func registerHotkey(_ shortcut: KeyboardShortcut) -> Bool

    /// Unregister the currently registered hotkey
    func unregisterHotkey()

    /// Check if a hotkey is currently registered
    var isHotkeyRegistered: Bool { get }
}
