//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults
import Logging

@testable import The_Bell

@MainActor
final class HapticSoundViewModelTest: XCTestCase {
    // MARK: Properties
    private var errorViewModel: ErrorViewModel!
    private var preferenceViewModel: StubPreferenceViewModel!
    private var sut: HapticSoundViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        errorViewModel = ErrorViewModel()
        preferenceViewModel = StubPreferenceViewModel()
        sut = HapticSoundViewModel(
            errorViewModel: errorViewModel,
            preferenceViewModel: preferenceViewModel,
            logger: Logger(label: "")
        )
    }

    // MARK: Tests
    func testThatModelIsRetrieved() async throws {
        preferenceViewModel.isAudioFeedbackEnabled = true
        preferenceViewModel.isHapticFeedbackEnabled = true
        preferenceViewModel.audioVolume = 0.45

        await sut.appear()

        XCTAssertTrue(sut.isAudioFeedbackEnabled)
        XCTAssertTrue(sut.isHapticFeedbackEnabled)
        XCTAssertEqual(sut.audioVolume, 0.45)
    }

    func testThatModelsAreSaved() async throws {
        await sut.appear()

        sut.audioVolume = 0.2
        sut.isAudioFeedbackEnabled = false
        sut.isHapticFeedbackEnabled = true

        XCTAssertEqual(preferenceViewModel.audioVolume, 0.2)
        XCTAssertFalse(preferenceViewModel.isAudioFeedbackEnabled)
        XCTAssertTrue(preferenceViewModel.isHapticFeedbackEnabled)
    }
}
