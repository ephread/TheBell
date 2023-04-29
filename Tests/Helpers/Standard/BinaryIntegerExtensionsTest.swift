//
// Copyright © 2020-2023 Frédéric Maquin <fred@ephread.com>
// Copyright © 2022 Łukasz Rutkowski
// All Rights Reserved
//

import XCTest
@testable import The_Bell

final class BinaryIntegerExtensionsTest: XCTestCase {
    // MARK: Tests
    func testEdgeCases() throws {
        XCTAssertEqual(Int.max.roundedDown(toMultipleOf: Int.max), Int.max)
        XCTAssertEqual(Int.max.roundedDown(toMultipleOf: 1), Int.max)

        XCTAssertEqual((Int.max - 1).roundedDown(toMultipleOf: 1), Int.max - 1)
        XCTAssertEqual(Int.max.roundedDown(toMultipleOf: (Int.max - 1)), Int.max - 1)

        XCTAssertEqual(3.roundedDown(toMultipleOf: 0), 0)
        XCTAssertEqual(0.roundedDown(toMultipleOf: 3), 0)
        XCTAssertEqual(0.roundedDown(toMultipleOf: 0), 0)
        XCTAssertEqual(4.roundedDown(toMultipleOf: 76), 0)
    }

    func testNominalCase() throws {
        // Smoke Tests
        XCTAssertEqual(5.roundedDown(toMultipleOf: 5), 5)
        XCTAssertEqual(23.roundedDown(toMultipleOf: 5), 20)
        XCTAssertEqual(237_654.roundedDown(toMultipleOf: 3), 237_654)
    }
}
