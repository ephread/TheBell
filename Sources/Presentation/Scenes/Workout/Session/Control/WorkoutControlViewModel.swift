//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Defaults
import Combine

// MARK: - Protocols
/// Manages a workout controls (pause / stop / resume) as
/// well as its elapsed time.
@MainActor
protocol WorkoutControlViewModeling: ViewModeling {
    // MARK: Properties
    var isWorkoutPaused: Bool { get }
    var isWorkoutStarted: Bool { get }

    /// When paused, this value is periodically toggled.
    /// The view can use this property to make a label blink.
    var isElapsedTimeVisible: Bool { get }

    /// The total time spent working out.
    var elapsedTime: String { get }

    // MARK: Methods
    /// Pauses or resumes the workout, depending on its current state.
    func pauseResumeWorkout() async

    /// Ends the workout (doesn't dismiss the sheet).
    func endWorkout() async
}

// MARK: - Main Class
/// Concrete implementation of ``WorkoutManagementViewModeling``
class WorkoutControlViewModel: WorkoutControlViewModeling {
    // MARK: Published properties
    @Published var isWorkoutPaused = false
    @Published var isWorkoutStarted = false

    @Published var isElapsedTimeVisible = true
    @Published var elapsedTime: String = L10n.Placeholder.elapsedTime

    // MARK: Private Properties
    private let workoutManager: any WorkoutSessionManagement
    private let dateTimeHelper: any DateTimeHelping

    /// A timer that makes the elapsed time label blink.
    private var blinkTimer: RepeatingTimer?

    /// Cancellables subscription.
    private var cancellables: Set<AnyCancellable> = Set()

    // MARK: Initialization
    nonisolated init(
        dateTimeHelper: any DateTimeHelping,
        workoutManager: any WorkoutSessionManagement
    ) {
        self.dateTimeHelper = dateTimeHelper
        self.workoutManager = workoutManager
    }

    // MARK: Methods
    func appear() async {
        if cancellables.isEmpty {
            workoutManager.state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    self?.handleState(state)
                }
                .store(in: &cancellables)

            workoutManager.totalElapsedTime
                .receive(on: DispatchQueue.main)
                .sink { [weak self] duration in
                    self?.handleTotalElapsedTime(duration)
                }
                .store(in: &cancellables)
        }
    }

    func pauseResumeWorkout() async {
        if isWorkoutPaused {
            await workoutManager.resumeWorkout()
        } else {
            await workoutManager.pauseWorkout()
        }
    }

    func endWorkout() async {
        if isWorkoutStarted {
            await workoutManager.endWorkout()
        }
    }

    // MARK: Private Methods
    private func startBlinkingElapsedTime() {
        blinkTimer = RepeatingTimer(timeInterval: 1.0) { [weak self] in
            self?.isElapsedTimeVisible.toggle()
        }
        Task { await blinkTimer?.start() }
    }

    private func stopBlinkingElapsedTime() {
        Task {
            await blinkTimer?.cancel()
            isElapsedTimeVisible = true
        }
    }

    private func handleState(_ state: WorkoutState?) {
        if state == .paused {
            isWorkoutPaused = true
            isWorkoutStarted = true
            startBlinkingElapsedTime()
        } else if state == .running {
            isWorkoutPaused = false
            isWorkoutStarted = true
            stopBlinkingElapsedTime()
        } else {
            isWorkoutPaused = false
            isWorkoutStarted = true
            stopBlinkingElapsedTime()
        }
    }

    private func handleTotalElapsedTime(_ duration: TimeInterval?) {
        if let duration {
            let components = dateTimeHelper.timeComponents(from: duration)
            elapsedTime = L10n.Workout.Summary.Label.totalTime(
                components.hours,
                components.minutes,
                components.seconds
            )
        } else {
            elapsedTime = L10n.Placeholder.elapsedTime
        }
    }
}
