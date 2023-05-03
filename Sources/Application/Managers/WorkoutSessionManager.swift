//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import HealthKit
import Defaults
import Combine
import Logging

// swiftlint:disable file_length
// rational: this is the biggest manager in the app. Splitting it
//           across multiple files would be confusing.

// MARK: - Protocols
@MainActor
/// Manages an ongoing workout, dispatching changes through Publishers.
protocol WorkoutSessionManagement {
    // MARK: Published Properties
    var totalElapsedTime: CurrentValueSubject<TimeInterval?, Never> { get }
    var remainingDuration: CurrentValueSubject<TimeInterval?, Never> { get }
    var currentIntervalType: CurrentValueSubject<IntervalType?, Never> { get }
    var currentHeartRate: CurrentValueSubject<HeartRate?, Never> { get }
    var activeCalories: CurrentValueSubject<Int?, Never> { get }
    var state: CurrentValueSubject<WorkoutState?, Never> { get }

    // MARK: Properties
    var preferredEnergyUnit: EnergyUnit { get }
    var isWorkoutLoaded: Bool { get }
    var isWorkoutStarted: Bool { get }
    var isWorkoutPaused: Bool { get }

    // MARK: Methods
    func prepareWorkout() async
    func startWorkout() async
    func pauseWorkout() async
    func resumeWorkout() async
    func endWorkout() async
    func clearWorkout() async

    func tryToRecoverWorkout() async
}

// MARK: - WorkoutManager
// swiftlint:disable type_body_length
// Rational: This manager can't be broken up.
class WorkoutSessionManager: NSObject,
                             WorkoutSessionManagement {
    // MARK: Published Properties
    let totalElapsedTime = CurrentValueSubject<TimeInterval?, Never>(nil)
    let remainingDuration = CurrentValueSubject<TimeInterval?, Never>(nil)
    let currentIntervalType = CurrentValueSubject<IntervalType?, Never>(nil)
    let currentHeartRate = CurrentValueSubject<HeartRate?, Never>(nil)
    let activeCalories = CurrentValueSubject<Int?, Never>(nil)

    let state = CurrentValueSubject<WorkoutState?, Never>(nil)

    // MARK: Properties
    var preferredEnergyUnit: EnergyUnit = .kilocalorie

    var isWorkoutLoaded: Bool { state.value != nil }
    var isWorkoutStarted: Bool { state.value == .paused || state.value == .running }
    var isWorkoutPaused: Bool { state.value == .paused }

    // MARK: Private Dependencies
    private var hapticSoundManager: any HapticSoundManagement
    private let mainRepository: any MainDataStorage
    private let healthKitManager: any HealthKitManagement
    private let countdown: any RoundCountdownTimeManagement
    private let elapsedTimeTracker: any ElapsedTimeTracking
    private let logger: Logger

    // MARK: Private Properties
    private var cancellables: Set<AnyCancellable> = Set()

    private var startDate: Date?
    private var workout: Workout!
    private var preferences: UserPreference!

    private var isWorkoutInBetweenRounds = false {
        didSet { saveIsWorkoutInBetweenRounds(isWorkoutInBetweenRounds) }
    }

    private var currentRound: Int = 0 {
        didSet { saveCurrentRound(currentRound) }
    }

    private var remainingDurationInCurrentRound: TimeInterval? {
        didSet { saveRemainingDurationInCurrentRound(remainingDurationInCurrentRound) }
    }

    // MARK: Initialization
    @available(*, unavailable)
    override private init() {
        fatalError("Not Implemented")
    }

    nonisolated init(
        hapticSoundManager: any HapticSoundManagement,
        healthKitManager: any HealthKitManagement,
        mainRepository: any MainDataStorage,
        countdown: any RoundCountdownTimeManagement,
        elapsedTimeTracker: any ElapsedTimeTracking,
        logger: Logger
    ) {
        self.hapticSoundManager = hapticSoundManager
        self.mainRepository = mainRepository
        self.healthKitManager = healthKitManager
        self.countdown = countdown
        self.elapsedTimeTracker = elapsedTimeTracker
        self.logger = logger

        super.init()
    }

    // MARK: Methods
    func prepareWorkout() async {
        await connectWithHealthKit()
        preferredEnergyUnit = await healthKitManager.preferredEnergyUnit

        updateState(to: .idle)
    }

    func startWorkout() async {
        guard !isWorkoutStarted else {
            logger.error(WorkoutError.workoutAlreadyRunning)
            await notifyError(WorkoutError.workoutAlreadyRunning)
            return
        }

        await updateModels()

        do {
            try await healthKitManager.requestAccessToHealthStore()
            await healthKitManager.discardPreviousWorkout()

            try await healthKitManager.startWorkout()

            saveIsWorkoutInBetweenRounds(isWorkoutInBetweenRounds)
            saveCurrentRound(currentRound)

            let now = Date.now
            startDate = now
            await elapsedTimeTracker.startTracking(from: now) { @MainActor [weak self] time in
                await self?.handleElapsedTimeTick(elaspedTime: time)
            }

            await startWorkoutCountdown()
        } catch let error as DisplayableError {
            await notifyError(error)
        } catch {
            // This can't happen, because 'healthKitManager.startWorkout()' only throws
            // "WorkoutError".
        }
    }

    func pauseWorkout() async {
        #if DEBUG
        if Defaults[.crashOnPause] {
            fatalError("Crash Requested")
        } else if Defaults[.notifyErrorOnPause] {
            await notifyError(WorkoutError.couldNotAccessHealthStore)
            return
        }
        #endif

        await elapsedTimeTracker.pauseTracking()
        await healthKitManager.pauseWorkout()
        await countdown.pause()

        updateState(to: .paused)
        hapticSoundManager.notifyUser(that: .workoutDidPause)
    }

    func resumeWorkout() async {
        await elapsedTimeTracker.resumeTracking()
        await healthKitManager.resumeWorkout()
        await countdown.resume()

        updateState(to: .running)
        hapticSoundManager.notifyUser(that: .workoutDidResume)
    }

    func endWorkout() async {
        await elapsedTimeTracker.stopTracking()
        await countdown.stop()

        let workoutSummary = await healthKitManager.makeSummary(
            startDate: startDate,
            workout: workout,
            totalDuration: elapsedTimeTracker.elapsedTime
        )

        do {
            #if DEBUG
            if Defaults[.notifyErrorOnEnd] {
                await notifyError(WorkoutError.couldNotEndWorkout(nil))
                return
            }
            #endif

            try await healthKitManager.endWorkout()

            hapticSoundManager.notifyUser(that: .workoutDidEnd)
            updateState(to: .completed(workoutSummary))
            await reset()
        } catch let error as DisplayableError {
            await notifyError(error)
        } catch {
            // This can't happen, because 'healthKitManager.endWorkout()' only throws
            // "WorkoutError".
        }
    }

    func clearWorkout() async {
        await reset()
        clearOngoingWorkout()
    }

    func tryToRecoverWorkout() async {
        // No workouts can be recovered if the user hasn't started one yet.
        guard Defaults[.hasSeenWelcomeMessage] else { return }

        logger.info("Looking for recoverable workouts…")

        await updateModels()

        do {
            try await healthKitManager.tryToRecoverWorkout()
            logger.info("Recoverable workout found, loading previous data…")
            await connectWithHealthKit()
            await recoverWorkoutData()
        } catch let error as DisplayableError {
            if let workoutError = error as? WorkoutError,
               case .noRestorableWorkouts = workoutError {
                logger.info("No workouts to recover.")
                // Doing nothing, because that means there no workout to recover.
            } else {
                await notifyError(error)
            }
        } catch {
            // This can't happen, because 'healthKitManager.endWorkout()' only throws
            // "WorkoutError".
        }
    }

    // MARK: - Private Methods
    private func connectWithHealthKit() async {
        await self.healthKitManager.setDelegate(self)
    }

    private func updateModels() async {
        workout = await mainRepository.getMainWorkout()
        preferences = await mainRepository.getUserPreferences()

        hapticSoundManager.isAudioFeedbackEnabled = preferences.isAudioFeedbackEnabled
        hapticSoundManager.isHapticFeedbackEnabled = preferences.isHapticFeedbackEnabled
        hapticSoundManager.audioVolume = preferences.audioVolume
    }

    private func recoverWorkoutData() async {
        if let elapsedTime = Defaults[.elapsedTimeInCurrentWorkout] {
            startDate = Date.now.addingTimeInterval(-elapsedTime)
            await elapsedTimeTracker.startTracking(
                from: elapsedTime
            ) { @MainActor [weak self] elaspedTime in
                await self?.handleElapsedTimeTick(elaspedTime: elaspedTime)
            }
        } else {
            let now = Date.now
            startDate = now
            await elapsedTimeTracker.startTracking(
                from: now
            ) { @MainActor [weak self] elaspedTime in
                await self?.handleElapsedTimeTick(elaspedTime: elaspedTime)
            }
        }

        currentRound = Defaults[.currentRound] ?? 0
        isWorkoutInBetweenRounds = Defaults[.isWorkoutInBetweenRounds] ?? false

        let remainingDuration = Defaults[.remainingDurationInCurrentRound]
        if isWorkoutInBetweenRounds {
            await countdown.reset()
            await startCountdown(with: remainingDuration ?? TimeInterval(workout.breakDuration))

            currentIntervalType.send(.break(currentRound, workout.roundCount))
        } else {
            await countdown.reset()
            await startCountdown(with: remainingDuration ?? TimeInterval(workout.roundDuration))

            if let remainingDuration = remainingDuration,
               Int(remainingDuration) < workout.lastStretchDuration {
                currentIntervalType.send(.lastSeconds(currentRound, workout.roundCount))
            } else {
                currentIntervalType.send(.round(currentRound, workout.roundCount))
            }
        }

        updateState(to: .running)
    }

    private func startWorkoutCountdown() async {
        guard await !countdown.isCountingDown else { return }

        await startCountdown(with: TimeInterval(workout.roundDuration))
        currentIntervalType.send(.round(currentRound, workout.roundCount))
        updateState(to: .running)

        hapticSoundManager.notifyUser(that: .roundDidStart)
    }

    private func updateState(to state: WorkoutState?) {
        if state != self.state.value {
            logger.info("Workout State: \(state?.name ?? "nil")")
            self.state.send(state)
        }
    }

    private func notifyError(_ error: any DisplayableError) async {
        self.state.send(.error(error))

        // All errors prevent a workout from starting or running, thus
        // we try one last time to end the workout, but ignore if it fails.
        logger.info("An unrecoverable error occured. Telling HealthKit to end the workout…")
        try? await healthKitManager.endWorkout()
    }

    private func startNextSegmentCountdown(from duration: TimeInterval? = nil) async {
        if isWorkoutInBetweenRounds {
            isWorkoutInBetweenRounds = false
            currentRound += 1

            await startCountdown(with: duration ?? TimeInterval(workout.roundDuration))
            currentIntervalType.send(.round(currentRound, workout.roundCount))
            hapticSoundManager.notifyUser(that: .roundDidStart)
        } else {
            isWorkoutInBetweenRounds = true

            await startCountdown(with: duration ?? TimeInterval(workout.breakDuration))
            currentIntervalType.send(.break(currentRound, workout.roundCount))
            hapticSoundManager.notifyUser(that: .roundDidEnd)
        }
    }

    private func reset() async {
        currentRound = 0
        remainingDurationInCurrentRound = nil

        activeCalories.send(nil)
        currentHeartRate.send(nil)

        isWorkoutInBetweenRounds = false

        await countdown.reset()
        await elapsedTimeTracker.reset()
    }

    private func clearOngoingWorkout() {
        Defaults[.elapsedTimeInCurrentWorkout] = nil
        Defaults[.remainingDurationInCurrentRound] = nil
        Defaults[.isWorkoutInBetweenRounds] = nil
        Defaults[.currentRound] = nil

        totalElapsedTime.send(nil)
        remainingDuration.send(nil)
        currentIntervalType.send(nil)
        currentHeartRate.send(nil)
        activeCalories.send(nil)

        updateState(to: nil)
    }

    private func saveCurrentRound(_ round: Int) {
        Defaults[.currentRound] = round
    }

    private func saveIsWorkoutInBetweenRounds(_ isInBetweenRounds: Bool) {
        Defaults[.isWorkoutInBetweenRounds] = isInBetweenRounds
    }

    private func saveRemainingDurationInCurrentRound(_ duration: TimeInterval?) {
        if let duration {
            // Defensive programming.
            Defaults[.remainingDurationInCurrentRound] = max(duration, 0)
        } else {
            Defaults[.remainingDurationInCurrentRound] = nil
        }
    }

    private func startCountdown(with duration: TimeInterval) async {
        await countdown.reset()
        await countdown.start(with: duration) { @MainActor [weak self] duration in
            await self?.handleCountdownTick(duration: duration)
        }
    }

    private func handleCountdownTick(duration: TimeInterval) async {
        if duration <= 0 { // Defensive programming.
            remainingDurationInCurrentRound = 0
            if currentRound == (workout.roundCount - 1) {
                await endWorkout()
            } else {
                await startNextSegmentCountdown()
            }
        } else {
            remainingDurationInCurrentRound = duration
            self.remainingDuration.send(duration)

            if !isWorkoutInBetweenRounds && Int(duration) == workout.lastStretchDuration {
                currentIntervalType.send(.lastSeconds(currentRound, workout.roundCount))
                hapticSoundManager.notifyUser(that: .roundDidReachItsLastFewSeconds)
            }
        }
    }

    private func handleElapsedTimeTick(elaspedTime: TimeInterval) async {
        Defaults[.elapsedTimeInCurrentWorkout] = elaspedTime
        totalElapsedTime.send(elaspedTime)
    }
}
// swiftlint:enable type_body_length

// MARK: Extensions | HealthKitManagerDelegate
extension WorkoutSessionManager: HealthKitManagerDelegate {
    func didUpdate(currentHeartRate: Int?) async {
        guard let currentHeartRate else {
            return
        }

        let heartRate = HeartRate(
            measured: currentHeartRate,
            maximum: preferences.maximumHeartRate
        )

        self.currentHeartRate.send(heartRate)
    }

    func didUpdate(activeCalories: Int?) async {
        self.activeCalories.send(activeCalories)
    }

    func didUpdate(preferredEnergyUnit: EnergyUnit) async {
        self.preferredEnergyUnit = preferredEnergyUnit
    }
}
