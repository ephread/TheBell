//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

@MainActor
final class WorkoutViewModelTest: XCTestCase {
    // MARK: Properties
    private var workoutSessionManager: MockSpyWorkoutSessionManager!
    private var mainViewModel: MockMainViewModel!
    private var errorViewModel: ErrorViewModel!
    private var sut: WorkoutViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        workoutSessionManager = MockSpyWorkoutSessionManager()
        mainViewModel = MockMainViewModel()
        errorViewModel = ErrorViewModel()
        sut = WorkoutViewModel(
            mainViewModel: mainViewModel,
            errorViewModel: errorViewModel,
            workoutManager: workoutSessionManager
        )
    }

    // MARK: Tests
    func testThatCurrentSceneIsUpdated() async {
        await sut.appear()

        var currentScene = sut.currentScene

        workoutSessionManager.sendState(.idle)
        await Task.yield()
        XCTAssertNotEqual(currentScene, sut.currentScene)
        currentScene = sut.currentScene

        workoutSessionManager.sendState(.running)
        await Task.yield()
        XCTAssertNotEqual(currentScene, sut.currentScene)
        currentScene = sut.currentScene

        workoutSessionManager.sendState(.paused)
        await Task.yield()
        // .paused and .running are expected to use the same scene.
        XCTAssertEqual(currentScene, sut.currentScene)
        currentScene = sut.currentScene

        workoutSessionManager.sendState(.error(nil))
        await Task.yield()
        XCTAssertNotEqual(currentScene, sut.currentScene)
        currentScene = sut.currentScene

        workoutSessionManager.sendState(.completed(.preview))
        await Task.yield()
        XCTAssertNotEqual(currentScene, sut.currentScene)
        currentScene = sut.currentScene
    }

    func testThatErrorsAreReported() async {
        await sut.appear()

        let error = StubDisplayableError(title: "Title 1", message: "Message 1")
        workoutSessionManager.sendState(.error(error))

        await Task.yield()
        XCTAssertNotNil(errorViewModel.currentError)
    }

    func testThatErrorActionClearsWorkout() async {
        await sut.appear()

        let error = StubDisplayableError(title: "Title 1", message: "Message 1")
        workoutSessionManager.sendState(.error(error))

        await Task.yield()
        errorViewModel.dismiss()

        await Task.yield()
        XCTAssertTrue(workoutSessionManager.didClearWorkout)
    }

    func testThatCompletingCountdownStartsWorkout() async {
        await sut.appear()
        await sut.didCompleteCountdown()

        XCTAssertTrue(workoutSessionManager.didStart)
    }
}
