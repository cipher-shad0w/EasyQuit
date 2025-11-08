//
//  ProcessManager.swift
//  EasyQuit
//
//  Service for managing running applications

import Foundation
import AppKit

/// Service for managing running applications and their lifecycle
final class ProcessManager: ProcessManagerProtocol {
    private let workspace: NSWorkspace

    init(workspace: NSWorkspace = .shared) {
        self.workspace = workspace
    }

    func getRunningApplications(includeBackground: Bool = false) -> [RunningApp] {
        workspace.runningApplications
            .filter { app in
                // Filter based on includeBackground setting
                if includeBackground {
                    // Show all apps including background apps
                    return true
                } else {
                    // Filter out background apps without icons
                    return app.activationPolicy == .regular
                }
            }
            .map { app in
                RunningApp(from: app)
            }
    }

    func getIncludedBackgroundApps(bundleIds: Set<String>) -> [RunningApp] {
        workspace.runningApplications
            .filter { app in
                // Only include apps with matching bundle IDs
                if let bundleId = app.bundleIdentifier {
                    return bundleIds.contains(bundleId)
                }
                return false
            }
            .map { app in
                RunningApp(from: app)
            }
    }

    @discardableResult
    func terminate(_ app: RunningApp) -> Bool {
        app.application.terminate()
    }

    @discardableResult
    func forceTerminate(_ app: RunningApp) -> Bool {
        app.application.forceTerminate()
    }

    @discardableResult
    func restart(_ app: RunningApp) -> Bool {
        guard let bundleURL = app.application.bundleURL else {
            return false
        }

        let wasTerminated = app.application.terminate()
        guard wasTerminated else {
            return false
        }

        // Wait a bit before restarting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }

            let configuration = NSWorkspace.OpenConfiguration()
            self.workspace.openApplication(at: bundleURL, configuration: configuration) { _, error in
                if error != nil {
                    // Failed to restart
                }
            }
        }

        return true
    }

    func showInFinder(_ app: RunningApp) {
        if let bundleURL = app.application.bundleURL {
            workspace.activateFileViewerSelecting([bundleURL])
        }
    }
}
