//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
@testable import The_Bell

// swiftlint:disable force_cast
// Rational: It's a test and we know for sure the error type.
@MainActor
final class ErrorViewModelTest: XCTestCase {
    // MARK: Properties
    private var viewModel: ErrorViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        viewModel = ErrorViewModel()
    }

    // MARK: Tests
    func testErrorSequence() throws {
        let error1 = StubDisplayableError(title: "Title 1", message: "Message 1")
        let error2 = StubDisplayableError(title: "Title 2", message: "Message 2")
        let error3 = StubDisplayableError(title: "Title 3", message: "Message 3")

        XCTAssertNil(viewModel.currentError)
        viewModel.push(error: error1)

        XCTAssertEqual(viewModel.currentError as! StubDisplayableError, error1)
        viewModel.push(error: error2)

        XCTAssertEqual(viewModel.currentError as! StubDisplayableError, error1)

        viewModel.dismiss()

        XCTAssertEqual(viewModel.currentError as! StubDisplayableError, error2)
        viewModel.push(error: error3)

        XCTAssertEqual(viewModel.currentError as! StubDisplayableError, error2)

        viewModel.dismiss()

        XCTAssertEqual(viewModel.currentError as! StubDisplayableError, error3)

        viewModel.dismiss()

        XCTAssertNil(viewModel.currentError)

        viewModel.dismiss()

        XCTAssertNil(viewModel.currentError)
    }

    func testThatActionIsCalled() throws {
        let error1 = StubDisplayableError(title: "Title 1", message: "Message 1")
        let error2 = StubDisplayableError(title: "Title 2", message: "Message 2")

        var didDismissError1 = false
        var didDismissError2 = false

        XCTAssertNil(viewModel.currentError)
        viewModel.push(error: error1) { @MainActor in didDismissError1 = true }
        viewModel.push(error: error2) { @MainActor in didDismissError2 = true }

        viewModel.dismiss()

        XCTAssertTrue(didDismissError1)

        viewModel.dismiss()

        XCTAssertTrue(didDismissError2)
    }
}
