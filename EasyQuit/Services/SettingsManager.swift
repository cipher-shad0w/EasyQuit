//
//  SettingsManager.swift
//  EasyQuit
//
//  Service for managing application settings

import Foundation
import Combine

/// Service for managing application settings with UserDefaults
final class SettingsManager: SettingsManagerProtocol {
    // MARK: - Keys

    private enum Keys {
        static let updateInterval = "updateInterval"
        static let defaultAction = "defaultAction"
        static let globalShortcut = "globalShortcut"
        static let ignoredApps = "ignoredApps"
        static let showBackgroundApps = "showBackgroundApps"
    }

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let eventPublisher: EventPublisherProtocol?

    private let updateIntervalSubject = CurrentValueSubject<Double, Never>(2.0)
    private let defaultActionSubject = CurrentValueSubject<DefaultAction, Never>(.gracefulQuit)
    private let globalShortcutSubject = CurrentValueSubject<KeyboardShortcut?, Never>(nil)
    private let showBackgroundAppsSubject = CurrentValueSubject<Bool, Never>(false)

    var updateIntervalPublisher: AnyPublisher<Double, Never> {
        updateIntervalSubject.eraseToAnyPublisher()
    }

    var defaultActionPublisher: AnyPublisher<DefaultAction, Never> {
        defaultActionSubject.eraseToAnyPublisher()
    }

    var globalShortcutPublisher: AnyPublisher<KeyboardShortcut?, Never> {
        globalShortcutSubject.eraseToAnyPublisher()
    }

    var showBackgroundAppsPublisher: AnyPublisher<Bool, Never> {
        showBackgroundAppsSubject.eraseToAnyPublisher()
    }

    // MARK: - Settings Properties

    var updateInterval: Double {
        get {
            let value = userDefaults.double(forKey: Keys.updateInterval)
            return value > 0 ? value : 2.0
        }
        set {
            userDefaults.set(newValue, forKey: Keys.updateInterval)
            updateIntervalSubject.send(newValue)
        }
    }

    var defaultAction: DefaultAction {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.defaultAction),
                  let action = DefaultAction(rawValue: rawValue) else {
                return .gracefulQuit
            }
            return action
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.defaultAction)
            defaultActionSubject.send(newValue)
        }
    }

    var globalShortcut: KeyboardShortcut? {
        get {
            guard let data = userDefaults.data(forKey: Keys.globalShortcut),
                  let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) else {
                return nil
            }
            return shortcut
        }
        set {
            if let shortcut = newValue {
                if let data = try? JSONEncoder().encode(shortcut) {
                    userDefaults.set(data, forKey: Keys.globalShortcut)
                }
            } else {
                userDefaults.removeObject(forKey: Keys.globalShortcut)
            }
            globalShortcutSubject.send(newValue)
            eventPublisher?.publish(.shortcutChanged(newValue))
        }
    }

    var ignoredApps: Set<String> {
        get {
            let array = userDefaults.stringArray(forKey: Keys.ignoredApps) ?? []
            return Set(array)
        }
        set {
            userDefaults.set(Array(newValue), forKey: Keys.ignoredApps)
        }
    }

    var showBackgroundApps: Bool {
        get {
            userDefaults.bool(forKey: Keys.showBackgroundApps)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.showBackgroundApps)
            showBackgroundAppsSubject.send(newValue)
        }
    }

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard, eventPublisher: EventPublisherProtocol? = nil) {
        self.userDefaults = userDefaults
        self.eventPublisher = eventPublisher

        // Load initial values
        updateIntervalSubject.send(updateInterval)
        defaultActionSubject.send(defaultAction)
        globalShortcutSubject.send(globalShortcut)
        showBackgroundAppsSubject.send(showBackgroundApps)
    }

    // MARK: - Methods

    func resetToDefaults() {
        updateInterval = 2.0
        defaultAction = .gracefulQuit
        globalShortcut = nil
        ignoredApps = []
    }
}
