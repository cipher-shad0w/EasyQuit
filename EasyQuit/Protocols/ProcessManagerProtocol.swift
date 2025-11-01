//
//  ProcessManagerProtocol.swift
//  EasyQuit
//
//  Protocol for managing running applications

import Foundation
import AppKit

/// Protocol for managing running applications and their lifecycle
protocol ProcessManagerProtocol {
    /// Get all currently running applications
    /// - Parameter includeBackground: Whether to include background apps without icons
    func getRunningApplications(includeBackground: Bool) -> [RunningApp]

    /// Terminate an application gracefully
    /// - Parameter app: The running app to terminate
    /// - Returns: True if termination was successful
    @discardableResult
    func terminate(_ app: RunningApp) -> Bool

    /// Force terminate an application
    /// - Parameter app: The running app to force terminate
    /// - Returns: True if termination was successful
    @discardableResult
    func forceTerminate(_ app: RunningApp) -> Bool

    /// Restart an application
    /// - Parameter app: The running app to restart
    /// - Returns: True if restart was successful
    @discardableResult
    func restart(_ app: RunningApp) -> Bool

    /// Show the application in Finder
    /// - Parameter app: The running app to show
    func showInFinder(_ app: RunningApp)
}
