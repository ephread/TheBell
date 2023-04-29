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

// swiftlint:disable file_length type_body_length
// rational: this is the biggest manager in the app. Splitting it
//           across multiple files would be confusing.

@MainActor
final class WorkoutSessionManagerTest: XCTestCase {
    // MARK: Properties
    private var hapticSoundManager: SpyHapticSoundManager!
    private var healthKitManager: MockSpyHealthKitManager!
    private var mainRepository: MockSpyMainRepository!
    private var countdownTimer: MockRoundCountdownTimer!
    private var elapsedTimeTracker: MockElapsedTimeTracker!
    private var sut: WorkoutSessionManager!

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Set up & Teardown
    override func setUp() async throws {
        try await super.setUp()
        hapticSoundManager = SpyHapticSoundManager()
        healthKitManager = MockSpyHealthKitManager()
        mainRepository = MockSpyMainRepository(userPreference: .mock, workout: .mock)
        countdownTimer = MockRoundCountdownTimer()
        elapsedTimeTracker = MockElapsedTimeTracker()

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

    // MARK: Workout Preparation Tests
    func testThatManagerConnectsToHealthKitManagerAndLoadsEnergyUnit() async {
        await sut.prepareWorkout()

        let isDelegateSet = await healthKitManager.delegate != nil
        let isPreferredEnergyUnitSet = sut.preferredEnergyUnit == .joule

        XCTAssertTrue(isDelegateSet)
        XCTAssertTrue(isPreferredEnergyUnitSet)
    }

    // MARK: Workout Tests
    func testThatWorkoutStarts() async {
        await sut.prepareWorkout()
        await sut.startWorkout()

        let didCallDiscardPreviousWorkout = await healthKitManager.didDiscardPreviousWorkout
        XCTAssertTrue(didCallDiscardPreviousWorkout)
        XCTAssertTrue(countdownTimer.didStartCountdown)
        XCTAssertTrue(elapsedTimeTracker.didStart)
    }

    func testThatWorkoutPauses() async {
        await sut.prepareWorkout()
        await sut.startWorkout()
        await sut.pauseWorkout()

        let didPause = await healthKitManager.didPause
        XCTAssertTrue(didPause)
        XCTAssertTrue(countdownTimer.didPause)
        XCTAssertTrue(elapsedTimeTracker.didPause)
        XCTAssertTrue(hapticSoundManager.didNotifyUser)
    }

    func testThatWorkoutResumes() async {
        await sut.prepareWorkout()
        await sut.startWorkout()
        await sut.pauseWorkout()
        await sut.resumeWorkout()

        let didResume = await healthKitManager.didResume
        XCTAssertTrue(didResume)
        XCTAssertTrue(countdownTimer.didResume)
        XCTAssertTrue(elapsedTimeTracker.didResume)
        XCTAssertTrue(hapticSoundManager.didNotifyUser)
    }

    func testThatWorkoutEnds() async {
        await sut.prepareWorkout()
        await sut.startWorkout()
        await sut.endWorkout()

        let didEnd = await healthKitManager.didEnd
        XCTAssertTrue(didEnd)
        XCTAssertTrue(countdownTimer.didStop)
        XCTAssertTrue(elapsedTimeTracker.didStop)
        XCTAssertTrue(hapticSoundManager.didNotifyUser)

        XCTAssertTrue(countdownTimer.didReset)
        XCTAssertTrue(elapsedTimeTracker.didReset)
    }

    // MARK: Combine Subscription Tests
    func testThatElapsedTimeIsSentAndSave() async {
        let sentExpectation = expectation(description: "'totalElapsedTime' is sent")
        let saveExpectation = expectation(description: "'totalElapsedTime' is saved")

        sut.totalElapsedTime
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { timeInterval in
                if timeInterval == 30 {
                    sentExpectation.fulfill()
                }

                if Defaults[.elapsedTimeInCurrentWorkout] == 30 {
                    saveExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()
        await elapsedTimeTracker.setElapsedTime(30)
        await fulfillment(of: [sentExpectation, saveExpectation], timeout: 2)
    }

    func testThatRemainingDurationIsSavedWhenZero() async {
        await sut.prepareWorkout()
        await sut.startWorkout()
        await countdownTimer.setDuration(0)
        await Task.yield()

        XCTAssertEqual(Defaults[.remainingDurationInCurrentRound], 0)
    }

    func testThatRemainingDurationIsSentAndSavedWhenNotZero() async {
        let sentExpectation = expectation(description: "'remainingDuration' is sent")
        let saveExpectation = expectation(description: "'remainingDuration' is saved")

        sut.remainingDuration
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { timeInterval in
                if timeInterval == 4 {
                    sentExpectation.fulfill()
                }

                if Defaults[.remainingDurationInCurrentRound] == 4 {
                    saveExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()
        await countdownTimer.setDuration(4)
        await fulfillment(of: [sentExpectation, saveExpectation], timeout: 2)
    }

    func testThatHeartRateIsSent() async {
        let expectation = expectation(description: "'currentHeartRate' is sent")

        sut.currentHeartRate
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { heartRate in
                if heartRate == HeartRate(measured: 90, maximum: 200) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()
        await healthKitManager.setCurrentHeartRate(90)
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testThatActiveCaloriesAreSent() async {
        let expectation = expectation(description: "'currentHeartRate' is sent")

        sut.activeCalories
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { activeCalorie in
                if activeCalorie == 30 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()
        await healthKitManager.setActiveCalorie(30)
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testThatPreferredUnitIsReceived() async {
        await sut.prepareWorkout()
        await sut.startWorkout()
        await healthKitManager.setPreferredEnergyUnit(.kilojoule)

        XCTAssertEqual(sut.preferredEnergyUnit, .kilojoule)
    }

    // MARK: Round Progression Tests
    func testThatRoundLeadsToBreak() async {
        let expectation = expectation(description: "Interval Type is a break")

        sut.currentIntervalType
            .receive(on: DispatchQueue.main)
            .dropFirst(2) // 0. -> nil (current value) | 1. -> .round (start)
            .sink { intervalType in
                if case let .break(currentRound, roundCount) = intervalType,
                   currentRound == 0, roundCount == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()

        await countdownTimer.setDuration(0)

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testThatBreakLeadsToNextRound() async {
        let expectation = expectation(description: "Round is increased")

        sut.currentIntervalType
            .receive(on: DispatchQueue.main)
            .dropFirst(3) // 0. -> nil (current value) | 1. -> .round (start) | 2. -> .break
            .sink { intervalType in
                if case let .round(currentRound, roundCount) = intervalType,
                   currentRound == 1, roundCount == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()

        await countdownTimer.setDuration(0) // End of First Round
        await countdownTimer.setDuration(0) // End of Break

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testManagerNotifiesAboutTheFinalStage() async {
        let expectation = expectation(description: "Round reached last Stretch")

        sut.currentIntervalType
            .receive(on: DispatchQueue.main)
            .dropFirst(2) // 0. -> nil (current value) | 1. -> .round (start)
            .sink { intervalType in
                if case let .lastSeconds(currentRound, roundCount) = intervalType,
                   currentRound == 0, roundCount == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await sut.prepareWorkout()
        await sut.startWorkout()

        await countdownTimer.setDuration(10) // Last Stage

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testRoundSequence() async {
        await sut.prepareWorkout()
        await sut.startWorkout()

        await countdownTimer.setDuration(0) // End of First Round
        await countdownTimer.setDuration(0) // End of Break
        await countdownTimer.setDuration(0) // End of Second Round

        switch sut.state.value {
        case .completed:
            break
        default:
            XCTFail("The workout didn't end.")
        }
    }

    func testThatRoundDataIsSaved() async {
        await sut.prepareWorkout()
        await sut.startWorkout()

        await countdownTimer.setDuration(9) // Last Seconds

        XCTAssertEqual(Defaults[.remainingDurationInCurrentRound], 9)

        await countdownTimer.setDuration(0) // End of First Round

        XCTAssertEqual(Defaults[.currentRound], 0)
        XCTAssertEqual(Defaults[.remainingDurationInCurrentRound], 0)
        XCTAssertNotNil(Defaults[.isWorkoutInBetweenRounds])
        if let isWorkoutInBetweenRounds = Defaults[.isWorkoutInBetweenRounds] {
            XCTAssertTrue(isWorkoutInBetweenRounds)
        }

        await countdownTimer.setDuration(0) // End of break

        XCTAssertEqual(Defaults[.currentRound], 1)
        XCTAssertNotNil(Defaults[.isWorkoutInBetweenRounds])
        if let isWorkoutInBetweenRounds = Defaults[.isWorkoutInBetweenRounds] {
            XCTAssertFalse(isWorkoutInBetweenRounds)
        }
    }

    // MARK: Error Management Tests
    func testThatStartingAWorkoutMultipleTimesTriggersAnError() async {
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

        await sut.prepareWorkout()
        await sut.startWorkout()
        await sut.startWorkout()

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testThatHealthKitErrorsAreForwardedWhenStartingAWorkout() async {
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

        await sut.prepareWorkout()

        await healthKitManager.enableErrorTrigger()
        await sut.startWorkout()

        await fulfillment(of: [expectation], timeout: 1)
    }

    func testThatHealthKitErrorsAreForwardedWhenEndingAWorkout() async {
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

        await sut.prepareWorkout()
        await sut.startWorkout()

        await healthKitManager.enableErrorTrigger()
        await sut.endWorkout()

        await fulfillment(of: [expectation], timeout: 1)
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
        await sut.recoverWorkout()

        await fulfillment(of: [expectation], timeout: 1)
    }
}

// MARK: - Private Extensions
private extension UserPreference {
    static var mock: UserPreference {
        UserPreference(
            isAudioFeedbackEnabled: true,
            isHapticFeedbackEnabled: true,
            maximumHeartRate: 200,
            audioVolume: 0.8
        )
    }
}

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
