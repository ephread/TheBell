//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import GRDB
import Defaults
import Logging

// MARK: - Main Class
/// Create the database schema and populates the database
/// with default values.
class DatabaseInitializer {
    // MARK: Private Properties
    private let fileManager: FileManager
    private let logger: Logger

    // MARK: Initialization
    init(fileManager: FileManager, logger: Logger) {
        self.fileManager = fileManager
        self.logger = logger
    }

    // MARK: Private Properties
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("createUserPreferences") { db in
            try db.create(table: "userPreference") { t in
                t.autoIncrementedPrimaryKey("id")

                t.column("isAudioFeedbackEnabled", .boolean).notNull()
                t.column("isHapticFeedbackEnabled", .boolean).notNull()
                t.column("maximumHeartRate", .integer).notNull()
                t.column("audioVolume", .double).notNull()
            }
        }

        migrator.registerMigration("createWorkouts") { db in
            try db.create(table: "workout") { t in
                t.autoIncrementedPrimaryKey("id")

                t.column("name", .text).notNull().unique().indexed()
                t.column("roundCount", .integer).notNull()
                t.column("roundDuration", .integer).notNull()
                t.column("lastStretchDuration", .integer).notNull()
                t.column("breakDuration", .integer).notNull()
            }
        }

        migrator.registerMigration("createMainWorkout") { db in
            var workout = Workout.main
            try workout.insert(db)
        }

        migrator.registerMigration("createDefaultUserPreference") { db in
            var userPreferences = UserPreference.default
            try userPreferences.insert(db)
        }

        return migrator
    }

    // MARK: Methods
    /// Create the database queue, migrate the scheme and populate the database.
    func initializeDatabaseQueue() throws -> DatabaseQueue {
        let databaseQueue = try makeDatabaseQueue()

        #if DEBUG
        if CommandLine.arguments.contains("--reset-database") {
            logger.debug("'--reset-database' detected: erasing database…")
            try databaseQueue.erase()
        }
        #endif

        // Between version 1.0 and version 1.1, the database schema was slightly altered.
        // For simplicity, we erase the pre-existing DB and recreate it.
        //
        // The Bell doesn't have a user base and it has been out of the store for a while.
        // Nobody is using v1.0. Worse-case scenario: users have to set their preferences again.
        if !Defaults[.isUsingDatabase2] {
            logger.info("'isUsingDatabase2' not set: erasing pre-existing database if it exists…")
            try databaseQueue.erase()
            Defaults[.isUsingDatabase2] = true
        }

        try migrator.migrate(databaseQueue)

        return databaseQueue
    }

    // MARK: - Private Methods
    private func makeDatabaseQueue() throws -> DatabaseQueue {
        let url = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let databaseURL = url.appendingPathComponent("db.sqlite")

        return try DatabaseQueue(path: databaseURL.path)
    }
}

#if DEBUG

extension DatabaseInitializer {
    func initializeInMemoryDatabaseQueue() throws -> DatabaseQueue {
        let databaseQueue = DatabaseQueue()
        try migrator.migrate(databaseQueue)

        return databaseQueue
    }
}

#endif
