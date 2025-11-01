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
    private var menuBarManager: MenuBarManager?
    private let logger = Logger(subsystem: "com.cipher-shadow.EasyQuit", category: "AppDelegate")
    private let container = DIContainer.shared

    func applicationDidFinishLaunching(_: Notification) {
        logger.info("Application did finish launching")
        logger.info("Bootstrapping DI container and creating MenuBarManager...")

        // Bootstrap the app with dependency injection
        menuBarManager = container.makeMenuBarManager()

        logger.info("MenuBarManager created: \(self.menuBarManager != nil)")
        logger.info("Setup complete - MVVM + DI architecture initialized")
    }

    func applicationWillTerminate(_: Notification) {
        logger.info("Application will terminate")
    }
}
