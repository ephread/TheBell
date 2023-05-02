//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

@MainActor
final class WorkoutControlViewModelTest: XCTestCase {
    // MARK: Properties
    private var workoutSessionManager: MockSpyWorkoutSessionManager!
    private var sut: WorkoutControlViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        workoutSessionManager = MockSpyWorkoutSessionManager()
        sut = WorkoutControlViewModel(
            dateTimeHelper: DateTimeHelper(),
            workoutManager: workoutSessionManager
        )
    }

    // MARK: Tests
    func testThatElapsedTimeIsUpdated() async {
        await sut.appear()

        let nilElapsedTime = sut.elapsedTime

        workoutSessionManager.sendTotalElapsedTime(300)
        await Task.yield()
        XCTAssertNotEqual(nilElapsedTime, sut.elapsedTime)
    }

    func testThatWorkoutIsPaused() async {
        await sut.appear()

        workoutSessionManager.sendState(.idle)
        await Task.yield()
        XCTAssertFalse(sut.isWorkoutPaused)

        workoutSessionManager.sendState(.running)
        await Task.yield()
        XCTAssertFalse(sut.isWorkoutPaused)

        workoutSessionManager.sendState(.paused)
        await Task.yield()
        XCTAssertTrue(sut.isWorkoutPaused)

        workoutSessionManager.sendState(.error(nil))
        await Task.yield()
        XCTAssertFalse(sut.isWorkoutPaused)

        workoutSessionManager.sendState(.completed(.preview))
        await Task.yield()
        XCTAssertFalse(sut.isWorkoutPaused)
    }

    func testThatWorkoutIsStarted() async {
        await sut.appear()

        XCTAssertFalse(sut.isWorkoutStarted)

        workoutSessionManager.sendState(.idle)
        await Task.yield()
        XCTAssertTrue(sut.isWorkoutStarted)

        workoutSessionManager.sendState(.running)
        await Task.yield()
        XCTAssertTrue(sut.isWorkoutStarted)

        workoutSessionManager.sendState(.paused)
        await Task.yield()
        XCTAssertTrue(sut.isWorkoutStarted)

        workoutSessionManager.sendState(.error(nil))
        await Task.yield()
        XCTAssertTrue(sut.isWorkoutStarted)

        workoutSessionManager.sendState(.completed(.preview))
        await Task.yield()
        XCTAssertTrue(sut.isWorkoutStarted)
    }

    func testThatPausingPausesTheWorkout() async {
        await sut.appear()
        workoutSessionManager.sendState(.running)

        await sut.pauseResumeWorkout()
        XCTAssertTrue(workoutSessionManager.didPause)
        XCTAssertFalse(workoutSessionManager.didResume)
    }

    func testThatResumingResumesTheWorkout() async {
        await sut.appear()
        workoutSessionManager.sendState(.paused)

        await Task.yield()
        await sut.pauseResumeWorkout()
        XCTAssertTrue(workoutSessionManager.didResume)
        XCTAssertFalse(workoutSessionManager.didPause)
    }

    func testThatEndingEndsTheWorkout() async {
        await sut.appear()
        workoutSessionManager.sendState(.running)

        await Task.yield()
        await sut.endWorkout()
        XCTAssertTrue(workoutSessionManager.didEnd)
    }

    func testThatEndingWhenNoWorkoutIsStartedDoesNothing() async {
        await sut.appear()
        await sut.endWorkout()
        XCTAssertFalse(workoutSessionManager.didEnd)
    }

    // MARK: Controversial Tests (timing)
    // These tests might exhibit timing issues, but if they do, this is concerning
    // so I think they have values.
    func testThatElapsedTimeVisibilityChangesWhenPaused() async {
        let expectation = expectation(
            description: "isElapsedTimeVisible was toggled at least twice"
        )

        await sut.appear()

        var toggleCount = 0
        var currentVisibility = false
        workoutSessionManager.sendState(.paused)
        await MainActor.run { currentVisibility = sut.isElapsedTimeVisible }

        Task.delayed(seconds: 1.2) { @MainActor in
            let newVisibility = self.sut.isElapsedTimeVisible

            if currentVisibility != newVisibility {
                toggleCount += 1
                currentVisibility = newVisibility
            }

            Task.delayed(seconds: 1.2) { @MainActor in
                if currentVisibility != self.sut.isElapsedTimeVisible {
                    toggleCount += 1
                }

                if toggleCount >= 2 {
                    expectation.fulfill()
                }
            }
        }

        await fulfillment(of: [expectation], timeout: 3)
    }

    // TODO: Improve this flaky test in the future, because it relies on a time delay (0.1).
    //       This is because `workoutSessionManager` updates are received synchronously,
    //       while `isElapsedTimeVisible` is updated asynchronously.
    //       The test is not critical and is disabled for now.
    func xtestThatResumingMakeElapsedTimeVisible() async {
        let positiveExpectation = expectation(description: "isElapsedTimeVisible is visible")
        let negativeExpectation = expectation(description: "isElapsedTimeVisible is visible")
        negativeExpectation.isInverted = true

        await sut.appear()

        workoutSessionManager.sendState(.paused)
        Task.delayed(seconds: 1.2) { @MainActor in
            if self.sut.isElapsedTimeVisible {
                negativeExpectation.fulfill()
            }

            self.workoutSessionManager.sendState(.running)
            Task.delayed(seconds: 0.1) { @MainActor in
                if self.sut.isElapsedTimeVisible {
                    positiveExpectation.fulfill()
                }
            }
        }

        await fulfillment(of: [positiveExpectation], timeout: 2.0)
        await fulfillment(of: [negativeExpectation], timeout: 2.0)
    }

    func testThatElapsedTimeVisibilityDoesNotChangesWhenNotPaused() async {
        let expectation = expectation(
            description: "isElapsedTimeVisible was never toggled and is visible."
        )

        await sut.appear()

        var toggleCount = 0
        var currentVisibility = false
        workoutSessionManager.sendState(.running)
        await MainActor.run { currentVisibility = sut.isElapsedTimeVisible }

        Task.delayed(seconds: 1.1) { @MainActor in
            let newVisibility = self.sut.isElapsedTimeVisible
            if currentVisibility != newVisibility {
                toggleCount += 1
                currentVisibility = newVisibility
            }

            Task.delayed(seconds: 1.1) { @MainActor in
                if currentVisibility != self.sut.isElapsedTimeVisible {
                    toggleCount += 1
                }

                if toggleCount == 0 && self.sut.isElapsedTimeVisible {
                    expectation.fulfill()
                }
            }
        }

        await fulfillment(of: [expectation], timeout: 3)
    }
}
