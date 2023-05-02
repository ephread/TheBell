//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

// MARK: - Protocols
@MainActor
/// Tracks the remaining time in a round.
///
/// The concrete implementation doesn't need to deal with a suspended process,
/// because it's intended to be used when a workout is ongoing (i.e. the app
/// remains in the foreground).
protocol RoundCountdownTimeManagement {
    // MARK: Properties
    var remainingDuration: TimeInterval { get async }
    var isCountingDown: Bool { get async }
    var isPaused: Bool { get async }

    // MARK: Methods

    /// Starts the timer.
    ///
    /// `onTick` is called immediately upon starting.
    ///
    /// - Parameters:
    ///   - duration: The duration to count down.
    ///   - onTick: A closure to invoke every time a second is counted down.
    func start(
        with duration: TimeInterval,
        onTick: @MainActor @Sendable @escaping (TimeInterval) async -> Void
    ) async

    /// Pauses the countdown.
    ///
    /// If this instance is paused or hasn't started counting,
    /// this method does nothing.
    ///
    /// This method does not invoke the closure passed to ``start(with:onTick:)``.
    func pause() async

    /// Resumes the countdown.
    ///
    /// If this instance is not paused or hasn't started counting,
    /// this method does nothing.
    ///
    /// This method invokes the closure passed to ``start(with:onTick:)``.
    func resume() async

    /// Stop the countdown.
    ///
    /// If this instance hasn't started counting, this method does nothing.
    ///
    /// This method does not invokes the closure passed to ``start(with:onTick:)``
    func stop() async

    /// Resets the countdown.
    func reset() async
}

// MARK: - CountdownTimer
class RoundCountdownTimer: RoundCountdownTimeManagement {
    // MARK: Properties
    var remainingDuration: TimeInterval = 0
    var isCountingDown = false
    var isPaused = false

    // MARK: Private Properties
    private var duration: TimeInterval = 0
    private var timer: RepeatingTimer?

    private var onTick: (@MainActor @Sendable (TimeInterval) async -> Void)?

    nonisolated init() { }

    // MARK: Methods
    func pause() async {
        guard !isPaused, isCountingDown else { return }
        isPaused = true
        await timer?.cancel()
    }

    func resume() async {
        guard isCountingDown, isPaused else { return }
        guard remainingDuration > 0 else { return }

        isPaused = false
        await timer?.cancel()
        await timer?.start()
        await onTick?(remainingDuration)
    }

    func stop() async {
        await timer?.cancel()
        isCountingDown = false
    }

    func reset() async {
        await timer?.cancel()
        timer = nil
        onTick = nil
        duration = 0
        remainingDuration = 0
        isCountingDown = false
        isPaused = false
    }

    func start(
        with duration: TimeInterval,
        onTick: @MainActor @Sendable @escaping (TimeInterval) async -> Void
    ) async {
        guard !isCountingDown else { return }

        self.duration = duration
        self.onTick = onTick

        isPaused = false
        isCountingDown = true
        remainingDuration = duration

        await initializeTimer()

        await timer?.start()
        await onTick(remainingDuration)
    }

    // MARK: Private Method
    private func initializeTimer() async {
        if timer == nil {
            timer = RepeatingTimer(timeInterval: 1) { [weak self] in
                await self?.handleTick()
            }
        }
    }

    private func handleTick() async {
        guard !isPaused else { return }

        remainingDuration -= 1
        await onTick?(remainingDuration)

        if remainingDuration <= 0 {
            await timer?.cancel()
        }
    }
}
