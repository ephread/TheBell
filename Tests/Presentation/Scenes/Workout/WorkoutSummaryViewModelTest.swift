//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest
import Combine
import Defaults

@testable import The_Bell

// MARK: - Main Class
@MainActor
final class WorkoutSummaryViewModelTest: XCTestCase {
    // MARK: Properties
    private var workoutSessionManager: MockSpyWorkoutSessionManager!
    private var sut: WorkoutSummaryViewModel!

    // MARK: Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()

        workoutSessionManager = MockSpyWorkoutSessionManager()
        sut = WorkoutSummaryViewModel(
            workoutSessionManager: workoutSessionManager,
            dateTimeHelper: DateTimeHelper()
        )
    }

    // MARK: Tests
    func testThatOnlyCompletionUpdatesSummary() async {
        let nilData = ViewModelData(viewModel: sut)
        await sut.appear()

        workoutSessionManager.sendState(.idle)
        await MainActor.run { XCTAssertEqual(nilData, ViewModelData(viewModel: sut)) }

        workoutSessionManager.sendState(.running)
        await MainActor.run { XCTAssertEqual(nilData, ViewModelData(viewModel: sut)) }

        workoutSessionManager.sendState(.paused)
        await MainActor.run { XCTAssertEqual(nilData, ViewModelData(viewModel: sut)) }

        workoutSessionManager.sendState(.error(nil))
        await MainActor.run { XCTAssertEqual(nilData, ViewModelData(viewModel: sut)) }

        workoutSessionManager.sendState(.completed(.preview))
        await MainActor.run { XCTAssertNotEqual(nilData, ViewModelData(viewModel: sut)) }
    }

    func testThatDismissingClearsTheCurrentWorkout() async {
        await sut.appear()
        await sut.dismiss()

        XCTAssertTrue(workoutSessionManager.didClearWorkout)
    }
}

// MARK: - Helpers
@MainActor
private struct ViewModelData: Equatable {
    let summaryTitle: String
    let completionPercentageLabel: String

    let totalDurationTitle: String
    let totalDurationLabel: String

    let activeEnergyTitle: String
    let activeEnergyLabel: String

    let totalEnergyTitle: String
    let totalEnergyLabel: String

    let energyUnitLabel: String

    let heartRateTitle: String
    let averageHeartRateLabel: String
    let heartRateUnitLabel: String
    let heartRateRangeTitle: String
    let heartRateRangeLabel: String

    let dateTitle: String
    let timeRangeLabel: String

    init(viewModel: WorkoutSummaryViewModel) {
        self.summaryTitle = viewModel.summaryTitle
        self.completionPercentageLabel = viewModel.completionPercentageLabel
        self.totalDurationTitle = viewModel.totalDurationTitle
        self.totalDurationLabel = viewModel.totalDurationLabel
        self.activeEnergyTitle = viewModel.activeEnergyTitle
        self.activeEnergyLabel = viewModel.activeEnergyLabel
        self.totalEnergyTitle = viewModel.totalEnergyTitle
        self.totalEnergyLabel = viewModel.totalEnergyLabel
        self.energyUnitLabel = viewModel.energyUnitLabel
        self.heartRateTitle = viewModel.heartRateTitle
        self.averageHeartRateLabel = viewModel.averageHeartRateLabel
        self.heartRateUnitLabel = viewModel.heartRateUnitLabel
        self.heartRateRangeTitle = viewModel.heartRateRangeTitle
        self.heartRateRangeLabel = viewModel.heartRateRangeLabel
        self.dateTitle = viewModel.dateTitle
        self.timeRangeLabel = viewModel.timeRangeLabel
    }
}
