//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Combine
@testable import The_Bell

actor MockSpyHealthKitManager: HealthKitManagement {
    // MARK: Properties
    var currentHeartRate: Int?
    var activeCalories: Int?
    var preferredEnergyUnit: EnergyUnit = .joule

    // MARK: Mock/Spy Properties
    weak var delegate: (any HealthKitManagerDelegate)?
    var isErrorTriggerEnabled = false
    var isDelayEnabled = false

    var didStart = false
    var didPause = false
    var didResume = false
    var didEnd = false
    var didRecover = false

    var didDiscardPreviousWorkout = false

    // MARK: Methods
    func makeSummary(
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval
    ) async -> WorkoutSummary? {
        return .preview
    }

    func requestAccessToHealthStore() async throws {
        if isDelayEnabled {
            try await Task.sleep(for: .seconds(1))
        }

        if isErrorTriggerEnabled {
            throw HealthKitError.accessRefused(nil)
        }
    }

    func loadPreferredEnergyUnit() async throws {

    }

    func startWorkout() async throws {
        didStart = true

        if isErrorTriggerEnabled {
            throw HealthKitError.healthKitNotAvailable
        }
    }

    func resumeWorkout() async {
        didResume = true
    }

    func pauseWorkout() async {
        didPause = true
    }

    func endWorkout() async throws {
        didEnd = true

        if isErrorTriggerEnabled {
            throw HealthKitError.healthKitNotAvailable
        }
    }

    func discardPreviousWorkout() async {
        didDiscardPreviousWorkout = true
    }

    func tryToRecoverWorkout() async throws {
        didRecover = true

        if isErrorTriggerEnabled {
            throw HealthKitError.healthKitNotAvailable
        }
    }

    func setDelegate(_ delegate: any HealthKitManagerDelegate) async {
        self.delegate = delegate
    }

    // MARK: Mock Methods
    func setCurrentHeartRate(_ value: Int?) async {
        currentHeartRate = value
        await delegate?.didUpdate(currentHeartRate: value)
    }

    func setActiveCalorie(_ value: Int?) async {
        activeCalories = value
        await delegate?.didUpdate(activeCalories: value)
    }

    func setPreferredEnergyUnit(_ value: EnergyUnit) async {
        preferredEnergyUnit = value
        await delegate?.didUpdate(preferredEnergyUnit: value)
    }

    func enableErrorTrigger() {
        isErrorTriggerEnabled = true
    }

    func enableDelayWhenRequestingPermissions() {
        isDelayEnabled = true
    }
}
