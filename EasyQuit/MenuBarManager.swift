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
    private let logger = Logger(subsystem: "com.cipher-shadow.EasyQuit", category: "MenuBarManager")

    override init() {
        super.init()
        logger.info("MenuBarManager init started")
        setupMenuBar()
    }

    private func setupMenuBar() {
        logger.info("Setting up menu bar")

        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        logger.info("Status item created: \(statusItem != nil)")

        if let button = statusItem?.button {
            logger.info("Status button found, setting image")
            button.image = NSImage(systemSymbolName: "power", accessibilityDescription: "EasyQuit")
            button.action = #selector(togglePopover)
            button.target = self
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

    @objc private func togglePopover() {
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
            } else {
                logger.error("Status button is nil")
            }
        }
    }
}
