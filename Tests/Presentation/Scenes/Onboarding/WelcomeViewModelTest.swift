//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

@MainActor
final class WelcomeViewModelTest: XCTestCase {
    // MARK: Properties
    private var healthkitManager: MockSpyHealthKitManager!
    private var mainViewModel: MockMainViewModel!
    private var errorViewModel: ErrorViewModel!

    private var viewModel: WelcomeViewModel!

    private var isRequestingAccess = false

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        healthkitManager = MockSpyHealthKitManager()
        mainViewModel = MockMainViewModel()
        errorViewModel = ErrorViewModel()
        viewModel = WelcomeViewModel(
            mainViewModel: mainViewModel,
            errorViewModel: errorViewModel,
            healthkitManager: healthkitManager
        )

        cancellables.forEach { $0.cancel() }
        cancellables = []
    }

    // MARK: Tests
    func testThatRequestingPermissionsSetsKeyToTrue() async {
        await viewModel.requestAccessToHealthStore()
        XCTAssertTrue(Defaults[.hasSeenWelcomeMessage])
    }

    func testThatRequestingPermissionsDoesNotTriggerAnError() async {
        await viewModel.requestAccessToHealthStore()
        XCTAssertNil(errorViewModel.currentError)
    }

    func testThatHealthKitErrorsAreDisplayed() async {
        await healthkitManager.enableErrorTrigger()
        await viewModel.requestAccessToHealthStore()
        XCTAssertNotNil(errorViewModel.currentError)
    }

    func testThatWelcomeViewIsHiddenOncePermissionsAreRequested() async {
        mainViewModel.setIsWelcomeMessageDisplayed(true)
        await viewModel.requestAccessToHealthStore()
        await MainActor.run { XCTAssertFalse(mainViewModel.isWelcomeMessageDisplayed) }
    }

    func testThatUserInteractionIsDisabledWhenRequestingPermissionsWithoutError() async {
        await healthkitManager.enableDelayWhenRequestingPermissions()
        await _testThatUserInteractionIsDisabledWhenRequestingPermissions()
    }

    func testThatUserInteractionIsDisabledWhenRequestingPermissionsWithError() async {
        await healthkitManager.enableDelayWhenRequestingPermissions()
        await healthkitManager.enableErrorTrigger()
        await _testThatUserInteractionIsDisabledWhenRequestingPermissions()
    }

    // MARK: Private Test Helpers
    private func _testThatUserInteractionIsDisabledWhenRequestingPermissions() async {
        let expectation = expectation(
            description: "User Interaction is disabled when requesting permissions."
        )

        viewModel.$isRequestingAccessToTheHealthStore
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] value in
                guard let self else { return }
                if value && isRequestingAccess {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        isRequestingAccess = true
        await self.viewModel.requestAccessToHealthStore()

        await fulfillment(of: [expectation], timeout: 2)
        await MainActor.run { XCTAssertFalse(viewModel.isRequestingAccessToTheHealthStore) }
    }
}
