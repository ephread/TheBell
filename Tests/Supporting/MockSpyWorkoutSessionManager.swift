//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Combine
@testable import The_Bell

final class MockSpyWorkoutSessionManager: WorkoutSessionManagement {
    // MARK: Properties
    var totalElapsedTime = CurrentValueSubject<TimeInterval?, Never>(nil)
    var remainingDuration = CurrentValueSubject<TimeInterval?, Never>(nil)
    var currentIntervalType = CurrentValueSubject<IntervalType?, Never>(nil)
    var currentHeartRate = CurrentValueSubject<HeartRate?, Never>(nil)
    var activeCalories = CurrentValueSubject<Int?, Never>(nil)
    var state = CurrentValueSubject<WorkoutState?, Never>(nil)
    var preferredEnergyUnit: EnergyUnit = .kilocalorie

    var isWorkoutLoaded = false
    var isWorkoutStarted = false
    var isWorkoutPaused = false

    // MARK: Mock/Spy Properties
    var didPrepare = false
    var didStart = false
    var didPause = false
    var didResume = false
    var didEnd = false
    var didClearWorkout = false

    // MARK: Methods
    func prepareWorkout() async { didPrepare = true }
    func startWorkout() async { didStart = true }
    func pauseWorkout() async { didPause = true }
    func resumeWorkout() async { didResume = true }
    func endWorkout() async { didEnd = true }
    func clearWorkout() async { didClearWorkout = true }

    func recoverWorkout() async { }

    // MARK: Mock Methods
    func sendTotalElapsedTime(_ value: TimeInterval?) {
        totalElapsedTime.send(value)
    }

    func sendRemainingDuration(_ value: TimeInterval?) {
        remainingDuration.send(value)
    }

    func sendCurrentIntervalType(_ value: IntervalType?) {
        currentIntervalType.send(value)
    }

    func sendCurrentHeartRate(_ value: HeartRate?) {
        currentHeartRate.send(value)
    }

    func sendActiveCalories(_ value: Int?) {
        activeCalories.send(value)
    }

    func sendState(_ value: WorkoutState?) {
        state.send(value)
    }

    func setPreferredEnergyUnit(_ value: EnergyUnit) {
        preferredEnergyUnit = value
    }

    func setIsWorkoutLoaded(_ value: Bool) {
        isWorkoutLoaded = true
    }

    func setIsWorkoutStarted(_ value: Bool) {
        isWorkoutStarted = true
    }

    func setIsWorkoutPaused(_ value: Bool) {
        isWorkoutPaused = true
    }
}
