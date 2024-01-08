//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Defaults
import Combine
import SwiftUI

// MARK: - Protocols
/// Manages the workout's dashboard data. The dashboard is read-only
/// and the property names should be self-explanatory.
@MainActor
protocol WorkoutDashboardViewModeling: ViewModeling {
    // MARK: Properties
    var currentRound: String { get }
    var totalCalorieUnit: String { get }

    var isWorkoutPaused: Bool { get }
    var isWorkoutStarted: Bool { get }

    var totalCalories: String { get }

    var currentHeartRate: String { get }
    var heartRateZone: String { get }
    var heartRateZoneColor: Color { get }

    var remainingTime: String { get }

    /// Used to make the remaining time label blink.
    var isRemainingTimeVisible: Bool { get }
    var remainingTimeColor: Color { get }
}

// MARK: - Main Class
/// Concrete implementation of ``WorkoutDashboardViewModeling``.
class WorkoutDashboardViewModel: WorkoutDashboardViewModeling {
    // MARK: Published Properties
    @Published var currentRound: String = L10n.Workout.Label.rounds(0, 0)
    @Published var totalCalorieUnit: String = L10n.Placeholder.twoLineUnit

    @Published var isWorkoutPaused = false
    @Published var isWorkoutStarted = false

    @Published var totalCalories: String = L10n.Placeholder.value
    @Published var currentHeartRate: String = L10n.Placeholder.value
    @Published var heartRateZone: String = L10n.Placeholder.percentageValue
    @Published var heartRateZoneColor = Color(.idleHeartRate)

    @Published var remainingTime: String = L10n.Placeholder.remainingTime
    @Published var isRemainingTimeVisible = true
    @Published var remainingTimeColor: Color = .white

    // MARK: Published Properties
    var heartRateViewModel = HeartRateViewModel()

    // MARK: Private Properties
    private let workoutManager: any WorkoutSessionManagement
    private let mainRepository: any MainDataStorage
    private let dateTimeHelper: any DateTimeHelping

    // Timer used to make the remaining time label blink.
    private var blinkTimer: RepeatingTimer?

    // Cancellable subscriptions
    private var cancellables: Set<AnyCancellable> = Set()

    // MARK: Initialization
    nonisolated init(
        workoutManager: any WorkoutSessionManagement,
        mainRepository: any MainDataStorage,
        dateTimeHelper: any DateTimeHelping
    ) {
        self.workoutManager = workoutManager
        self.mainRepository = mainRepository
        self.dateTimeHelper = dateTimeHelper
    }

    // MARK: Methods
    func appear() async {
        totalCalorieUnit = workoutManager.preferredEnergyUnit.label(of: .active, style: .short)

        if cancellables.isEmpty {
            workoutManager.currentIntervalType
                .receive(on: DispatchQueue.main)
                .sink { [weak self] intervalType in
                    self?.handleIntervalType(intervalType)
                }
                .store(in: &cancellables)

            workoutManager.remainingDuration
                .receive(on: DispatchQueue.main)
                .sink { [weak self] remainingDuration in
                    self?.updateRemainingDuration(remainingDuration)
                }
                .store(in: &cancellables)

            workoutManager.activeCalories
                .receive(on: DispatchQueue.main)
                .sink { [weak self] activeCalories in
                    self?.handleActiveCalories(activeCalories)
                }
                .store(in: &cancellables)

            workoutManager.currentHeartRate
                .receive(on: DispatchQueue.main)
                .sink { @MainActor [weak self] heartRate in
                    self?.handleHeartRate(heartRate)
                }
                .store(in: &cancellables)

            workoutManager.state
                .receive(on: DispatchQueue.main)
                .sink { @MainActor [weak self] state in
                    self?.handleState(state)
                }
                .store(in: &cancellables)
        }
    }

    // MARK: Private Methods
    private func startBlinkingRemainingTime() {
        blinkTimer = RepeatingTimer(timeInterval: 1.0) { [weak self] in
            self?.isRemainingTimeVisible.toggle()
        }

        Task { await blinkTimer?.start() }
    }

    private func stopBlinkingRemainingTime() {
        Task {
            await blinkTimer?.cancel()
            isRemainingTimeVisible = true
        }
    }

    private func updateRemainingDuration(_ remainingDuration: TimeInterval?) {
        if let remainingDuration {
            let components = dateTimeHelper.timeComponents(from: remainingDuration)
            remainingTime = L10n.Workout.Label.timer(components.minutes, components.seconds)
        } else {
            remainingTime = L10n.Placeholder.remainingTime
        }
    }

    private func handleIntervalType(_ intervalType: IntervalType?) {
        switch intervalType {
        case let .round(currentRound, roundCount):
            self.remainingTimeColor = .white
            self.currentRound = L10n.Workout.Label.rounds(currentRound + 1, roundCount).uppercased()
        case let .lastSeconds(currentRound, roundCount):
            self.remainingTimeColor = .yellow
            self.currentRound = L10n.Workout.Label.rounds(currentRound + 1, roundCount).uppercased()
        case let .break(currentRound, roundCount):
            self.remainingTimeColor = .blue
            self.currentRound = L10n.Workout.Label.break(currentRound + 1, roundCount).uppercased()
        case .none:
            self.remainingTimeColor = .white
            self.currentRound = L10n.Workout.Label.rounds(0, 0)
        }
    }

    private func handleState(_ state: WorkoutState?) {
        if state == .paused {
            isWorkoutPaused = true
            isWorkoutStarted = true
            startBlinkingRemainingTime()
        } else if state == .running {
            isWorkoutPaused = false
            isWorkoutStarted = true
            stopBlinkingRemainingTime()
        } else {
            isWorkoutPaused = false
            isWorkoutStarted = true
            stopBlinkingRemainingTime()
        }
    }

    private func handleActiveCalories(_ activeCalories: Int?) {
        if let calories = activeCalories {
            self.totalCalories = "\(calories)"
        } else {
            self.totalCalories = L10n.Placeholder.value
        }
    }

    private func handleHeartRate(_ heartRate: HeartRate?) {
        if let heartRate = heartRate {
            currentHeartRate = "\(heartRate.measured)"
            heartRateZone = "\(Int(round(heartRate.percent * 100)))%"
            heartRateZoneColor = heartRate.zone.color

            heartRateViewModel.heartRateStyle = .beating(bpm: heartRate.measured)
        } else {
            currentHeartRate = L10n.Placeholder.value
            heartRateZone = L10n.Placeholder.percentageValue
            heartRateZoneColor = HeartRateZone.idle.color

            heartRateViewModel.heartRateStyle = .loading
        }
    }
}
