//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

@testable import The_Bell

final class MockElapsedTimeTracker: ElapsedTimeTracking {
    // MARK: Properties
    var elapsedTime: TimeInterval = 0

    var isTracking = false
    var isPaused = false

    // MARK: Mock/Spy Properties
    var didStart = false
    var didPause = false
    var didResume = false
    var didStop = false
    var didReset = false

    var onTick: (@MainActor @Sendable (TimeInterval) async -> Void)?

    // MARK: Methods
    func startTracking(
        from date: Date,
        onTick: @escaping @MainActor @Sendable (TimeInterval) async -> Void
    ) async {
        self.didStart = true
        self.onTick = onTick
    }

    func startTracking(
        from elapsedTime: TimeInterval,
        onTick: @escaping @MainActor @Sendable (TimeInterval) async -> Void
    ) async {
        self.didStart = true
        self.onTick = onTick
    }

    func pauseTracking() async {
        didPause = true
    }

    func resumeTracking() async {
        didResume = true
    }

    func stopTracking() async {
        didStop = true
    }

    func reset() async {
        didReset = true
    }

    // MARK: Mock Methods
    func setElapsedTime(_ duration: TimeInterval) async {
        elapsedTime = duration
        await onTick?(duration)
    }
}
