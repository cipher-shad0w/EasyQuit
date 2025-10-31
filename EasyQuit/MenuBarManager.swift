//
//  MenuBarManager.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import AppKit
import os.log
import SwiftUI

class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var settingsWindow: NSWindow?
    private let logger = Logger(subsystem: "com.cipher-shadow.EasyQuit", category: "MenuBarManager")
    private let hotkeyManager = HotkeyManager()

    override init() {
        super.init()
        logger.info("MenuBarManager init started")
        setupMenuBar()
        setupHotkey()
        observeShortcutChanges()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupMenuBar() {
        logger.info("Setting up menu bar")

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        logger.info("Status item created: \(self.statusItem != nil)")

        if let button = statusItem?.button {
            logger.info("Status button found, setting image")
            button.image = NSImage(systemSymbolName: "power", accessibilityDescription: "EasyQuit")
            button.action = #selector(handleClick(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            logger.info("Button image set: \(button.image != nil)")
        } else {
            logger.error("Failed to get status item button")
        }

        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 245)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        logger.info("Popover created and configured")
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            logger.info("Right click detected, showing menu")
            showContextMenu()
        } else {
            logger.info("Left click detected, toggling popover")
            togglePopover()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        // Settings menu item
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit menu item
        let quitItem = NSMenuItem(
            title: "Quit EasyQuit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        // Show menu
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func openSettings() {
        logger.info("Opening settings")

        // Close popover if open
        if popover?.isShown == true {
            popover?.performClose(nil)
        }

        // If settings window already exists, bring it to front
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create settings window
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Activate app to bring window to front
        NSApp.activate(ignoringOtherApps: true)

        settingsWindow = window
        logger.info("Settings window created and shown")
    }

    @objc private func quitApp() {
        logger.info("Quitting application")
        NSApp.terminate(nil)
    }

    private func togglePopover() {
        logger.info("Toggle popover called")
        guard let popover else {
            logger.error("Popover is nil")
            return
        }

        if popover.isShown {
            logger.info("Closing popover")
            popover.performClose(nil)
        } else {
            logger.info("Opening popover")
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                logger.info("Popover shown")

                // Activate the app to ensure the popover gets focus
                NSApp.activate(ignoringOtherApps: true)
            } else {
                logger.error("Status button is nil")
            }
        }
    }

    // MARK: - Hotkey Management

    private func setupHotkey() {
        logger.info("Setting up hotkey")

        // Load saved shortcut from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "globalShortcut"),
           let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) {
            registerHotkey(shortcut)
        }

        // Set up hotkey action
        hotkeyManager.onHotkeyPressed = { [weak self] in
            DispatchQueue.main.async {
                self?.togglePopover()
            }
        }
    }

    private func observeShortcutChanges() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("GlobalShortcutChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let shortcut = notification.userInfo?["shortcut"] as? KeyboardShortcut {
                self?.registerHotkey(shortcut)
            } else {
                self?.hotkeyManager.unregisterHotkey()
                self?.logger.info("Hotkey unregistered")
            }
        }
    }

    private func registerHotkey(_ shortcut: KeyboardShortcut) {
        logger.info("Registering hotkey: \(shortcut.displayString)")
        let success = hotkeyManager.registerHotkey(
            keyCode: UInt32(shortcut.keyCode),
            modifiers: shortcut.carbonModifiers
        )
        if success {
            logger.info("Hotkey registered successfully: \(shortcut.displayString)")
        } else {
            logger.error("Failed to register hotkey: \(shortcut.displayString)")
        }
    }
}
