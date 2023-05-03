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
    private var mainViewModel: MockSpyHomeViewModel!
    private var errorViewModel: ErrorViewModel!

    private var sut: WelcomeViewModel!

    private var isRequestingAccess = false

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        healthkitManager = MockSpyHealthKitManager()
        mainViewModel = MockSpyHomeViewModel()
        errorViewModel = ErrorViewModel()
        sut = WelcomeViewModel(
            mainViewModel: mainViewModel,
            errorViewModel: errorViewModel,
            healthkitManager: healthkitManager
        )

        cancellables.forEach { $0.cancel() }
        cancellables = []
    }

    // MARK: Tests
    func testThatRequestingPermissionsSetsKeyToTrue() async {
        await sut.requestAccessToHealthStore()
        XCTAssertTrue(Defaults[.hasSeenWelcomeMessage])
    }

    func testThatRequestingPermissionsDoesNotTriggerAnError() async {
        await sut.requestAccessToHealthStore()
        XCTAssertNil(errorViewModel.currentError)
    }

    func testThatHealthKitErrorsAreDisplayed() async {
        await healthkitManager.enableErrorTrigger()
        await sut.requestAccessToHealthStore()
        XCTAssertNotNil(errorViewModel.currentError)
    }

    func testThatWelcomeViewIsDismissedOncePermissionsAreGrantedOrRefused() async {
        mainViewModel.setIsWelcomeMessageDisplayed(true)
        await sut.requestAccessToHealthStore()
        XCTAssertTrue(mainViewModel.didCallOnboardingDidComplete)
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

        sut.$isRequestingAccessToTheHealthStore
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
        await self.sut.requestAccessToHealthStore()

        await fulfillment(of: [expectation], timeout: 2)
        await MainActor.run { XCTAssertFalse(sut.isRequestingAccessToTheHealthStore) }
    }
}
