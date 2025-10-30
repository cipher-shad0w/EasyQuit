//
//  AppListViewModel.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 30/10/2025
//

import Foundation
import AppKit
import Combine

class AppListViewModel: ObservableObject {
    @Published var runningApps: [RunningApp] = []
    @Published var searchText: String = ""
    @Published var ignoredApps: Set<String> = []

    private var timer: Timer?
    private var workspace = NSWorkspace.shared

    // System apps that should be hidden
    private let protectedBundleIdentifiers = [
        "com.apple.finder",
        "com.apple.systemuiserver",
        "com.apple.dock",
        "com.apple.loginwindow",
        "com.apple.WindowManager"
    ]

    var filteredApps: [RunningApp] {
        let apps = runningApps.filter { app in
            // Filter out ignored apps
            guard let bundleId = app.bundleIdentifier else { return true }
            return !ignoredApps.contains(bundleId)
        }

        if searchText.isEmpty {
            return apps
        }
        return apps.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        refreshApps()
        startAutoRefresh()
    }

    deinit {
        timer?.invalidate()
    }

    func refreshApps() {
        let apps = workspace.runningApplications
            .filter { app in
                // Filter out background apps and protected system apps
                guard app.activationPolicy == .regular else { return false }
                guard let bundleId = app.bundleIdentifier else { return false }
                return !protectedBundleIdentifiers.contains(bundleId)
            }
            .map { RunningApp(from: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        DispatchQueue.main.async {
            self.runningApps = apps
        }
    }

    private func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.refreshApps()
        }
    }

    func quitApp(_ app: RunningApp, force: Bool = false) {
        if force {
            app.application.forceTerminate()
        } else {
            app.application.terminate()
        }

        // Refresh after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshApps()
        }
    }

    func restartApp(_ app: RunningApp) {
        guard let bundleURL = app.application.bundleURL else { return }

        // Terminate the app first
        app.application.terminate()

        // Relaunch after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            NSWorkspace.shared.openApplication(at: bundleURL, configuration: NSWorkspace.OpenConfiguration())
            self.refreshApps()
        }
    }

    func showInFinder(_ app: RunningApp) {
        guard let bundleURL = app.application.bundleURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([bundleURL])
    }

    func ignoreApp(_ app: RunningApp) {
        guard let bundleId = app.bundleIdentifier else { return }
        ignoredApps.insert(bundleId)
    }

    func unignoreAll() {
        ignoredApps.removeAll()
    }
}
