//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

@testable import The_Bell

final class MockRoundCountdownTimer: RoundCountdownTimeManagement {
    // MARK: Properties
    var remainingDuration: TimeInterval = 0
    var isCountingDown = false
    var isPaused = false

    // MARK: Mock/Spy Properties
    var didStartCountdown = false
    var didPause = false
    var didResume = false
    var didStop = false
    var didReset = false

    var onTick: (@MainActor @Sendable (TimeInterval) async -> Void)?

    // MARK: Methods
    func start(
        with duration: TimeInterval,
        onTick: @escaping @MainActor @Sendable (TimeInterval) async -> Void
    ) async {
        self.didStartCountdown = true
        self.onTick = onTick
    }

    func pause() async {
        didPause = true
    }

    func resume() async {
        didResume = true
    }

    func stop() async {
        didStop = true
    }

    func reset() async {
        didReset = true
    }

    // MARK: Mock Methods
    func setDuration(_ duration: TimeInterval) async {
        remainingDuration = duration
        await onTick?(duration)
    }
}
