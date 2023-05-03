//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

@MainActor
final class WorkoutDashboardViewModelTest: XCTestCase {
    // MARK: Properties
    private var workoutSessionManager: MockSpyWorkoutSessionManager!
    private var mainRepository: MockSpyMainRepository!
    private var sut: WorkoutDashboardViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        workoutSessionManager = MockSpyWorkoutSessionManager()
        mainRepository = MockSpyMainRepository()
        sut = WorkoutDashboardViewModel(
            workoutManager: workoutSessionManager,
            mainRepository: mainRepository,
            dateTimeHelper: DateTimeHelper()
        )
    }

    // MARK: Tests
    func testThatEnergyUnitIsRetrieved() async {
        workoutSessionManager.setPreferredEnergyUnit(.joule)
        let calorieUnit = sut.totalCalorieUnit
        await sut.appear()
        XCTAssertNotEqual(sut.totalCalorieUnit, calorieUnit)
    }

    func testThatIntervalTypeIsUpdated() async {
        await sut.appear()

        var currentRound = sut.currentRound

        workoutSessionManager.sendCurrentIntervalType(.round(3, 4))
        await Task.yield()
        XCTAssertNotEqual(currentRound, sut.currentRound)
        currentRound = sut.currentRound

        workoutSessionManager.sendCurrentIntervalType(.break(3, 4))
        await Task.yield()
        XCTAssertNotEqual(currentRound, sut.currentRound)
        currentRound = sut.currentRound

        workoutSessionManager.sendCurrentIntervalType(.lastSeconds(3, 4))
        await Task.yield()
        XCTAssertNotEqual(currentRound, sut.currentRound)
    }

    func testThatRemainingTimeIsUpdated() async {
        await sut.appear()

        let nilRemainingTime = sut.remainingTime

        workoutSessionManager.sendRemainingDuration(300)
        await Task.yield()
        XCTAssertNotEqual(nilRemainingTime, sut.remainingTime)
    }

    func testThatActiveCaloriesAreUpdated() async {
        await sut.appear()

        let nilActiveCalories = sut.totalCalories

        workoutSessionManager.sendActiveCalories(50)
        await Task.yield()
        XCTAssertNotEqual(nilActiveCalories, sut.totalCalories)
    }

    func testThatHearRateIsUpdated() async {
        await sut.appear()

        let nilHeartRate = sut.currentHeartRate
        let nilHeartRateZone = sut.heartRateZone
        let nilHeartRateZoneColor = sut.heartRateZoneColor

        workoutSessionManager.sendCurrentHeartRate(HeartRate(measured: 170, maximum: 190))
        await Task.yield()
        XCTAssertNotEqual(nilHeartRate, sut.currentHeartRate)
        XCTAssertNotEqual(nilHeartRateZone, sut.heartRateZone)
        XCTAssertNotEqual(nilHeartRateZoneColor, sut.heartRateZoneColor)
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
        await Task.yield()
        currentVisibility = sut.isRemainingTimeVisible

        Task.delayed(seconds: 1.2) { @MainActor in
            let newVisibility = self.sut.isRemainingTimeVisible

            if currentVisibility != newVisibility {
                toggleCount += 1
                currentVisibility = newVisibility
            }

            Task.delayed(seconds: 1.2) { @MainActor in
                if currentVisibility != self.sut.isRemainingTimeVisible {
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
            if self.sut.isRemainingTimeVisible {
                negativeExpectation.fulfill()
            }

            self.workoutSessionManager.sendState(.running)
            Task.delayed(seconds: 0.1) { @MainActor in
                if self.sut.isRemainingTimeVisible {
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
        await Task.yield()
        currentVisibility = sut.isRemainingTimeVisible

        Task.delayed(seconds: 1.1) { @MainActor in
            let newVisibility = self.sut.isRemainingTimeVisible
            if currentVisibility != newVisibility {
                toggleCount += 1
                currentVisibility = newVisibility
            }

            Task.delayed(seconds: 1.1) { @MainActor in
                if currentVisibility != self.sut.isRemainingTimeVisible {
                    toggleCount += 1
                }

                if toggleCount == 0 && self.sut.isRemainingTimeVisible {
                    expectation.fulfill()
                }
            }
        }

        await fulfillment(of: [expectation], timeout: 3)
    }
}
