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
class HotkeyManager {
    private let logger = Logger(subsystem: "com.cipher-shadow.EasyQuit", category: "HotkeyManager")
    private var eventHandler: EventHandlerRef?
    private var eventHotKeyRef: EventHotKeyRef?
    var onHotkeyPressed: (() -> Void)?

    deinit {
        unregisterHotkey()
    }

    /// Registers a global hotkey with the given key code and modifiers
    /// - Parameters:
    ///   - keyCode: The virtual key code (e.g., 0x0E for Command+Space)
    ///   - modifiers: Carbon modifier flags (e.g., cmdKey, shiftKey, optionKey, controlKey)
    /// - Returns: True if registration was successful
    @discardableResult
    func registerHotkey(keyCode: UInt32, modifiers: UInt32) -> Bool {
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

/// Represents a keyboard shortcut with key and modifiers
struct KeyboardShortcut: Codable, Equatable {
    let keyCode: UInt16
    let modifierFlags: UInt

    var displayString: String {
        var parts: [String] = []

        if modifierFlags & UInt(NSEvent.ModifierFlags.control.rawValue) != 0 {
            parts.append("⌃")
        }
        if modifierFlags & UInt(NSEvent.ModifierFlags.option.rawValue) != 0 {
            parts.append("⌥")
        }
        if modifierFlags & UInt(NSEvent.ModifierFlags.shift.rawValue) != 0 {
            parts.append("⇧")
        }
        if modifierFlags & UInt(NSEvent.ModifierFlags.command.rawValue) != 0 {
            parts.append("⌘")
        }

        if let keyString = keyCodeToString(keyCode) {
            parts.append(keyString)
        }

        return parts.joined()
    }

    /// Converts Carbon modifiers to NSEvent.ModifierFlags
    var carbonModifiers: UInt32 {
        var carbonMods: UInt32 = 0

        if modifierFlags & UInt(NSEvent.ModifierFlags.control.rawValue) != 0 {
            carbonMods |= UInt32(controlKey)
        }
        if modifierFlags & UInt(NSEvent.ModifierFlags.option.rawValue) != 0 {
            carbonMods |= UInt32(optionKey)
        }
        if modifierFlags & UInt(NSEvent.ModifierFlags.shift.rawValue) != 0 {
            carbonMods |= UInt32(shiftKey)
        }
        if modifierFlags & UInt(NSEvent.ModifierFlags.command.rawValue) != 0 {
            carbonMods |= UInt32(cmdKey)
        }

        return carbonMods
    }

    private func keyCodeToString(_ keyCode: UInt16) -> String? {
        // Map common key codes to their string representations
        switch Int(keyCode) {
        case 0x00: return "A"
        case 0x0B: return "B"
        case 0x08: return "C"
        case 0x02: return "D"
        case 0x0E: return "E"
        case 0x03: return "F"
        case 0x05: return "G"
        case 0x04: return "H"
        case 0x22: return "I"
        case 0x26: return "J"
        case 0x28: return "K"
        case 0x25: return "L"
        case 0x2E: return "M"
        case 0x2D: return "N"
        case 0x1F: return "O"
        case 0x23: return "P"
        case 0x0C: return "Q"
        case 0x0F: return "R"
        case 0x01: return "S"
        case 0x11: return "T"
        case 0x20: return "U"
        case 0x09: return "V"
        case 0x0D: return "W"
        case 0x07: return "X"
        case 0x10: return "Y"
        case 0x06: return "Z"
        case 0x12: return "1"
        case 0x13: return "2"
        case 0x14: return "3"
        case 0x15: return "4"
        case 0x17: return "5"
        case 0x16: return "6"
        case 0x1A: return "7"
        case 0x1C: return "8"
        case 0x19: return "9"
        case 0x1D: return "0"
        case 0x31: return "Space"
        case 0x24: return "↩"
        case 0x30: return "⇥"
        case 0x33: return "⌫"
        case 0x35: return "⎋"
        case 0x7E: return "↑"
        case 0x7D: return "↓"
        case 0x7B: return "←"
        case 0x7C: return "→"
        case 0x2F: return "."
        case 0x2B: return ","
        case 0x7A: return "F1"
        case 0x78: return "F2"
        case 0x63: return "F3"
        case 0x76: return "F4"
        case 0x60: return "F5"
        case 0x61: return "F6"
        case 0x62: return "F7"
        case 0x64: return "F8"
        case 0x65: return "F9"
        case 0x6D: return "F10"
        case 0x67: return "F11"
        case 0x6F: return "F12"
        default: return nil
        }
    }
}
