//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import HealthKit

// MARK: - Protocols
/// Builds a workout summary from the given inputs.
@MainActor
protocol WorkoutSummaryBuilding: Sendable {
    /// Builds a workout summary from the given inputs.
    ///
    /// - Parameters:
    ///   - builder: The workout build from HealthKit.
    ///   - startDate: The start date of the workout.
    ///   - workout: The workout preferences
    ///   - totalDuration: The total duration of the workout.
    ///   - energyUnit: The user preferred energy unit.
    /// - Returns: The Workout Summary.
    func makeSummary(
        builder: HKLiveWorkoutBuilder?,
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval,
        energyUnit: EnergyUnit
    ) async -> WorkoutSummary?
}

// MARK: - Main Class
final class WorkoutSummaryBuilder: WorkoutSummaryBuilding {
    nonisolated init() { }

    func makeSummary(
        builder: HKLiveWorkoutBuilder?,
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval,
        energyUnit: EnergyUnit
    ) async -> WorkoutSummary? {
        guard let startDate = startDate else { return nil }

        let endDate = Date.now

        var activeEnergyBurned: Int?
        var totalEnergyBurned: Int?

        var averageHeartRate: Int?
        var minimumHeartRate: Int?
        var maximumHeartRate: Int?

        let heartRateQuantity = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let activeEnergyQuantity = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let basalEnergyQuantity = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!

        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())

        let heartStatistics = builder?.statistics(for: heartRateQuantity)
        let activeEnergyStatistics = builder?.statistics(for: activeEnergyQuantity)
        let basalEnergyStatistics = builder?.statistics(for: basalEnergyQuantity)

        if let value = heartStatistics?.averageQuantity()?.doubleValue(for: heartRateUnit) {
            averageHeartRate = Int(round(value))
        }

        if let value = heartStatistics?.maximumQuantity()?.doubleValue(for: heartRateUnit) {
            maximumHeartRate = Int(round(value))
        }

        if let value = heartStatistics?.minimumQuantity()?.doubleValue(for: heartRateUnit) {
            minimumHeartRate = Int(round(value))
        }

        let unit = energyUnit.hkUnit
        if let value = activeEnergyStatistics?.sumQuantity()?.doubleValue(for: unit) {
            let activeValue = Int(round(value))
            activeEnergyBurned = activeValue

            if let value = basalEnergyStatistics?.sumQuantity()?.doubleValue(for: unit) {
                totalEnergyBurned = activeValue + Int(round(value))
            }
        }

        let expectedDuration = Double(
            workout.roundCount * workout.roundDuration +
            (workout.roundCount - 1) * workout.breakDuration
        )

        return WorkoutSummary(
            activeEnergyBurned: activeEnergyBurned,
            totalEnergyBurned: totalEnergyBurned,
            averageHeartRate: averageHeartRate,
            minimumHeartRate: minimumHeartRate,
            maximumHeartRate: maximumHeartRate,
            startDate: startDate,
            endDate: endDate,
            totalDuration: totalDuration,
            expectedTotalDuration: expectedDuration,
            energyUnit: energyUnit
        )
    }
}
