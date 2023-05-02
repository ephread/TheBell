//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults
import Logging

@testable import The_Bell

// MARK: - Main Test Class

// swiftlint:disable function_body_length
// Sinking publishers takes a lot of line.

@MainActor
final class WorkoutSessionManagerRecoveryTest: XCTestCase {
    // MARK: Properties
    private var hapticSoundManager: SpyHapticSoundManager!
    private var healthKitManager: MockSpyHealthKitManager!
    private var mainRepository: MockSpyMainRepository!
    private var countdownTimer: RoundCountdownTimer!
    private var elapsedTimeTracker: ElapsedTimeTracker!
    private var sut: WorkoutSessionManager!

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Set up & Teardown
    override func setUp() async throws {
        try await super.setUp()
        hapticSoundManager = SpyHapticSoundManager()
        healthKitManager = MockSpyHealthKitManager()
        mainRepository = MockSpyMainRepository(workout: .mock)
        countdownTimer = RoundCountdownTimer()
        elapsedTimeTracker = ElapsedTimeTracker()

        sut = WorkoutSessionManager(
            hapticSoundManager: hapticSoundManager,
            healthKitManager: healthKitManager,
            mainRepository: mainRepository,
            countdown: countdownTimer,
            elapsedTimeTracker: elapsedTimeTracker,
            logger: Logger(label: "")
        )

        cancellables.forEach { $0.cancel() }
        cancellables = []

        Defaults.removeAll()
    }

    // Session Recovery (Integration Tests)
    func testThatManagerInvokesHealthKitManagerWhenRecovering() async {
        await sut.tryToRecoverWorkout()

        let didRecover = await healthKitManager.didRecover
        XCTAssertTrue(didRecover)
    }

    func testThatManagerSetsItselfAsDelegateOfHealthKitManagerWhenRecovering() async {
        await sut.tryToRecoverWorkout()

        let delegate = await healthKitManager.delegate
        XCTAssertTrue(delegate === sut)
    }

    func testThatHealthKitErrorsAreForwardedWhenRecoveringAWorkout() async {
        let expectation = expectation(description: "An error is sent")

        sut.state
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { state in
                if case let .error(error) = state, error != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await healthKitManager.enableErrorTrigger()
        await sut.tryToRecoverWorkout()

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testThatWorkoutIsRecovered() async {
        let intervalTypeExpectation = expectation(description: "The interval type is '.round'")
        let stateExpectation = expectation(description: "The state is '.running'")
        let elapsedTimeExpectation = expectation(description: "The elapsed time is correct")
        let remainingTimeExpectation = expectation(description: "The remaining time is correct")

        sut.state
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { state in
                if case .running = state {
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.currentIntervalType
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { intervalType in
                if case let .round(currentRound, totalRound) = intervalType {
                    if currentRound == 1 && totalRound == 2 {
                        intervalTypeExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        sut.totalElapsedTime
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { totalElapsedTime in
                // Because it relies on Date.now, the elapsed time will never be  exact,
                // but it has to be within a second of the "real value".
                if let totalElapsedTime,
                   totalElapsedTime >= 50 && totalElapsedTime < 51 {
                    elapsedTimeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.remainingDuration
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { remainingDuration in
                if remainingDuration == 35 {
                    remainingTimeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        Defaults[.currentRound] = 1
        Defaults[.elapsedTimeInCurrentWorkout] = 50
        Defaults[.remainingDurationInCurrentRound] = 35
        Defaults[.isWorkoutInBetweenRounds] = false

        await sut.tryToRecoverWorkout()

        await fulfillment(
            of: [
                intervalTypeExpectation,
                stateExpectation,
                elapsedTimeExpectation,
                remainingTimeExpectation
            ],
            timeout: 2
        )
    }

    func testLastStretchWorkoutIsRecovered() async {
        let intervalTypeExpectation = expectation(description: "The interval type is '.round'")
        let stateExpectation = expectation(description: "The state is '.running'")
        let elapsedTimeExpectation = expectation(description: "The elapsed time is correct")
        let remainingTimeExpectation = expectation(description: "The remaining time is correct")

        sut.state
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { state in
                if case .running = state {
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.currentIntervalType
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { intervalType in
                if case let .lastSeconds(currentRound, totalRound) = intervalType {
                    if currentRound == 1 && totalRound == 2 {
                        intervalTypeExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        sut.totalElapsedTime
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { totalElapsedTime in
                // Because it relies on Date.now, the elapsed time will never be  exact,
                // but it has to be within a second of the "real value".
                if let totalElapsedTime,
                   totalElapsedTime >= 50 && totalElapsedTime < 51 {
                    elapsedTimeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.remainingDuration
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { remainingDuration in
                if remainingDuration == 5 {
                    remainingTimeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        Defaults[.currentRound] = 1
        Defaults[.elapsedTimeInCurrentWorkout] = 50
        Defaults[.remainingDurationInCurrentRound] = 5
        Defaults[.isWorkoutInBetweenRounds] = false

        await sut.tryToRecoverWorkout()

        await fulfillment(
            of: [
                intervalTypeExpectation,
                stateExpectation,
                elapsedTimeExpectation,
                remainingTimeExpectation
            ],
            timeout: 2
        )
    }

    func testInBetweenRoundWorkoutIsRecovered() async {
        let intervalTypeExpectation = expectation(description: "The interval type is '.round'")
        let stateExpectation = expectation(description: "The state is '.running'")
        let elapsedTimeExpectation = expectation(description: "The elapsed time is correct")
        let remainingTimeExpectation = expectation(description: "The remaining time is correct")

        sut.state
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { state in
                if case .running = state {
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.currentIntervalType
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { intervalType in
                if case let .break(currentRound, totalRound) = intervalType {
                    if currentRound == 1 && totalRound == 2 {
                        intervalTypeExpectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)

        sut.totalElapsedTime
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { totalElapsedTime in
                // Because it relies on Date.now, the elapsed time will never be  exact,
                // but it has to be within a second of the "real value".
                if let totalElapsedTime,
                   totalElapsedTime >= 50 && totalElapsedTime < 51 {
                    elapsedTimeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.remainingDuration
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { remainingDuration in
                if remainingDuration == 5 {
                    remainingTimeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        Defaults[.currentRound] = 1
        Defaults[.elapsedTimeInCurrentWorkout] = 50
        Defaults[.remainingDurationInCurrentRound] = 5
        Defaults[.isWorkoutInBetweenRounds] = true

        await sut.tryToRecoverWorkout()

        await fulfillment(
            of: [
                intervalTypeExpectation,
                stateExpectation,
                elapsedTimeExpectation,
                remainingTimeExpectation
            ],
            timeout: 2
        )
    }
}

// MARK: - Private Extensions
private extension Workout {
    static var mock: Workout {
        Workout(
            name: "DEFAULT",
            roundCount: 2,
            roundDuration: 60,
            lastStretchDuration: 10,
            breakDuration: 5
        )
    }
}
