//
//  IdleMonitor.swift
//  IdleDetector
//
//  Reads system-wide human-input idle time from the HID event stream. This is intentionally
//  computer-wide, not scoped to one app: macOS routes input to an app only AFTER the window
//  server picks the frontmost target, while the idle counter sits upstream of that routing —
//  so it can answer "is a human touching this machine right now," never "into which app."
//  No TCC permission is required to read it.
//

import CoreGraphics
import Foundation
import Observation

/// Which event-state table idle time is read from. Both reflect real hardware; they diverge
/// for synthetic input: `.combinedSession` also counts events injected into the session, while
/// `.hidSystem` reflects only the physical devices (synthetic input posted above the HID layer
/// is invisible to it).
enum IdleSource {
    case combinedSession
    case hidSystem

    var stateID: CGEventSourceStateID {
        switch self {
        case .combinedSession: return .combinedSessionState
        case .hidSystem: return .hidSystemState
        }
    }

    /// One-line explanation shown under the toggle.
    var detail: String {
        switch self {
        case .combinedSession: return "combinedSessionState — physical input plus injected/automated input."
        case .hidSystem: return "hidSystemState — physical mouse & keyboard only."
        }
    }
}

@MainActor
@Observable
final class IdleMonitor {
    /// Seconds since the most recent human input of any kind (the lesser of mouse and keyboard).
    private(set) var idleSeconds: Double = 0

    /// Seconds since the last mouse movement, click, drag, or scroll.
    private(set) var mouseIdleSeconds: Double = 0

    /// Seconds since the last key or modifier event.
    private(set) var keyboardIdleSeconds: Double = 0

    /// How long input must be absent before the user is considered idle (seconds).
    var idleThreshold: Double = 60

    /// Which event-state table is queried. Switching it lets you watch synthetic input count
    /// (or not) toward activity in real time.
    var source: IdleSource = .combinedSession

    /// Whether the user is currently considered idle, per `idleThreshold`.
    var isIdle: Bool { idleSeconds >= idleThreshold }

    /// How far the current idle streak has progressed toward the threshold, clamped to 0...1.
    var progressToIdle: Double {
        guard idleThreshold > 0 else { return 0 }
        return min(idleSeconds / idleThreshold, 1)
    }

    private var pollTask: Task<Void, Never>?
    private let sampleInterval = Duration.milliseconds(100)

    /// Mouse-class event types. `secondsSinceLastEventType` is per-type, so we take the minimum
    /// across all of them to get "time since any mouse activity."
    private static let mouseEvents: [CGEventType] = [
        .leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp,
        .mouseMoved, .leftMouseDragged, .rightMouseDragged, .scrollWheel,
        .otherMouseDown, .otherMouseUp, .otherMouseDragged
    ]

    private static let keyboardEvents: [CGEventType] = [.keyDown, .keyUp, .flagsChanged]

    /// Begin polling the HID idle counters. Safe to call repeatedly; a second call is a no-op.
    func start() {
        guard pollTask == nil else { return }
        sample()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: self?.sampleInterval ?? .milliseconds(100))
                } catch {
                    break
                }
                self?.sample()
            }
        }
    }

    /// Stop polling.
    func stop() {
        pollTask?.cancel()
        pollTask = nil
    }

    private func sample() {
        let state = source.stateID
        mouseIdleSeconds = Self.idleTime(state, Self.mouseEvents)
        keyboardIdleSeconds = Self.idleTime(state, Self.keyboardEvents)
        idleSeconds = min(mouseIdleSeconds, keyboardIdleSeconds)
    }

    /// Smallest "seconds since last event" across a set of event types, for the given state table.
    private static func idleTime(_ state: CGEventSourceStateID, _ types: [CGEventType]) -> Double {
        let samples = types.map {
            CGEventSource.secondsSinceLastEventType(state, eventType: $0)
        }
        return samples.min() ?? 0
    }
}
