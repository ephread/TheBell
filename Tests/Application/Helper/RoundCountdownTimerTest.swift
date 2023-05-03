//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
@testable import The_Bell

@MainActor
final class RoundCountdownTimerTest: XCTestCase {
    // MARK: Properties
    private var counts: [TimeInterval] = []
    private var timer: RoundCountdownTimer!

    // MARK: Set up & Teardown
    override func setUp() async throws {
        try await super.setUp()
        counts = []
        timer = RoundCountdownTimer()
    }

    // MARK: Tests
    func testNominalCase() async throws {
        let tickExpectation = expectation(description: "The tracker ticked four times.")
        let negativeExpectation = expectation(description: "The tracker didn't tick four times.")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 3.2) { @MainActor in
            await self.timer.stop()

            // 4 because The time tracker notifies the current time
            // as soon as it starts (1 + 3 ticks).
            print(self.counts)
            if self.counts == [30, 29, 28, 27] {
                tickExpectation.fulfill()
            } else {
                negativeExpectation.fulfill()
            }
        }

        await timer.start(with: 30) { [weak self] timeInterval in
            self?.counts.append(timeInterval)
        }

        XCTAssertTrue(timer.isCountingDown)

        await fulfillment(of: [negativeExpectation], timeout: 4)
        await fulfillment(of: [tickExpectation], timeout: 4)
    }

    func testThatTrackerPausesAndThatMultipleCallsAreIgnored() async throws {
        let tickExpectation = expectation(description: "The tracker ticked five times.")

        let pauseExpectation = expectation(description: "isPause is true")
        let resumeExpectation = expectation(description: "isTracking is true")
        let stopExpectation = expectation(description: "isPause && isTracking are false")

        let negativeExpectation = expectation(description: "The tracker didn't tick five times.")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 2.1) { @MainActor in
            await self.timer.pause()
            await self.timer.pause()
            await self.timer.pause()

            if self.timer.isPaused && self.timer.isCountingDown {
                pauseExpectation.fulfill()
            }

            Task.delayed(seconds: 2.1) { @MainActor in
                await self.timer.resume()
                await self.timer.resume()
                await self.timer.resume()

                if !self.timer.isPaused && self.timer.isCountingDown {
                    resumeExpectation.fulfill()
                }

                Task.delayed(seconds: 1.1) { @MainActor in
                    await self.timer.stop()
                    await self.timer.stop()
                    await self.timer.stop()

                    if !self.timer.isPaused && !self.timer.isCountingDown {
                        stopExpectation.fulfill()
                    }

                    // 5 because The time tracker notifies the current time
                    // as soon as it starts, resumes and stops (1 + 2 + 1 + 1 ticks).
                    if self.counts == [30, 29, 28, 28, 27] {
                        tickExpectation.fulfill()
                    } else {
                        negativeExpectation.fulfill()
                    }
                }
            }
        }

        await timer.start(with: 30) { [weak self] time in
            self?.counts.append(time)
        }

        await fulfillment(of: [negativeExpectation], timeout: 6)
        await fulfillment(of: [tickExpectation], timeout: 6)

        await fulfillment(of: [pauseExpectation], timeout: 6)
        await fulfillment(of: [resumeExpectation], timeout: 6)
        await fulfillment(of: [stopExpectation], timeout: 6)
    }
}
