//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Combine

#if DEBUG

// Fake objects that can be used in SwiftUI Previews.

extension WorkoutSummary {
    static var preview: WorkoutSummary {
        WorkoutSummary(
            activeEnergyBurned: 130,
            totalEnergyBurned: 220,
            averageHeartRate: 155,
            minimumHeartRate: 110,
            maximumHeartRate: 173,
            startDate: Date(timeIntervalSince1970: 1_680_786_000),
            endDate: Date(timeIntervalSince1970: 1_680_787_800),
            totalDuration: 1_800,
            expectedTotalDuration: 1_800,
            energyUnit: .kilocalorie
        )
    }
}

class EmptyHapticSoundManager: HapticSoundManagement {
    var isAudioFeedbackEnabled = false
    var isHapticFeedbackEnabled = false
    var audioVolume: Float = 0

    func notifyUser(that eventType: HapticSoundEventType) { }
}

actor EmptyHealthKitManager: HealthKitManagement {
    var preferredEnergyUnit: EnergyUnit = .kilocalorie
    var currentHeartRate: Int?
    var activeCalories: Int?

    func makeSummary(
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval
    ) -> WorkoutSummary? {
        return nil
    }

    func requestAccessToHealthStore() async throws { }
    func loadPreferredEnergyUnit() async throws { }
    func startWorkout() async throws { }
    func resumeWorkout() async { }
    func pauseWorkout() async { }
    func endWorkout() async throws { }
    func discardPreviousWorkout() async { }
    func recoverWorkout() async throws { }
    func reset() async { }
    func setDelegate(_ delegate: any HealthKitManagerDelegate) async { }
}

class WorkoutSessionManagerPreview: WorkoutSessionManagement {
    let totalElapsedTime = CurrentValueSubject<TimeInterval?, Never>(40)
    let remainingDuration = CurrentValueSubject<TimeInterval?, Never>(92)
    let currentIntervalType = CurrentValueSubject<IntervalType?, Never>(.round(3, 6))

    let currentHeartRate = CurrentValueSubject<HeartRate?, Never>(nil)
    let activeCalories = CurrentValueSubject<Int?, Never>(nil)

    let state = CurrentValueSubject<WorkoutState?, Never>(.running)
    let error = CurrentValueSubject<(any DisplayableError)?, Never>(nil)

    var preferredEnergyUnit: EnergyUnit = .kilocalorie
    var isCountingDown = true
    var isWorkoutLoaded = true
    var isWorkoutStarted = true
    var isWorkoutPaused = false

    func prepareWorkout() async { }
    func startWorkout() async {
        currentHeartRate.send(HeartRate(measured: 130, maximum: 220))
        activeCalories.send(456)
    }

    func startWorkoutCountdown() async { }
    func recoverWorkout() async { }
    func resumeWorkout() async { }
    func pauseWorkout() async { }
    func endWorkout() async { }
    func clearWorkout() async { }
}

class WorkoutViewModelPreview: WorkoutViewModel {
    func startCountdown() {
        self.currentScene = .countdown
    }
}

class MainRepositoryPreview: MainDataStorage {
    func getUserPreferences() async -> UserPreference {
        UserPreference(
            isAudioFeedbackEnabled: false,
            isHapticFeedbackEnabled: false,
            maximumHeartRate: 220,
            audioVolume: 0
        )
    }

    func getMainWorkout() async -> Workout {
        Workout(
            name: "Default",
            roundCount: 9,
            roundDuration: 300,
            lastStretchDuration: 10,
            breakDuration: 20
        )
    }

    func save(preferences: UserPreference) async throws -> UserPreference { preferences }
    func save(workout: Workout) async throws -> Workout { workout }
}

#endif
