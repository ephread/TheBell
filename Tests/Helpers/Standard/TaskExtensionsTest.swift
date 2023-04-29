//
// Copyright © 2020-2023 Frédéric Maquin <fred@ephread.com>
// Copyright © 2022 Łukasz Rutkowski
// All Rights Reserved
//

import XCTest
@testable import The_Bell

final class TaskExtensionsTest: XCTestCase {
    // MARK: Tests
    func testThatTaskExecutesAfterDelay() throws {
        let positiveExpectation = expectation(description: "Delayed task finished in time")
        let negativeExpectation = expectation(description: "Delayed task finished too early")
        negativeExpectation.isInverted = true

        Task.delayed(seconds: 0.2) {
            positiveExpectation.fulfill()
            negativeExpectation.fulfill()
        }

        wait(for: [negativeExpectation], timeout: 0.1)
        wait(for: [positiveExpectation], timeout: 0.15)
    }
}
