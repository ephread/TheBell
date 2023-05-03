//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import HealthKit
import Logging
import Combine

// MARK: - Protocol
protocol HealthKitManagement: AnyActor {
    /// The current heart rate reported by HealthKit.
    var currentHeartRate: Int? { get async }
    var activeCalories: Int? { get async }
    var preferredEnergyUnit: EnergyUnit { get async }

    // MARK: Methods
    /// Create a workout summary from the given parameters.
    ///
    /// - Parameters:
    ///   - startDate: The start date of the workout.
    ///   - workout: The completed workout
    ///   - totalDuration: The total duration of the workout.
    /// - Returns: A summary of the workout.
    func makeSummary(
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval
    ) async -> WorkoutSummary?

    /// Request HealthKit to grant access to the health store.
    ///
    /// You must call this method at some point before calling any of the
    /// workout-related methods `-Workout()` and ``loadPreferredEnergyUnit()``
    ///
    /// **Errors**
    ///
    /// This method only throws instances of ``HealthKitError``.
    func requestAccessToHealthStore() async throws

    /// Load the user's preferred energy unit.
    ///
    /// You must call ``requestAccessToHealthStore()`` as some point before
    /// calling this method or it will fail silently.
    ///
    /// **Errors**
    ///
    /// This method only throws instances of ``HealthKitError``.
    func loadPreferredEnergyUnit() async throws

    func startWorkout() async throws
    func resumeWorkout() async
    func pauseWorkout() async
    func endWorkout()  async throws

    /// Discards a previous workout.
    ///
    /// If there are no workouts to discard, this method does nothings.
    /// If errors happen while discarding a previous workout, they are ignored.
    ///
    /// You must call ``requestAccessToHealthStore()`` as some point before
    /// calling this method or it will fail silently.
    func discardPreviousWorkout() async

    /// Try to recover a workout if it exists.
    ///
    /// This method is expected to be called as early as possible during the app's lifecycle.
    /// Unlike ``discardPreviousWorkout()`` or ``startWorkout()``, it calls
    /// ``requestAccessToHealthStore()`` internally. 
    ///
    /// **Errors**
    ///
    /// This method only throws instances of ``WorkoutError``. If no workout exists, this method
    /// throws ``WorkoutError/noRestorableWorkouts``.
    func tryToRecoverWorkout() async throws

    func setDelegate(_ delegate: any HealthKitManagerDelegate) async
}

// MARK: - Main Class
actor HealthKitManager: NSObject,
                        HealthKitManagement {
    // MARK: - Private Properties
    private let workoutSummaryBuilder: any WorkoutSummaryBuilding
    private let logger: Logger

    private var healthStore: HKHealthStore?
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    var currentHeartRate: Int?
    var activeCalories: Int?
    var preferredEnergyUnit: EnergyUnit = .kilocalorie

    private weak var delegate: (any HealthKitManagerDelegate)?

    var workoutConfiguration: HKWorkoutConfiguration {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .highIntensityIntervalTraining
        configuration.locationType = .indoor

        return configuration
    }

    // MARK: Initialization
    init(workoutSummaryBuilder: any WorkoutSummaryBuilding, logger: Logger) {
        self.workoutSummaryBuilder = workoutSummaryBuilder
        self.logger = logger
    }

    // MARK: Methods
    func makeSummary(
        startDate: Date?,
        workout: Workout,
        totalDuration: TimeInterval
    ) async -> WorkoutSummary? {
        return await workoutSummaryBuilder.makeSummary(
            builder: builder,
            startDate: startDate,
            workout: workout,
            totalDuration: totalDuration,
            energyUnit: preferredEnergyUnit
        )
    }

    func requestAccessToHealthStore() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.error(HealthKitError.healthKitNotAvailable)
            throw HealthKitError.healthKitNotAvailable
        }

        healthStore = HKHealthStore()

        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        do {
            try await healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            logger.error(error)
            throw HealthKitError.accessRefused(error)
        }
    }

    func loadPreferredEnergyUnit() async throws {
        guard let healthStore = healthStore else {
            logger.error(HealthKitError.storeNotReady)
            throw HealthKitError.storeNotReady
        }

        let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

        let units: [HKQuantityType: HKUnit]
        do {
            units = try await healthStore.preferredUnits(for: [type])
        } catch {
            logger.error(error)
            throw HealthKitError.unitNotAvailable(error)
        }

        guard let unit = units[type] else {
            logger.warning("Energy unit was not returned by HealthKit.")
            throw HealthKitError.unitNotAvailable(nil)
        }

        let energyUnit: EnergyUnit
        let energyFormatterUnit = HKUnit.energyFormatterUnit(from: unit)
        switch energyFormatterUnit {
        case .joule: energyUnit = .kilojoule
        case .kilojoule: energyUnit = .kilojoule
        case .calorie: energyUnit = .calorie
        case .kilocalorie: energyUnit = .kilocalorie
        @unknown default: energyUnit = .kilocalorie
        }

        preferredEnergyUnit = energyUnit
    }

    func startWorkout() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.error(HealthKitError.healthKitNotAvailable)
            throw HealthKitError.healthKitNotAvailable
        }

        guard let healthStore = healthStore else {
            logger.error(WorkoutError.couldNotAccessHealthStore)
            throw WorkoutError.couldNotAccessHealthStore
        }

        do {
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: workoutConfiguration
            )
        } catch {
            // TODO: Customize errors based on HKError.Code.
            logger.error(error)
            throw WorkoutError.couldNotStartWorkout
        }

        builder = session?.associatedWorkoutBuilder()
        configureBuilder(using: healthStore)

        let now = Date.now
        session?.startActivity(with: now)

        do {
            try await builder?.beginCollection(at: now)
        } catch {
            logger.error(error)
            session?.end()

            let nsError = error as NSError
            if nsError.code == HKError.errorAuthorizationDenied.rawValue {
                throw WorkoutError.authorizationDenied
            } else {
                throw WorkoutError.couldNotStartDataCollection(error)
            }
        }
    }

    func resumeWorkout() async {
        session?.resume()
    }

    func pauseWorkout() async {
        session?.pause()
    }

    func endWorkout() async throws {
        defer { reset() }

        guard let session = session, let builder = builder else {
            logger.error(WorkoutError.couldNotEndWorkout(nil))
            throw WorkoutError.couldNotEndWorkout(nil)
        }

        session.end()

        do {
            try await builder.endCollection(at: .now)
        } catch {
            logger.error(error)
            throw WorkoutError.couldNotEndDataCollection(error)
        }

        do {
            try await builder.finishWorkout()
        } catch {
            logger.error(error)
            throw WorkoutError.couldNotEndWorkout(error)
        }

        logger.info("HealthKit Workout successfully ended.")
    }

    func discardPreviousWorkout() async {
        do {
            guard let healthStore else {
                logger.warning(
                    "'healthStore' is nil, did you forget to call 'requestAccessToHealthStore()'?"
                )
                return
            }

            let session = try await healthStore.recoverActiveWorkoutSession()
            let builder = session?.associatedWorkoutBuilder()
            session?.end()

            try await builder?.endCollection(at: .now)
            try await builder?.finishWorkout()
        } catch {
            logger.error(error)
            // Do nothing, because we are trying to discard a previous workout.
            // If an error occurred, it doesn't matter.
        }
    }

    func tryToRecoverWorkout() async throws {
        do {
            try await requestAccessToHealthStore()
        } catch let error as HealthKitError {
            logger.error(error)
            throw WorkoutError.couldNotRestoreWorkout(error.underlyingError)
        } catch {
            logger.error(error)
            throw WorkoutError.couldNotRestoreWorkout(error)
        }

        // Defensive, because if requestAccessToHealthStore() doesn't fail,
        // 'healthStore' is guaranteed to be present.
        guard let healthStore = healthStore else {
            logger.error(WorkoutError.couldNotAccessHealthStore)
            throw WorkoutError.couldNotAccessHealthStore
        }

        do {
            session = try await healthStore.recoverActiveWorkoutSession()

            // If session is nil, there are no recoverable workouts.
            guard session != nil else {
                throw WorkoutError.noRestorableWorkouts
            }

            builder = session?.associatedWorkoutBuilder()
        } catch {
            if let error = error as? WorkoutError,
               case .noRestorableWorkouts = error {
                // Rethrows error in case there are no recoverable workouts.
                throw error
            } else {
                logger.error(error)
                throw WorkoutError.couldNotRestoreWorkout(error)
            }
        }

        configureBuilder(using: healthStore)
    }

    func setDelegate(_ delegate: any HealthKitManagerDelegate) async {
        self.delegate = delegate
    }

    // MARK: - Private Methods
    private func configureBuilder(using healthStore: HKHealthStore) {
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: workoutConfiguration
        )

        builder?.delegate = self
    }

    private func handleNewCollections(
        from workoutBuilder: HKLiveWorkoutBuilder,
        types: Set<HKSampleType>
    ) async {
        let heartRateQuantity = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let activeCalorie = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

        if types.contains(heartRateQuantity) {
            let statistics = workoutBuilder.statistics(for: heartRateQuantity)

            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            if let value = statistics?.mostRecentQuantity()?.doubleValue(for: heartRateUnit) {
                let roundedValue = Int(round(value))
                currentHeartRate = roundedValue
                await delegate?.didUpdate(currentHeartRate: currentHeartRate)
            } else {
                // Unlike Total Calories, the user should be notified that their heart rate
                // isn't measured properly.
                currentHeartRate = nil
                await delegate?.didUpdate(currentHeartRate: nil)
            }
        } else if types.contains(activeCalorie) {
            let statistics = workoutBuilder.statistics(for: activeCalorie)

            let calorieUnit = preferredEnergyUnit.hkUnit
            if let value = statistics?.sumQuantity()?.doubleValue(for: calorieUnit) {
                activeCalories = Int(round(value))
                await delegate?.didUpdate(activeCalories: activeCalories)
            }
        }
    }

    private func reset() {
        logger.info("Resetting HealthKit Manager…")
        session = nil
        builder = nil
    }
}

extension HealthKitManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        Task { await handleNewCollections(from: workoutBuilder, types: collectedTypes) }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }
}

protocol HealthKitManagerDelegate: Sendable, AnyObject {
    func didUpdate(currentHeartRate: Int?) async
    func didUpdate(activeCalories: Int?) async
    func didUpdate(preferredEnergyUnit: EnergyUnit) async
}
