//
//  AppListViewModel.swift
//  EasyQuit
//
//  ViewModel for managing the application list

import AppKit
import Combine
import Foundation

final class AppListViewModel: ObservableObject {
    @Published var runningApps: [RunningApp] = []
    @Published var searchText: String = ""
    @Published var ignoredApps: Set<String> = []
    @Published var includedApps: Set<String> = []

    private let processManager: ProcessManagerProtocol
    private var settingsManager: SettingsManagerProtocol
    private let eventPublisher: EventPublisherProtocol
    private let configuration: AppConfiguration

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let refreshQueue = DispatchQueue(label: "com.easyquit.refreshQueue")
    private var isRefreshing = false

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

    init(
        processManager: ProcessManagerProtocol,
        settingsManager: SettingsManagerProtocol,
        eventPublisher: EventPublisherProtocol,
        configuration: AppConfiguration
    ) {
        self.processManager = processManager
        self.settingsManager = settingsManager
        self.eventPublisher = eventPublisher
        self.configuration = configuration

        // Load ignored and included apps from settings
        self.ignoredApps = settingsManager.ignoredApps
        self.includedApps = settingsManager.includedApps

        setupBindings()
        refreshApps()
        startAutoRefresh()
    }

    deinit {
        timer?.invalidate()
    }

    private func setupBindings() {
        // Subscribe to update interval changes
        settingsManager.updateIntervalPublisher
            .sink { [weak self] interval in
                self?.restartAutoRefresh(with: interval)
            }
            .store(in: &cancellables)

        // Subscribe to ignored apps changes
        settingsManager.ignoredAppsPublisher
            .sink { [weak self] newIgnoredApps in
                guard let self else { return }
                if self.ignoredApps != newIgnoredApps {
                    self.ignoredApps = newIgnoredApps
                }
            }
            .store(in: &cancellables)

        // Subscribe to included apps changes
        settingsManager.includedAppsPublisher
            .sink { [weak self] newIncludedApps in
                guard let self else { return }
                if self.includedApps != newIncludedApps {
                    self.includedApps = newIncludedApps
                    self.refreshApps()
                }
            }
            .store(in: &cancellables)
    }

    private func restartAutoRefresh(with interval: Double) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refreshApps()
        }
    }

    func refreshApps() {
        refreshQueue.async { [weak self] in
            guard let self = self else { return }

            // Prevent concurrent refreshes
            guard !self.isRefreshing else { return }
            self.isRefreshing = true

            // Get regular foreground apps
            let regularApps = self.processManager.getRunningApplications(includeBackground: false)
                .filter { app in
                    // Filter out protected system apps
                    guard let bundleId = app.bundleIdentifier else { return false }
                    return !self.configuration.protectedBundleIdentifiers.contains(bundleId)
                }

            // Get included background apps
            let includedBackgroundApps = self.processManager.getIncludedBackgroundApps(bundleIds: self.includedApps)
                .filter { app in
                    // Filter out protected system apps
                    guard let bundleId = app.bundleIdentifier else { return false }
                    return !self.configuration.protectedBundleIdentifiers.contains(bundleId)
                }

            // Combine both lists
            let allApps = regularApps + includedBackgroundApps

            // Deduplicate apps by process ID and bundle identifier
            var seenPIDs = Set<Int>()
            var seenBundleIds = Set<String>()
            let uniqueApps = allApps.filter { app in
                let pidIsUnique = seenPIDs.insert(app.id).inserted

                // For apps with bundle IDs, also check bundle ID uniqueness
                if let bundleId = app.bundleIdentifier {
                    let bundleIdIsUnique = seenBundleIds.insert(bundleId).inserted
                    return pidIsUnique && bundleIdIsUnique
                }

                return pidIsUnique
            }

            let sortedApps = uniqueApps.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }

            DispatchQueue.main.async {
                self.runningApps = sortedApps
                self.isRefreshing = false
            }
        }
    }

    private func startAutoRefresh() {
        let interval = settingsManager.updateInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.refreshApps()
        }
    }

    func quitApp(_ app: RunningApp, force: Bool = false) {
        let success = force ? processManager.forceTerminate(app) : processManager.terminate(app)

        if success, let bundleId = app.bundleIdentifier {
            eventPublisher.publish(.applicationQuit(bundleId))
        }

        // Refresh after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshApps()
        }
    }

    func restartApp(_ app: RunningApp) {
        let success = processManager.restart(app)

        if success, let bundleId = app.bundleIdentifier {
            eventPublisher.publish(.applicationRestarted(bundleId))
        }

        // Refresh after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshApps()
        }
    }

    func showInFinder(_ app: RunningApp) {
        processManager.showInFinder(app)
    }

    func ignoreApp(_ app: RunningApp) {
        guard let bundleId = app.bundleIdentifier else { return }
        ignoredApps.insert(bundleId)

        // Persist to settings
        settingsManager.ignoredApps = ignoredApps
    }

    func unignoreAll() {
        ignoredApps.removeAll()

        // Persist to settings
        settingsManager.ignoredApps = ignoredApps
    }
}
