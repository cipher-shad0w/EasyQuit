//
//  EventPublisherProtocol.swift
//  EasyQuit
//
//  Type-safe event publishing protocol

import Foundation
import Combine

/// Application events that can be published
enum AppEvent {
    case shortcutChanged(KeyboardShortcut?)
    case settingsChanged
    case applicationQuit(String) // bundle identifier
    case applicationRestarted(String) // bundle identifier
}

/// Protocol for publishing application events
protocol EventPublisherProtocol {
    /// Publisher for application events
    var eventPublisher: AnyPublisher<AppEvent, Never> { get }

    /// Publish an event
    /// - Parameter event: The event to publish
    func publish(_ event: AppEvent)
}
