//
//  SettingsViewModel.swift
//  EasyQuit
//
//  ViewModel for settings management

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var updateInterval: Double {
        didSet {
            if updateInterval != settingsManager.updateInterval {
                settingsManager.updateInterval = updateInterval
            }
        }
    }

    @Published var globalShortcut: KeyboardShortcut? {
        didSet {
            if globalShortcut != settingsManager.globalShortcut {
                settingsManager.globalShortcut = globalShortcut
            }
        }
    }

    private var settingsManager: SettingsManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(settingsManager: SettingsManagerProtocol) {
        self.settingsManager = settingsManager

        // Initialize from settings manager
        self.updateInterval = settingsManager.updateInterval
        self.globalShortcut = settingsManager.globalShortcut

        // Subscribe to external changes
        setupBindings()
    }

    private func setupBindings() {
        settingsManager.updateIntervalPublisher
            .sink { [weak self] newValue in
                guard let self, self.updateInterval != newValue else { return }
                self.updateInterval = newValue
            }
            .store(in: &cancellables)

        settingsManager.globalShortcutPublisher
            .sink { [weak self] newValue in
                guard let self else { return }
                // Compare optionals properly
                if (self.globalShortcut == nil && newValue != nil) ||
                   (self.globalShortcut != nil && newValue == nil) ||
                   (self.globalShortcut != newValue) {
                    self.globalShortcut = newValue
                }
            }
            .store(in: &cancellables)
    }

    func resetToDefaults() {
        settingsManager.resetToDefaults()
    }
}
