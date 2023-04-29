//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

// Formatters are not tested.
final class DateTimeHelperTest: XCTestCase {
    // MARK: Properties
    private var sut: DateTimeHelper!

    // MARK: Setup and Teardown
    override func setUp() {
        super.setUp()
        sut = DateTimeHelper()
    }

    // MARK: Tests
    func testTimeComponentsEdgeCases() {
        let components1 = sut.timeComponents(from: 0)

        XCTAssertEqual(components1.hours, 0)
        XCTAssertEqual(components1.minutes, 0)
        XCTAssertEqual(components1.seconds, 0)

        let components2 = sut.timeComponents(from: TimeInterval.infinity)

        XCTAssertEqual(components2.hours, 0)
        XCTAssertEqual(components2.minutes, 0)
        XCTAssertEqual(components2.seconds, 0)

        let components3 = sut.timeComponents(from: TimeInterval.nan)

        XCTAssertEqual(components3.hours, 0)
        XCTAssertEqual(components3.minutes, 0)
        XCTAssertEqual(components3.seconds, 0)

        let components4 = sut.timeComponents(from: TimeInterval.leastNonzeroMagnitude)

        XCTAssertEqual(components4.hours, 0)
        XCTAssertEqual(components4.minutes, 0)
        XCTAssertEqual(components4.seconds, 0)

        let components5 = sut.timeComponents(from: TimeInterval.leastNormalMagnitude)

        XCTAssertEqual(components5.hours, 0)
        XCTAssertEqual(components5.minutes, 0)
        XCTAssertEqual(components5.seconds, 0)

        let components6 = sut.timeComponents(from: TimeInterval.greatestFiniteMagnitude)

        XCTAssertEqual(components6.hours, 0)
        XCTAssertEqual(components6.minutes, 0)
        XCTAssertEqual(components6.seconds, 0)

        let components7 = sut.timeComponents(from: TimeInterval(Int.max))

        XCTAssertEqual(components7.hours, 0)
        XCTAssertEqual(components7.minutes, 0)
        XCTAssertEqual(components7.seconds, 0)

        let components8 = sut.timeComponents(from: -8)

        XCTAssertEqual(components8.hours, 0)
        XCTAssertEqual(components8.minutes, 0)
        XCTAssertEqual(components8.seconds, 0)
    }

    func testTimeComponentsNominalCases() {
        let components = sut.timeComponents(from: 4)

        XCTAssertEqual(components.hours, 0)
        XCTAssertEqual(components.minutes, 0)
        XCTAssertEqual(components.seconds, 4)

        let components2 = sut.timeComponents(from: 60)

        XCTAssertEqual(components2.hours, 0)
        XCTAssertEqual(components2.minutes, 1)
        XCTAssertEqual(components2.seconds, 0)

        let components3 = sut.timeComponents(from: 61.5)

        XCTAssertEqual(components3.hours, 0)
        XCTAssertEqual(components3.minutes, 1)
        XCTAssertEqual(components3.seconds, 1)

        let components4 = sut.timeComponents(from: 3_599.4)

        XCTAssertEqual(components4.hours, 0)
        XCTAssertEqual(components4.minutes, 59)
        XCTAssertEqual(components4.seconds, 59)

        let components5 = sut.timeComponents(from: 3_600.45)

        XCTAssertEqual(components5.hours, 1)
        XCTAssertEqual(components5.minutes, 0)
        XCTAssertEqual(components5.seconds, 0)

        let components6 = sut.timeComponents(from: 9_223_372_036_854_774)

        XCTAssertEqual(components6.hours, 2_562_047_788_015)
        XCTAssertEqual(components6.minutes, 12)
        XCTAssertEqual(components6.seconds, 54)
    }
}
