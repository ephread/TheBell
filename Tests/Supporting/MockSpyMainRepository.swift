//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Combine
import GRDB

@testable import The_Bell

final class MockSpyMainRepository: MainDataStorage {
    // MARK: Mock/Spy Properties
    var didCallGetUserPreferences = false
    var didCallGetMainWorkout = false

    var didCallSavePreferences = false
    var didCallSaveWorkout = false

    var userPreference: UserPreference
    var workout: Workout

    var shouldTriggerErrorOnSave = false

    // MARK: Initialization
    init(userPreference: UserPreference = .default, workout: Workout = .main) {
        self.userPreference = userPreference
        self.workout = workout
    }

    // MARK: Methods
    func getUserPreferences() async -> UserPreference {
        didCallGetUserPreferences = true
        return userPreference
    }

    func getMainWorkout() async -> Workout {
        didCallGetMainWorkout = true
        return workout
    }

    func save(preferences: UserPreference) async throws -> UserPreference {
        didCallSavePreferences = true

        if shouldTriggerErrorOnSave {
            throw The_Bell.DatabaseError.databaseError(DatabaseError())
        }

        self.userPreference = preferences
        return preferences
    }

    func save(workout: Workout) async throws -> Workout {
        didCallSaveWorkout = true

        if shouldTriggerErrorOnSave {
            throw The_Bell.DatabaseError.databaseError(DatabaseError())
        }

        self.workout = workout
        return workout
    }

    // MARK: Mock Methods
    func enableErrorOnSave() {
        shouldTriggerErrorOnSave = true
    }
}
