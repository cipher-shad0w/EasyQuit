//
//  EventPublisher.swift
//  EasyQuit
//
//  Type-safe event publishing service

import Foundation
import Combine

/// Service for publishing application events in a type-safe manner
final class EventPublisher: EventPublisherProtocol {
    private let eventSubject = PassthroughSubject<AppEvent, Never>()

    var eventPublisher: AnyPublisher<AppEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    func publish(_ event: AppEvent) {
        eventSubject.send(event)
    }
}
