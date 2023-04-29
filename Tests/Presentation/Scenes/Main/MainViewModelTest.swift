//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Defaults
@testable import The_Bell

@MainActor
final class MainViewModelTest: XCTestCase {
    // MARK: Properties
    private var workoutManager: MockSpyWorkoutSessionManager!
    private var mainRepository: MockSpyMainRepository!
    private var viewModel: HomeViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        workoutManager = MockSpyWorkoutSessionManager()
        mainRepository = MockSpyMainRepository()
        viewModel = HomeViewModel(
            mainRepository: mainRepository,
            workoutSessionManager: workoutManager
        )

        Defaults.removeAll()
    }

    // MARK: Tests
    func testThatWelcomeViewIsDisplayedWhenTheKeyIsFalse() async throws {
        await viewModel.appear()

        XCTAssertTrue(viewModel.isWelcomeMessageDisplayed)
    }

    func testThatWelcomeViewIsNotDisplayedWhenTheKeyIsTrue() async throws {
        Defaults[.hasSeenWelcomeMessage] = true
        await viewModel.appear()

        XCTAssertFalse(viewModel.isWelcomeMessageDisplayed)
    }

    func testThatWorkoutIsDisplayedWhenTheStateIsNotNil() async throws {
        Defaults[.hasSeenWelcomeMessage] = true
        await viewModel.appear()

        XCTAssertFalse(viewModel.isWorkoutDisplayed)

        workoutManager.sendState(.idle)

        await MainActor.run { XCTAssertTrue(viewModel.isWorkoutDisplayed) }

        workoutManager.sendState(.paused)

        await MainActor.run { XCTAssertTrue(viewModel.isWorkoutDisplayed) }

        workoutManager.sendState(.running)

        await MainActor.run { XCTAssertTrue(viewModel.isWorkoutDisplayed) }

        workoutManager.sendState(.completed(nil))

        await MainActor.run { XCTAssertTrue(viewModel.isWorkoutDisplayed) }

        workoutManager.sendState(.error(nil))

        await MainActor.run { XCTAssertTrue(viewModel.isWorkoutDisplayed) }

        workoutManager.sendState(nil)

        await MainActor.run { XCTAssertFalse(viewModel.isWorkoutDisplayed) }
    }

    func testThatTheNumberOfRoundIsRetrieved() async throws {
        await viewModel.appear()

        XCTAssertTrue(mainRepository.didCallGetMainWorkout)
    }

    func testThatWorkoutIsPrepared() async throws {
        await viewModel.appear()
        await viewModel.prepareWorkout()

        XCTAssertTrue(workoutManager.didPrepare)
    }
}
