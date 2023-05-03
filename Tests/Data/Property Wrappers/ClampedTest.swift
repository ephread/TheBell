//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
@testable import The_Bell

final class ClampedTest: XCTestCase {
    // MARK: Tests
    func testThatValuesAreClamped() {
        @Clamped(4...10) var value1
        @Clamped(-30...300) var value2

        @Clamped(0...0) var value3
        @Clamped(1...1) var value4

        value1 = 20
        value2 = -40
        value3 = 20
        value4 = -40

        XCTAssertEqual(value1, 10)
        XCTAssertEqual(value2, -30)
        XCTAssertEqual(value3, 0)
        XCTAssertEqual(value4, 1)

        value1 = 5
        value2 = 5
        value3 = 0
        value4 = 1

        XCTAssertEqual(value1, 5)
        XCTAssertEqual(value2, 5)

        XCTAssertEqual(value3, 0)
        XCTAssertEqual(value4, 1)

    }
}
