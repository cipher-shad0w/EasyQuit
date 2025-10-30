//
//  RunningApp.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import AppKit
import Foundation

struct RunningApp: Identifiable, Hashable {
    let id: Int
    let name: String
    let bundleIdentifier: String?
    let icon: NSImage?
    let application: NSRunningApplication

    init(from runningApp: NSRunningApplication) {
        self.id = Int(runningApp.processIdentifier)
        self.name = runningApp.localizedName ?? "Unknown"
        self.bundleIdentifier = runningApp.bundleIdentifier
        self.icon = runningApp.icon
        self.application = runningApp
    }

    static func == (lhs: RunningApp, rhs: RunningApp) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
