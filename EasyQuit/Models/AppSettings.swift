//
//  AppSettings.swift
//  EasyQuit
//
//  Created by cipher-shad0w on 31/10/2025
//

import Foundation
import SwiftUI

// Note: DefaultAction has been moved to SettingsManagerProtocol.swift

struct AppSettings {
    // Keys for UserDefaults
    private enum Keys {
        static let updateInterval = "updateInterval"
        static let defaultAction = "defaultAction"
        static let showForceQuitWarning = "showForceQuitWarning"
        static let showMultipleQuitWarning = "showMultipleQuitWarning"
        static let hideSystemApps = "hideSystemApps"
        static let compactView = "compactView"
        static let showBackgroundApps = "showBackgroundApps"
    }
}
