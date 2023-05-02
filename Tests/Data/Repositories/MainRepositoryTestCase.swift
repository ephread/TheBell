//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import GRDB
import Logging
@testable import The_Bell

final class MainRepositoryTestCase: XCTestCase {
    // MARK: Properties
    private var databaseQueue: DatabaseQueue!
    private var sut: MainRepository!

    // MARK: Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()

        let intializer = DatabaseInitializer(
            fileManager: FileManager.default,
            logger: Logger(label: "")
        )

        databaseQueue = try intializer.initializeInMemoryDatabaseQueue()
        sut = MainRepository(databaseQueue: databaseQueue, logger: Logger(label: ""))
    }

    // MARK: Tests
    func testRoundTrip() async throws {
        var workout = await sut.getMainWorkout()
        workout.roundCount = 5
        workout.roundDuration = 50
        workout.lastStretchDuration = 10
        workout.breakDuration = 30

        try await sut.save(workout: workout)

        let workout2 = await sut.getMainWorkout()

        XCTAssertEqual(workout, workout2)

        var preferences = await sut.getUserPreferences()
        preferences.audioVolume = 0.1
        preferences.isAudioFeedbackEnabled = false
        preferences.isHapticFeedbackEnabled = true
        preferences.maximumHeartRate = 170

        try await sut.save(preferences: preferences)

        let preferences2 = await sut.getUserPreferences()

        XCTAssertEqual(preferences, preferences2)
    }

}
