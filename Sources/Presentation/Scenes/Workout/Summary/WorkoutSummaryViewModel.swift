//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Combine

// MARK: - Protocols
/// Provides data to the workout summary view.
/// Properties should be self-explanatory.
@MainActor
protocol WorkoutSummaryViewModeling: ObservableObject {
    // MARK: Properties
    var summaryTitle: String { get }
    var completionPercentageLabel: String { get }

    var totalDurationTitle: String { get }
    var totalDurationLabel: String { get }

    var activeEnergyTitle: String { get }
    var activeEnergyLabel: String { get }

    var totalEnergyTitle: String { get }
    var totalEnergyLabel: String { get }

    var energyUnitLabel: String { get }

    var heartRateTitle: String { get }
    var averageHeartRateLabel: String { get }
    var heartRateUnitLabel: String { get }
    var heartRateRangeTitle: String { get }
    var heartRateRangeLabel: String { get }

    var dateTitle: String { get }
    var timeRangeLabel: String { get }

    // MARK: Methods
    func dismiss() async
}

// MARK: - Main Class
class WorkoutSummaryViewModel: WorkoutSummaryViewModeling {
    // MARK: Properties
    var summaryTitle: String {
        L10n.Workout.Summary.subtitle
    }

    var completionPercentageLabel: String {
        guard let summary = summary else { return L10n.Placeholder.percentageValue }

        let percentage = Int(min(1, summary.totalDuration / summary.expectedTotalDuration)) * 100
        return L10n.Workout.Summary.percentageOfCompletion(percentage)
    }

    var totalDurationTitle: String {
        L10n.Workout.Summary.Title.totalTime.uppercased()
    }

    var totalDurationLabel: String {
        guard let summary = summary else { return L10n.Placeholder.value }

        let components = dateTimeHelper.timeComponents(from: summary.totalDuration)

        return L10n.Workout.Summary.Label.totalTime(
            components.hours,
            components.minutes,
            components.seconds
        )
    }

    var activeEnergyTitle: String {
        guard let summary = summary else { return L10n.Placeholder.value }

        return L10n.Workout.Unit.active(summary.energyUnit).uppercased()
    }

    var activeEnergyLabel: String {
        guard let summary = summary else { return L10n.Placeholder.value }

        if let activeEnergyBurned = summary.activeEnergyBurned {
            return "\(activeEnergyBurned)"
        } else {
            return L10n.Placeholder.value
        }
    }

    var totalEnergyTitle: String {
        guard let summary = summary else { return L10n.Placeholder.value }

        return L10n.Workout.Unit.total(summary.energyUnit).uppercased()
    }

    var totalEnergyLabel: String {
        guard let summary = summary else { return L10n.Placeholder.value }

        if let activeEnergyBurned = summary.totalEnergyBurned {
            return "\(activeEnergyBurned)"
        } else {
            return L10n.Placeholder.value
        }
    }

    var energyUnitLabel: String {
        summary?.energyUnit.shortName ?? L10n.Placeholder.unit
    }

    var heartRateTitle: String {
        L10n.Workout.Summary.Title.averageHeartRate.uppercased()
    }

    var averageHeartRateLabel: String {
        guard let summary = summary else { return L10n.Placeholder.value }

        if let averageHeartRate = summary.averageHeartRate {
            return "\(averageHeartRate)"
        } else {
            return L10n.Placeholder.value
        }
    }

    var heartRateUnitLabel: String {
        L10n.Workout.Unit.beatsPerMinutes
    }

    var heartRateRangeTitle: String {
        L10n.Workout.Summary.Title.range.uppercased()
    }

    var heartRateRangeLabel: String {
        guard let summary = summary,
              let minimumHeartRate = summary.minimumHeartRate,
              let maximumHeartRate = summary.maximumHeartRate else {
            return L10n.Placeholder.title
        }

        return L10n.Workout.Summary.Label.heartRateRange(minimumHeartRate, maximumHeartRate)
    }

    var dateTitle: String {
        guard let summary = summary else { return L10n.Placeholder.title }
        return dateTimeHelper.workoutSummaryDate(from: summary.startDate)
    }

    var timeRangeLabel: String {
        guard let summary = summary else { return L10n.Placeholder.title }

        let start = dateTimeHelper.workoutSummaryTime(from: summary.startDate)
        let end = dateTimeHelper.workoutSummaryTime(from: summary.endDate)
        return L10n.Workout.Summary.Label.timeRange(start, end)
    }

    // MARK: Private Properties
    private let workoutSessionManager: any WorkoutSessionManagement
    private let dateTimeHelper: any DateTimeHelping

    /// The workout summary, retrieved from ``WorkoutSessionManagement``.
    private var summary: WorkoutSummary? {
        // Because we don't want to expose the summary as a published property,
        // we need to manually trigger an update when it changes internally.
        willSet { objectWillChange.send()}
    }

    /// Cancellables subscription.
    private var cancellables: Set<AnyCancellable> = Set()

    // MARK: Initialization
    nonisolated init(
        workoutSessionManager: any WorkoutSessionManagement,
        dateTimeHelper: any DateTimeHelping
    ) {
        self.workoutSessionManager = workoutSessionManager
        self.dateTimeHelper = dateTimeHelper
    }

    // MARK: Methods
    func appear() async {
        if cancellables.isEmpty {
            workoutSessionManager.state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    if case .completed(let summary) = state {
                        self?.summary = summary
                    }
                }
                .store(in: &cancellables)
        }
    }

    func dismiss() async {
        await workoutSessionManager.clearWorkout()
    }
}

// Convenience initializer intended to be used with previews.
#if DEBUG

extension WorkoutSummaryViewModel {
    convenience init(
        workoutSessionManager: any WorkoutSessionManagement,
        dateTimeHelper: any DateTimeHelping,
        summary: WorkoutSummary
    ) {
        self.init(workoutSessionManager: workoutSessionManager, dateTimeHelper: dateTimeHelper)
        self.summary = summary
    }
}

#endif
