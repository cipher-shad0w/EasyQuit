//
//  DIContainer.swift
//  EasyQuit
//
//  Dependency Injection Container

import Foundation

/// Dependency Injection Container for managing app dependencies
final class DIContainer {
    static let shared = DIContainer()

    // MARK: - Services

    private(set) lazy var eventPublisher: EventPublisherProtocol = {
        EventPublisher()
    }()

    private(set) lazy var processManager: ProcessManagerProtocol = {
        ProcessManager()
    }()

    private(set) lazy var settingsManager: SettingsManagerProtocol = {
        SettingsManager(eventPublisher: eventPublisher)
    }()

    private(set) lazy var hotkeyManager: HotkeyManagerProtocol = {
        HotkeyManager()
    }()

    private(set) lazy var appConfiguration: AppConfiguration = {
        AppConfiguration()
    }()

    // MARK: - ViewModels

    func makeAppListViewModel() -> AppListViewModel {
        AppListViewModel(
            processManager: processManager,
            settingsManager: settingsManager,
            eventPublisher: eventPublisher,
            configuration: appConfiguration
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(settingsManager: settingsManager)
    }

    // MARK: - Managers

    func makeMenuBarManager() -> MenuBarManager {
        MenuBarManager(
            hotkeyManager: hotkeyManager,
            settingsManager: settingsManager,
            eventPublisher: eventPublisher,
            makeAppListViewModel: makeAppListViewModel,
            makeSettingsViewModel: makeSettingsViewModel
        )
    }

    // MARK: - Private Init (Singleton)

    private init() {}

    // MARK: - Reset for Testing

    #if DEBUG
    func reset() {
        // Reset all lazy properties by recreating the container
        // This is useful for testing
    }
    #endif
}
