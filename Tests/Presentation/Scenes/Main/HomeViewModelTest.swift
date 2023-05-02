//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Defaults
import Logging

@testable import The_Bell

@MainActor
final class HomeViewModelTest: XCTestCase {
    // MARK: Properties
    private var workoutManager: MockSpyWorkoutSessionManager!
    private var mainRepository: MockSpyMainRepository!
    private var sut: HomeViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        workoutManager = MockSpyWorkoutSessionManager()
        mainRepository = MockSpyMainRepository()
        sut = HomeViewModel(
            mainRepository: mainRepository,
            workoutSessionManager: workoutManager,
            logger: Logger(label: "")
        )

        Defaults.removeAll()
    }

    // MARK: Tests
    func testThatWelcomeViewIsDisplayedWhenTheKeyIsFalse() async throws {
        await sut.appear()

        XCTAssertTrue(sut.isWelcomeMessageDisplayed)
    }

    func testThatWelcomeViewIsNotDisplayedWhenTheKeyIsTrue() async throws {
        Defaults[.hasSeenWelcomeMessage] = true
        await sut.appear()

        XCTAssertFalse(sut.isWelcomeMessageDisplayed)
    }

    func testThatWelcomeViewIsDismissedWhenCompleted() async throws {
        await sut.appear()
        sut.onboardingDidComplete()

        XCTAssertFalse(sut.isWelcomeMessageDisplayed)
    }

    func testThatWorkoutIsDisplayedWhenTheStateIsNotNil() async throws {
        Defaults[.hasSeenWelcomeMessage] = true
        await sut.appear()

        XCTAssertFalse(sut.isWorkoutDisplayed)

        workoutManager.sendState(.idle)

        await MainActor.run { XCTAssertTrue(sut.isWorkoutDisplayed) }

        workoutManager.sendState(.paused)

        await MainActor.run { XCTAssertTrue(sut.isWorkoutDisplayed) }

        workoutManager.sendState(.running)

        await MainActor.run { XCTAssertTrue(sut.isWorkoutDisplayed) }

        workoutManager.sendState(.completed(nil))

        await MainActor.run { XCTAssertTrue(sut.isWorkoutDisplayed) }

        workoutManager.sendState(.error(nil))

        await MainActor.run { XCTAssertTrue(sut.isWorkoutDisplayed) }

        workoutManager.sendState(nil)

        await MainActor.run { XCTAssertFalse(sut.isWorkoutDisplayed) }
    }

    func testThatTheNumberOfRoundIsRetrieved() async throws {
        await sut.appear()

        XCTAssertTrue(mainRepository.didCallGetMainWorkout)
    }

    func testThatWorkoutIsPrepared() async throws {
        await sut.appear()
        await sut.prepareWorkout()

        XCTAssertTrue(workoutManager.didPrepare)
    }
}
