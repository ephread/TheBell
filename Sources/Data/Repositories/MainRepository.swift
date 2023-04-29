//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import GRDB
import Logging
import Defaults

// MARK: - Protocols
/// Stores and retrieves main data models to/from the database.
protocol MainDataStorage {
    /// - Returns: The User Preferences.
    func getUserPreferences() async -> UserPreference

    /// - Returns: The Main Workout
    func getMainWorkout() async -> Workout

    /// Persist the given preferences.
    /// - Parameter preferences: The User Preferences to save.
    /// - Returns: The updated User Preferences.
    @discardableResult
    func save(preferences: UserPreference) async throws -> UserPreference

    /// Persist the given workout.
    /// - Parameter preferences: The Main Workout to save.
    /// - Returns: The updated Main Workout.
    @discardableResult
    func save(workout: Workout) async throws -> Workout
}

// MARK: - Implementation
actor MainRepository: MainDataStorage {
    // MARK: Private Properties
    private var databaseQueue: DatabaseQueue
    private let logger: Logger

    // MARK: Initialization
    init(databaseQueue: DatabaseQueue, logger: Logger) {
        self.databaseQueue = databaseQueue
        self.logger = logger
    }

    // MARK: Methods
    func getUserPreferences() async -> UserPreference {
        // The object is guaranteed to be present. If it isn't something went wrong
        // and the app can't continue anyway. We are force-wrapping to make the
        // failure explicit rather than letting the exception bubble up.
        // swiftlint:disable:next force_try
        return try! await databaseQueue.read { db in
            try UserPreference.filter(sql: "id = ?", arguments: [1]).fetchOne(db)!
        }
    }

    func getMainWorkout() async -> Workout {
        // The object is guaranteed to be present. If it isn't something went wrong
        // and the app can't continue anyway. We are force-wrapping to make the
        // failure explicit rather than letting the exception bubble up.
        // swiftlint:disable:next force_try
        return try! await databaseQueue.read { db in
            try Workout.filter(sql: "name = ?", arguments: ["main"]).fetchOne(db)!
        }
    }

    @discardableResult
    func save(preferences: UserPreference) async throws -> UserPreference {
        #if DEBUG
        if Defaults[.notifyErrorOnSave] {
            throw DatabaseError.unknownError(FakeError())
        }
        #endif

        do {
            return try await databaseQueue.write { [weak self] db in
                let returnValue = try preferences.saved(db)
                self?.logger.log(level: .debug, "User Preferences saved: \(preferences)")
                return returnValue
            }
        } catch {
            logger.error(error)

            switch error {
            case let error as GRDB.PersistenceError:
                throw DatabaseError.persistenceError(error)
            case let error as GRDB.DatabaseError:
                throw DatabaseError.databaseError(error)
            default:
                throw DatabaseError.unknownError(error)
            }
        }
    }

    @discardableResult
    func save(workout: Workout) async throws -> Workout {
        #if DEBUG
        if Defaults[.notifyErrorOnSave] {
            throw DatabaseError.unknownError(FakeError())
        }
        #endif

        do {
            return try await databaseQueue.write { [weak self] db in
                let returnValue = try workout.saved(db)
                self?.logger.log(level: .debug, "Workout saved: \(workout)")
                return returnValue
            }
        } catch {
            logger.error(error)

            switch error {
            case let error as GRDB.PersistenceError:
                throw DatabaseError.persistenceError(error)
            case let error as GRDB.DatabaseError:
                throw DatabaseError.databaseError(error)
            default:
                throw DatabaseError.unknownError(error)
            }
        }
    }
}
