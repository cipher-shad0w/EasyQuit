//
//  EasyQuitApp.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import os.log
import SwiftUI

@main
struct EasyQuitApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager?
    private let logger = Logger(subsystem: "com.cipher-shadow.EasyQuit", category: "AppDelegate")

    func applicationDidFinishLaunching(_: Notification) {
        logger.info("Application did finish launching")
        logger.info("Creating MenuBarManager...")

        menuBarManager = MenuBarManager()

        logger.info("MenuBarManager created: \(self.menuBarManager != nil)")
        logger.info("Setup complete")
    }

    func applicationWillTerminate(_: Notification) {
        logger.info("Application will terminate")
    }
}
