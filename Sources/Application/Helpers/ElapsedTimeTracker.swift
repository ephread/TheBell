//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

// MARK: - Main Protocol
/// Tracks the total time elapsed in a workout.
///
/// The concrete implementation doesn't need to deal with a suspended process,
/// because it's intended to be used when a workout is ongoing (i.e. the app
/// remains in the foreground).
@MainActor
protocol ElapsedTimeTracking: AnyObject {
    // MARK: Properties
    /// The number of seconds elapsed since the reference date
    ///  (see ``startTracking(from:onTick:)``, minus the time spend paused.
    var elapsedTime: TimeInterval { get async }

    var isTracking: Bool { get async }
    var isPaused: Bool { get async }

    // MARK: Methods

    /// Starts counting time elapsed since `date`.
    ///
    /// - Parameters:
    ///   - date: The start date to use.
    ///   - onTick: A closure to call about every second.
    func startTracking(
        from date: Date,
        onTick: @MainActor @Sendable @escaping (TimeInterval) async -> Void
    ) async

    /// Starts counting time elapsed since now minus `elapsedTime`.
    /// This method is used when restoring a workout.
    ///
    /// - Parameters:
    ///   - elapsedTime: A negative offset in seconds.
    ///   - onTick: A closure to call about every second.
    func startTracking(
        from elapsedTime: TimeInterval,
        onTick: @MainActor @Sendable @escaping (TimeInterval) async -> Void
    ) async

    func pauseTracking() async
    func resumeTracking() async
    func stopTracking() async

    func reset() async
}

// MARK: - Main Class
class ElapsedTimeTracker: ElapsedTimeTracking {
    // MARK: Properties
    var elapsedTime: TimeInterval {
        get async {
            guard let startDate = startDate else { return 0 }
            guard isTracking else { return lastElapsedTimeSent ?? 0 }

            return Date.now.timeIntervalSince(startDate) - timeSpentPaused
        }
    }

    var isTracking = false
    var isPaused = false

    // MARK: Private Property
    private var startDate: Date?
    private var timer: RepeatingTimer?
    private var onTick: (@MainActor @Sendable (TimeInterval) async -> Void)?

    private var pauseDate: Date?

    private var timeSpentPaused: TimeInterval = 0
    private var lastElapsedTimeSent: TimeInterval?

    // MARK: Initializer
    nonisolated init() { }

    // MARK: Methods
    func startTracking(
        from date: Date,
        onTick: @MainActor @Sendable @escaping (TimeInterval) async -> Void
    ) async {
        guard !isTracking else { return }

        await initializeTimer()
        await reset()

        self.onTick = onTick
        self.isTracking = true
        self.startDate = date

        await timer?.start()
    }

    func startTracking(
        from elapsedTime: TimeInterval,
        onTick: @MainActor @Sendable @escaping (TimeInterval) async -> Void
    ) async {
        guard !isTracking else { return }

        await initializeTimer()
        await reset()

        self.onTick = onTick
        self.isTracking = true
        self.startDate = Date.now.addingTimeInterval(-elapsedTime)

        await timer?.start()
    }

    func pauseTracking() async {
        guard isTracking else { return }

        await notify()
        isPaused = true
        pauseDate = Date.now
        await timer?.cancel()
    }

    func resumeTracking() async {
        guard isTracking, isPaused, let pauseDate = pauseDate else { return }

        isPaused = false
        timeSpentPaused += Date.now.timeIntervalSince(pauseDate)

        await timer?.start()
        self.pauseDate = nil
    }

    func stopTracking() async {
        guard isTracking else { return }

        if isPaused, let pauseDate = pauseDate {
            timeSpentPaused += Date.now.timeIntervalSince(pauseDate)
        }

        await notify()
        isTracking = false
        await timer?.cancel()
    }

    func reset() async {
        lastElapsedTimeSent = nil
        isTracking = false
        isPaused = false

        startDate = nil
        await timer?.cancel()

        pauseDate = nil
        timeSpentPaused = 0
    }

    // MARK: Private Methods
    private func initializeTimer() async {
        if timer == nil {
            timer = RepeatingTimer(timeInterval: 1) { [weak self] in
                await self?.handleTick()
            }
        }
    }

    private func handleTick() async {
        await notify()
    }

    private func notify() async {
        if isTracking && !isPaused {
            let time = await elapsedTime
            lastElapsedTimeSent = time
            await onTick?(time)
        }
    }
}
