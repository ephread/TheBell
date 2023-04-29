//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Defaults
import Combine
import SwiftUI

// MARK: - Protocols
/// Manages navigation and errors for ``WorkoutView``
@MainActor
protocol WorkoutViewModeling: ViewModeling {
    // MARK: Properties
    /// `true` when the summary should be displayed (at the end of a workout).
    var currentScene: WorkoutScene { get }

    // MARK: Methods
    func didCompleteCountdown() async
}

// MARK: - Main Class
class WorkoutViewModel: WorkoutViewModeling {
    // MARK: Properties
    @Published var currentScene: WorkoutScene = .blank

    // MARK: Private Properties
    private let mainViewModel: any HomeViewModeling
    private let errorViewModel: any ErrorViewModeling
    private let workoutManager: any WorkoutSessionManagement

    private var cancellables: Set<AnyCancellable> = Set()

    // MARK: Initialization
    nonisolated init(
        mainViewModel: any HomeViewModeling,
        errorViewModel: any ErrorViewModeling,
        workoutManager: any WorkoutSessionManagement
    ) {
        self.mainViewModel = mainViewModel
        self.errorViewModel = errorViewModel
        self.workoutManager = workoutManager
    }

    // MARK: Methods
    func appear() async {
        // Connecting the publisher only once.
        if cancellables.isEmpty {
            workoutManager.state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    self?.switchScene(basedOn: state)
                }
                .store(in: &cancellables)
        }
    }

    func didCompleteCountdown() async {
        await workoutManager.startWorkout()
    }

    func switchScene(basedOn state: WorkoutState?) {
        switch state {
        case .running, .paused:
            withAnimation {
                currentScene = .dashboard
            }
        case .completed:
            withAnimation {
                currentScene = .summary
            }
        case .error(let error):
            withAnimation {
                currentScene = .error
            }

            if let error {
                errorViewModel.push(error: error) { [weak self] in
                    Task { await self?.workoutManager.clearWorkout() }
                }
            }
        case .idle:
            withAnimation {
                currentScene = .countdown
            }
        default:
            currentScene = .blank
        }
    }
}

enum WorkoutScene {
    case blank, summary, dashboard, countdown, error
}
