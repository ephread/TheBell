//
// Copyright © 2020-2023 Frédéric Maquin <fred@ephread.com>
// Copyright © 2022 Łukasz Rutkowski
// All Rights Reserved
//

import XCTest
@testable import The_Bell

@MainActor
final class ElapsedTimeTrackerTest: XCTestCase {
    // MARK: Properties
    private var elapsedTimes: [TimeInterval] = []
    private var elapsedTimeTracker: ElapsedTimeTracker!

    // MARK: Set up & Teardown
    override func setUp() async throws {
        try await super.setUp()
        elapsedTimes = []
        elapsedTimeTracker = ElapsedTimeTracker()
    }

    // MARK: Tests
    func testThatElapsedTimeIsZeroWhenNotStarted() async {
        let elapsedTime = await elapsedTimeTracker.elapsedTime
        XCTAssertEqual(elapsedTime, 0)
    }

    func testDefaultInit() async throws {
        let tickExpectation = expectation(description: "The tracker ticked five times")
        let negativeExpectation = expectation(description: "The tracker didn't tick five times")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 3.2) { @MainActor in
            await self.elapsedTimeTracker.stopTracking()

            print(self.elapsedTimes)

            // 5 because The time tracker notifies the current time
            // when it starts and stops. (1 + 3 + 1 ticks).
            if self.elapsedTimes.count == 5 {
                tickExpectation.fulfill()
            } else {
                negativeExpectation.fulfill()
            }
        }

        await elapsedTimeTracker.startTracking(from: .now) { [weak self] timeInterval in
            self?.elapsedTimes.append(timeInterval)
        }

        await fulfillment(of: [negativeExpectation], timeout: 4)
        await fulfillment(of: [tickExpectation], timeout: 4)
    }

    func testPastDateInit() async throws {
        let tickExpectation = expectation(description: "The tracker ticked five times")
        let valueExpectation = expectation(description: "The time values are above 4,000")
        let negativeExpectation = expectation(description: "The tracker didn't tick five times")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 3.2) { @MainActor in
            await self.elapsedTimeTracker.stopTracking()

            // 5 because The time tracker notifies the current time
            // when it starts and stops. (1 + 3 + 1 ticks).
            if self.elapsedTimes.count == 5 {
                tickExpectation.fulfill()
            } else {
                negativeExpectation.fulfill()
            }

            if (self.elapsedTimes.allSatisfy { $0 >= 4_000 }) {
                valueExpectation.fulfill()
            }
        }

        await elapsedTimeTracker.startTracking(
            from: .now.addingTimeInterval(-4_000)
        ) { [weak self] timeInterval in
            self?.elapsedTimes.append(timeInterval)
        }

        await fulfillment(of: [negativeExpectation], timeout: 4)
        await fulfillment(of: [tickExpectation], timeout: 4)
        await fulfillment(of: [valueExpectation], timeout: 4)
    }

    func testTimeIntervalInit() async throws {
        let tickExpectation = expectation(description: "The tracker ticked five times")
        let valueExpectation = expectation(description: "The time values are above 300")
        let negativeExpectation = expectation(description: "The tracker didn't tick five times")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 3.2) { @MainActor in
            await self.elapsedTimeTracker.stopTracking()

            // 5 because The time tracker notifies the current time
            // when it starts and stops. (1 + 3 + 1 ticks).
            if self.elapsedTimes.count == 5 {
                tickExpectation.fulfill()
            } else {
                negativeExpectation.fulfill()
            }

            if (self.elapsedTimes.allSatisfy { $0 >= 300 }) {
                valueExpectation.fulfill()
            }
        }

        await elapsedTimeTracker.startTracking(from: 300) { [weak self] timeInterval in
            self?.elapsedTimes.append(timeInterval)
        }

        await fulfillment(of: [negativeExpectation], timeout: 4)
        await fulfillment(of: [tickExpectation], timeout: 4)
        await fulfillment(of: [valueExpectation], timeout: 4)
    }

    func testThatTrackerPausesAndThatMultipleCallsAreIgnored() async throws {
        let tickExpectation = expectation(description: "The tracker ticked six times")
        let valueExpectation = expectation(description: "The last time values is between 3s and 4s")

        let pauseExpectation = expectation(description: "'isPause' is true")
        let resumeExpectation = expectation(description: "'isTracking' is true")
        let stopExpectation = expectation(description: "'isPause' and 'isTracking' are false")

        let negativeExpectation = expectation(description: "The tracker didn't tick six times.")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 2.1) { @MainActor in
            await self.elapsedTimeTracker.pauseTracking()
            await self.elapsedTimeTracker.pauseTracking()
            await self.elapsedTimeTracker.pauseTracking()

            if self.elapsedTimeTracker.isPaused && self.elapsedTimeTracker.isTracking {
                pauseExpectation.fulfill()
            }

            Task.delayed(seconds: 2.1) { @MainActor in
                await self.elapsedTimeTracker.resumeTracking()
                await self.elapsedTimeTracker.resumeTracking()
                await self.elapsedTimeTracker.resumeTracking()

                if !self.elapsedTimeTracker.isPaused && self.elapsedTimeTracker.isTracking {
                    resumeExpectation.fulfill()
                }

                Task.delayed(seconds: 1.1) { @MainActor in
                    await self.elapsedTimeTracker.stopTracking()
                    await self.elapsedTimeTracker.stopTracking()
                    await self.elapsedTimeTracker.stopTracking()

                    if !self.elapsedTimeTracker.isPaused && !self.elapsedTimeTracker.isTracking {
                        stopExpectation.fulfill()
                    }

                    
                    // 6 because The time tracker notifies the current time
                    // as soon as it starts, resumes and stops (1 + 2 + 1 + 1 + 1 ticks).
                    if self.elapsedTimes.count == 6 {
                        tickExpectation.fulfill()
                    } else {
                        negativeExpectation.fulfill()
                    }

                    // The tracker accounts for the time paused, so the
                    // last value is between 3s and 4s (and not between 5s and 6s).
                    if (3...4).contains(self.elapsedTimes.last!) {
                        valueExpectation.fulfill()
                    }
                }
            }
        }

        await elapsedTimeTracker.startTracking(from: .now) { [weak self] timeInterval in
            self?.elapsedTimes.append(timeInterval)
        }

        await fulfillment(of: [negativeExpectation], timeout: 6)
        await fulfillment(of: [tickExpectation], timeout: 6)
        await fulfillment(of: [valueExpectation], timeout: 6)

        await fulfillment(of: [pauseExpectation], timeout: 6)
        await fulfillment(of: [resumeExpectation], timeout: 6)
        await fulfillment(of: [stopExpectation], timeout: 6)
    }

    func testThatElapsedTimeDoesNotChangeAfterStopping() async throws {
        let tickExpectation = expectation(description: "The tracker stopped ticking")
        let elapsedExpectation = expectation(
            description: "The tracker's 'elapsedTime' equals the last time sent"
        )

        Task.delayed(seconds: 2.2) { @MainActor in
            await self.elapsedTimeTracker.stopTracking()

            let elapsedTimeCount: Int = self.elapsedTimes.count

            Task.delayed(seconds: 2) { @MainActor in
                if elapsedTimeCount == self.elapsedTimes.count {
                    tickExpectation.fulfill()
                }

                if await self.elapsedTimes.last == self.elapsedTimeTracker.elapsedTime {
                    elapsedExpectation.fulfill()
                }
            }
        }

        await elapsedTimeTracker.startTracking(from: .now) { [weak self] timeInterval in
            self?.elapsedTimes.append(timeInterval)
        }

        await fulfillment(of: [tickExpectation], timeout: 5)
        await fulfillment(of: [elapsedExpectation], timeout: 5)
    }
}
