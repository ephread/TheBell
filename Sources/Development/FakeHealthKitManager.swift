//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

#if DEBUG

import Foundation

actor FakeHealthKitManager: HealthKitManagement {
    var currentHeartRate: Int?
    var activeCalories: Int?
    var preferredEnergyUnit: EnergyUnit = .kilocalorie

    private weak var delegate: (any HealthKitManagerDelegate)?

    private var isStarted = false
    private var isPaused = false

    private var varWorkoutTimer: RepeatingTimer?

    func makeSummary(
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval
    ) async -> WorkoutSummary? {
        return .preview
    }

    func requestAccessToHealthStore() async throws {
        // DO nothing.
    }

    func loadPreferredEnergyUnit() async throws {
        preferredEnergyUnit = .kilocalorie
        await delegate?.didUpdate(preferredEnergyUnit: preferredEnergyUnit)
    }

    func startWorkout() async throws {
        if varWorkoutTimer == nil {
            varWorkoutTimer = await RepeatingTimer(timeInterval: 5) { [weak self] in
                await self?.updateMetrics()
            }
        }

        isStarted = true
        await varWorkoutTimer?.start()
    }

    func resumeWorkout() async {
        isPaused = false
        await varWorkoutTimer?.start()
    }

    func pauseWorkout() async {
        isPaused = true
        await varWorkoutTimer?.cancel()
    }

    func endWorkout() async throws {
        isStarted = false
        isPaused = false
        await varWorkoutTimer?.cancel()
    }

    func discardPreviousWorkout() async {

    }

    func recoverWorkout() async throws {

    }

    func setDelegate(_ delegate: any HealthKitManagerDelegate) async {
        self.delegate = delegate
    }

    private func updateMetrics() async {
        currentHeartRate = Int.random(in: 120...140)
        activeCalories = (activeCalories ?? 0) + Int.random(in: 0...2)

        await delegate?.didUpdate(currentHeartRate: currentHeartRate)
        await delegate?.didUpdate(activeCalories: activeCalories)
    }
}

#endif
