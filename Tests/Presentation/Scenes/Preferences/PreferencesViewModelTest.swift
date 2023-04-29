//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults
import Logging

@testable import The_Bell

@MainActor
final class PreferencesViewModelTest: XCTestCase {
    // MARK: Properties
    private var errorViewModel: ErrorViewModel!
    private var mainRepository: MockSpyMainRepository!
    private var sut: PreferencesViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        errorViewModel = ErrorViewModel()
        mainRepository = MockSpyMainRepository(userPreference: .default, workout: .main)
        sut = PreferencesViewModel(
            errorViewModel: errorViewModel,
            mainRepository: mainRepository,
            logger: Logger(label: "")
        )
    }

    // MARK: Tests
    func testThatModelsAreRetrieved() async throws {
        await sut.appear()

        // Disappears because data updates are only
        // performed from other view models.

        XCTAssertTrue(mainRepository.didCallGetUserPreferences)

        XCTAssertEqual(sut.heartRate, 192)
        XCTAssertEqual(sut.roundCount, 9)
        XCTAssertEqual(sut.roundMinuteDuration, 3)
        XCTAssertEqual(sut.roundSecondDuration, 0)
        XCTAssertEqual(sut.breakMinuteDuration, 0)
        XCTAssertEqual(sut.breakSecondDuration, 30)
        XCTAssertEqual(sut.lastStretchMinuteDuration, 0)
        XCTAssertEqual(sut.lastStretchSecondDuration, 30)
        XCTAssertTrue(sut.isAudioFeedbackEnabled)
        XCTAssertFalse(sut.isHapticFeedbackEnabled)
        XCTAssertEqual(sut.audioVolume, 8)

        mainRepository.didCallGetUserPreferences = false

        // Appears again because other views were popped from the stack.
        await sut.appear()

        XCTAssertFalse(mainRepository.didCallGetUserPreferences)
    }

    func testThatModelsAreSaved() async throws {
        await sut.appear()

        sut.heartRate = 140
        sut.roundCount = 2
        sut.roundMinuteDuration = 1
        sut.roundSecondDuration = 30
        sut.breakMinuteDuration = 1
        sut.breakSecondDuration = 5
        sut.lastStretchMinuteDuration = 0
        sut.lastStretchSecondDuration = 25
        sut.isAudioFeedbackEnabled = true
        sut.isHapticFeedbackEnabled = true
        sut.audioVolume = 4.0

        // Disappears because data updates are only performed
        // from other view models and then reappears when
        // the view is popped from the stack.
        await sut.appear()

        XCTAssertTrue(mainRepository.didCallGetUserPreferences)

        XCTAssertEqual(mainRepository.userPreference.maximumHeartRate, 140)
        XCTAssertEqual(mainRepository.workout.roundCount, 2)
        XCTAssertEqual(mainRepository.workout.roundDuration, 90)
        XCTAssertEqual(mainRepository.workout.breakDuration, 65)
        XCTAssertEqual(mainRepository.workout.lastStretchDuration, 25)
        XCTAssertTrue(mainRepository.userPreference.isAudioFeedbackEnabled)
        XCTAssertTrue(mainRepository.userPreference.isHapticFeedbackEnabled)
        XCTAssertEqual(mainRepository.userPreference.audioVolume, 0.4)
    }

    func testThatValuesAreClamped() async throws {
        await sut.appear()

        // Disappears because data updates are only
        // performed from other view models.

        sut.heartRate = 500
        sut.roundCount = 0
        sut.roundMinuteDuration = 1
        sut.roundSecondDuration = 5_000
        sut.breakMinuteDuration = 0
        sut.breakSecondDuration = 0
        sut.lastStretchMinuteDuration = 60_000
        sut.lastStretchSecondDuration = 0
        sut.audioVolume = 500

        // Appears again because other views were popped from the stack.
        await sut.appear()

        XCTAssertTrue(mainRepository.didCallGetUserPreferences)

        XCTAssertEqual(mainRepository.userPreference.maximumHeartRate, 220)
        XCTAssertEqual(mainRepository.workout.roundCount, 2)
        XCTAssertEqual(mainRepository.workout.roundDuration, 900)
        XCTAssertEqual(mainRepository.workout.breakDuration, 5)
        XCTAssertEqual(mainRepository.workout.lastStretchDuration, 300)
        XCTAssertEqual(mainRepository.userPreference.audioVolume, 1)
    }

    func testThatFinalStageDurationIsValidatedAndUpdatedIfNecessary() async throws {
        await sut.appear()

        // Disappears because data updates are only
        // performed from other view models.

        sut.roundMinuteDuration = 0
        sut.roundSecondDuration = 900
        sut.lastStretchMinuteDuration = 0
        sut.lastStretchSecondDuration = 500

        // Appears again because other views were popped from the stack.
        await sut.appear()

        XCTAssertEqual(mainRepository.workout.lastStretchDuration, 300)

        // Disappears because data updates are only
        // performed from other view models.

        sut.roundMinuteDuration = 0
        sut.roundSecondDuration = 200
        sut.lastStretchMinuteDuration = 0
        sut.lastStretchSecondDuration = 9_000

        // Appears again because other views were popped from the stack.
        await sut.appear()

        XCTAssertEqual(mainRepository.workout.lastStretchDuration, 100)
    }

    func testThatErrorsAreReportedOnSave() async throws {
        mainRepository.enableErrorOnSave()
        await sut.appear()

        // Disappear and reappears.
        await sut.appear()

        // There should be two errors enqueued (UserPreference + Workout).
        XCTAssertNotNil(errorViewModel.currentError)
        errorViewModel.dismiss()
        XCTAssertNotNil(errorViewModel.currentError)
    }

    func testThatFinalStageRangeDependsOnRoundDuration() async throws {
        await sut.appear()

        sut.roundSecondDuration = 25
        sut.roundMinuteDuration = 3

        XCTAssertEqual(sut.range(forRow: .lastStretchDuration), 5...100)

        sut.roundSecondDuration = 7
        sut.roundMinuteDuration = 2

        XCTAssertEqual(sut.range(forRow: .lastStretchDuration), 5...60)

        sut.roundSecondDuration = 0
        sut.roundMinuteDuration = 900

        XCTAssertEqual(sut.range(forRow: .lastStretchDuration), 5...300)

        // Impossible edge case, just testing that the method returns an empty range.
        sut.roundSecondDuration = 5
        sut.roundMinuteDuration = 0

        XCTAssertEqual(sut.range(forRow: .lastStretchDuration), 0...0)
    }
}
