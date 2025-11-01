//
//  HotkeyManager.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 31/10/2025
//

import AppKit
import Carbon
import os.log

/// Manages global keyboard shortcuts for the application
final class HotkeyManager: HotkeyManagerProtocol {
    private let logger = Logger(subsystem: "com.cipher-shadow.EasyQuit", category: "HotkeyManager")
    private var eventHandler: EventHandlerRef?
    private var eventHotKeyRef: EventHotKeyRef?
    var onHotkeyPressed: (() -> Void)?

    var isHotkeyRegistered: Bool {
        eventHotKeyRef != nil
    }

    deinit {
        unregisterHotkey()
    }

    /// Registers a global hotkey from a KeyboardShortcut
    /// - Parameter shortcut: The keyboard shortcut to register
    /// - Returns: True if registration was successful
    @discardableResult
    func registerHotkey(_ shortcut: KeyboardShortcut) -> Bool {
        registerHotkey(keyCode: UInt32(shortcut.keyCode), modifiers: shortcut.carbonModifiers)
    }

    /// Registers a global hotkey with the given key code and modifiers
    /// - Parameters:
    ///   - keyCode: The virtual key code (e.g., 0x0E for Command+Space)
    ///   - modifiers: Carbon modifier flags (e.g., cmdKey, shiftKey, optionKey, controlKey)
    /// - Returns: True if registration was successful
    @discardableResult
    private func registerHotkey(keyCode: UInt32, modifiers: UInt32) -> Bool {
        logger.info("Registering hotkey with keyCode: \(keyCode), modifiers: \(modifiers)")

        // Unregister any existing hotkey first
        unregisterHotkey()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))

        // Install event handler
        let status = InstallEventHandler(GetApplicationEventTarget(), { _, event, userData -> OSStatus in
            guard let userData = userData else { return OSStatus(eventNotHandledErr) }

            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.logger.info("Hotkey pressed!")
            manager.onHotkeyPressed?()

            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)

        if status != noErr {
            logger.error("Failed to install event handler: \(status)")
            return false
        }

        // Register the hotkey
        var hotKeyID = EventHotKeyID(signature: OSType(0x4B455946), id: 1) // 'KEYF'
        let registerStatus = RegisterEventHotKey(keyCode,
                                                 modifiers,
                                                 hotKeyID,
                                                 GetApplicationEventTarget(),
                                                 0,
                                                 &eventHotKeyRef)

        if registerStatus != noErr {
            logger.error("Failed to register hotkey: \(registerStatus)")
            if let handler = eventHandler {
                RemoveEventHandler(handler)
                eventHandler = nil
            }
            return false
        }

        logger.info("Hotkey registered successfully")
        return true
    }

    /// Unregisters the current global hotkey
    func unregisterHotkey() {
        if let hotKeyRef = eventHotKeyRef {
            logger.info("Unregistering hotkey")
            UnregisterEventHotKey(hotKeyRef)
            eventHotKeyRef = nil
        }

        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}
