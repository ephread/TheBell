//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Combine
import Defaults
import Logging

// MARK: - Protocols
/// Provides data to the "main" view of the app.
@MainActor
protocol HomeViewModeling: ViewModeling {
    // MARK: Properties
    /// The title of the button starting a workout.
    var buttonTitle: String { get }

    /// The subtitle the button starting a workout.
    var buttonSubtitle: String { get }

    /// The navigation title, different depending
    /// on the current state.
    var navigationTitle: String { get }

    /// `true` to display the welcome message, see ``WelcomeViewModel``
    /// for more information.
    var isWelcomeMessageDisplayed: Bool { get set }

    /// `true` to display the currently ongoing workout.
    ///
    /// A workout should be displayed as long as its state isn't nil.
    /// When its state is nil, it's either because it hasn't started yet or
    /// because ``WorkoutSessionManager.clearWorkout()`` was called, clearing
    /// the previous one. See ``WorkoutState`` for more information.
    var isWorkoutDisplayed: Bool { get }

    /// `true` when the navigation bar should be displayed.
    var isNavigationBarHidden: Bool { get }

    /// The navigation bar display mode, changing depending
    /// on the current state.
    var navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode { get }

    /// Prepare the workout and display the countdown.
    func prepareWorkout() async
}

// MARK: - Main Class
/// A concrete implementation of ``MainViewModeling``.
class HomeViewModel: HomeViewModeling {
    // MARK: Properties
    @Published var buttonTitle: String = ""
    @Published var buttonSubtitle: String = ""
    @Published var navigationTitle: String = L10n.General.theBell

    @Published var isWelcomeMessageDisplayed = false
    @Published var isWorkoutDisplayed = false
    @Published var isNavigationBarHidden = false
    @Published var navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode = .automatic

    // MARK: - Private Properties
    private let mainRepository: any MainDataStorage
    private let workoutSessionManager: any WorkoutSessionManagement
    private let logger: Logger

    /// The number of round in the current workout, used in the button's
    /// subtitle. This piece of data is loaded from the preferences.
    private var roundCount: Int?

    /// Cancellables subscription.
    private var cancellables: Set<AnyCancellable> = Set()

    // MARK: - Initialization
    nonisolated init(
        mainRepository: any MainDataStorage,
        workoutSessionManager: any WorkoutSessionManagement,
        logger: Logger
    ) {
        self.mainRepository = mainRepository
        self.workoutSessionManager = workoutSessionManager
        self.logger = logger
    }

    // MARK: Methods
    func appear() async {
        #if DEBUG
        if CommandLine.arguments.contains("--no-welcome") {
            logger.debug("'--no-welcome' detected, skipping welcome scene.")
            isWelcomeMessageDisplayed = false
        } else {
            isWelcomeMessageDisplayed = !Defaults[.hasSeenWelcomeMessage]
        }
        #else
        isWelcomeMessageDisplayed = !Defaults[.hasSeenWelcomeMessage]
        #endif

        if cancellables.isEmpty {
            workoutSessionManager.state
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    self?.handleState(state)
                }
                .store(in: &cancellables)
        }

        await reloadData()
    }

    func reloadData() async {
        roundCount = await mainRepository.getMainWorkout().roundCount

        if let roundCount {
            buttonSubtitle = L10n.Main.roundCount(roundCount).uppercased()
            buttonTitle = L10n.Main.startWorkout
        } else {
            buttonTitle = ""
            buttonSubtitle = ""
        }
    }

    func prepareWorkout() async {
        await workoutSessionManager.prepareWorkout()
    }

    private func handleState(_ state: WorkoutState?) {
        // Reacts to the workout's state change.
        // See isWorkoutDisplayed's documentation for more information.
        withAnimation {
            isWorkoutDisplayed = (state != nil)

            if isWelcomeMessageDisplayed {
                navigationBarDisplayMode = .automatic
                isNavigationBarHidden = true
                navigationTitle = ""
                return
            }

            if isWorkoutDisplayed {
                if let state, case .completed = state {
                    navigationBarDisplayMode = .inline
                    isNavigationBarHidden = false
                    navigationTitle = L10n.Workout.Summary.title
                } else {
                    navigationBarDisplayMode = .automatic
                    isNavigationBarHidden = true
                    navigationTitle = ""
                }
                return
            }

            navigationBarDisplayMode = .automatic
            isNavigationBarHidden = false
            navigationTitle = L10n.General.theBell
        }
    }
}
