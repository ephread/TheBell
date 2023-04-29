//
// Copyright © 2020-2023 Frédéric Maquin <fred@ephread.com>
// Copyright © 2022 Łukasz Rutkowski
// All Rights Reserved
//

import XCTest
@testable import The_Bell

@MainActor
final class RepeatingTimerExtensionsTest: XCTestCase {
    // MARK: Properties
    private var numberOfTicks = 0
    private var timer: RepeatingTimer?

    // MARK: Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        numberOfTicks = 0
    }

    // MARK: Tests
    func testThatTimerTicksAppropriately() async throws {
        let positiveExpectation = expectation(description: "The timer ticked three times.")
        let negativeExpectation = expectation(description: "The timer didn't tick three times.")
        negativeExpectation.isInverted = true

        timer = RepeatingTimer(timeInterval: 0.1) { [weak self] in
            self?.numberOfTicks += 1
        }

        Task.delayed(seconds: 0.35) {
            if await self.numberOfTicks == 3 {
                positiveExpectation.fulfill()
            } else {
                negativeExpectation.fulfill()
            }

            await self.timer?.cancel()
        }

        await timer?.start()

        await fulfillment(of: [negativeExpectation], timeout: 0.4)
        await fulfillment(of: [positiveExpectation], timeout: 0.4)
    }

    func testThatTimerCancels() async throws {
        let positiveExpectation = expectation(description: "The timer ticked only twice.")
        let negativeExpectation = expectation(description: "The timer didn't tick twice.")
        negativeExpectation.isInverted = true

        timer = RepeatingTimer(timeInterval: 0.1) { [weak self] in
            self?.numberOfTicks += 1
        }

        Task.delayed(seconds: 0.22) {
            await self.timer?.cancel()
        }

        Task.delayed(seconds: 0.50) {
            if await self.numberOfTicks == 2 {
                positiveExpectation.fulfill()
            } else {
                negativeExpectation.fulfill()
            }

            await self.timer?.cancel()
        }

        await timer?.start()

        await fulfillment(of: [negativeExpectation], timeout: 0.6)
        await fulfillment(of: [positiveExpectation], timeout: 0.6)
    }
}
