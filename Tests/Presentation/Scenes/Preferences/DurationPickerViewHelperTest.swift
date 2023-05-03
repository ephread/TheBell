//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

final class DurationPickerViewHelperTest: XCTestCase {
    // MARK: Properties
    private var sut: DurationPickerViewHelper!

    // MARK: Setup and Teardown
    override func setUp() {
        super.setUp()
        sut = DurationPickerViewHelper()
    }

    // MARK: Tests
    func testMakeMinuteOptionsEdgeCases() {
        let options = sut.makeMinuteOptions(range: 0...0, step: 10)
        XCTAssertEqual(options, [0])

        let options2 = sut.makeMinuteOptions(range: 0...10, step: 1)
        XCTAssertEqual(options2, [0])

        let options3 = sut.makeMinuteOptions(range: 0...10, step: Int.max)
        XCTAssertEqual(options3, [0])

        let options4 = sut.makeMinuteOptions(range: 0...60, step: 2)
        XCTAssertEqual(options4, [0])

        let options5 = sut.makeMinuteOptions(range: 60...60, step: 1)
        XCTAssertEqual(options5, [1])
    }

    func testMakeSecondOptionsEdgeCases() {
        let options = sut.makeSecondOptions(range: 0...0, step: 10)
        XCTAssertEqual(options, [0])

        let options2 = sut.makeSecondOptions(range: 0...10, step: Int.max)
        XCTAssertEqual(options2, [0])

        let options3 = sut.makeSecondOptions(range: 60...60, step: 1)
        XCTAssertEqual(options3, [60])
    }

    func testMakeSecondWithStepsGreaterThanOne() {
        let options = sut.makeSecondOptions(range: 3...44, step: 3)
        XCTAssertEqual(options, [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42])

        let options2 = sut.makeSecondOptions(range: 0...300, step: 10)
        XCTAssertEqual(options2, [0, 10, 20, 30, 40, 50])
    }

    func testMakeMinutesWithStepsGreaterThanOne() {
        let options2 = sut.makeMinuteOptions(range: 0...359, step: 2)
        XCTAssertEqual(options2, [0, 2, 4])

        let options2b = sut.makeMinuteOptions(range: 0...360, step: 2)
        XCTAssertEqual(options2b, [0, 2, 4, 6])

        let options3 = sut.makeMinuteOptions(range: 65...360, step: 2)
        XCTAssertEqual(options3, [1, 3, 5])
    }

    func testThatValidateAndUpdateTimeComponentsReturnsNilWhenComponentsAreValid() {
        let comps = sut.validateAndUpdateTimeComponents(range: 0...125, minutes: 2, seconds: 3)
        XCTAssertNil(comps)

        let comps2 = sut.validateAndUpdateTimeComponents(range: 0...0, minutes: 0, seconds: 0)
        XCTAssertNil(comps2)

        let comps3 = sut.validateAndUpdateTimeComponents(range: 60...60, minutes: 1, seconds: 0)
        XCTAssertNil(comps3)

        let comps4 = sut.validateAndUpdateTimeComponents(range: 60...60, minutes: 0, seconds: 60)
        XCTAssertNil(comps4)
    }

    func testThatValidateAndUpdateTimeComponentsUpdatesInvalidComponents() {
        let comps = sut.validateAndUpdateTimeComponents(range: 0...125, minutes: 3, seconds: 20)
        XCTAssertEqual(comps?.minutes, 2)
        XCTAssertEqual(comps?.seconds, 5)

        let comps2 = sut.validateAndUpdateTimeComponents(range: 10...20, minutes: 0, seconds: 2)
        XCTAssertEqual(comps2?.minutes, 0)
        XCTAssertEqual(comps2?.seconds, 10)
    }
}
