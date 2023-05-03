//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Resolver
import GRDB
import SwiftUI
import Puppy
import Logging

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerHelpers()
        registerManagers()
        registerViewModels()
        registerWorkoutViewModels()
    }

    private static func registerHelpers() {
        register((any LoggingManagement).self) {
            LoggingManager(fileManager: FileManager.default)
        }
        .scope(.application)

        register {
            resolve((any LoggingManagement).self).makeLogger()
        }
        .scope(.application)

        register((any RoundCountdownTimeManagement).self) { RoundCountdownTimer() }
        register((any ElapsedTimeTracking).self) { ElapsedTimeTracker() }
        register((any WorkoutSummaryBuilding).self) { WorkoutSummaryBuilder() }
        register((any DateTimeHelping).self) { DateTimeHelper() }
    }

    private static func registerManagers() {
        register((any HapticSoundManagement).self) {
            HapticSoundManager(logger: resolve())
        }.scope(.application)

        register {
            // Forced unwrapped, because if the database can't be instantiated,
            // it's a fatal error.
            // swiftlint:disable:next force_try
            try! DatabaseInitializer(fileManager: FileManager.default, logger: resolve())
                .initializeDatabaseQueue()
        }.scope(.application)

        register((any MainDataStorage).self) {
            MainRepository(databaseQueue: resolve(), logger: resolve())
        }

        #if DEBUG
        if CommandLine.arguments.contains("--fake-healthkit") {
            register((any HealthKitManagement).self) {
                FakeHealthKitManager()
            }.scope(.application)
        } else {
            register((any HealthKitManagement).self) {
                HealthKitManager(
                    workoutSummaryBuilder: resolve(),
                    logger: resolve()
                )
            }.scope(.application)
        }
        #else
        register((any HealthKitManagement).self) {
            HealthKitManager(
                workoutSummaryBuilder: resolve(),
                logger: resolve()
            )
        }.scope(.application)
        #endif

        register((any WorkoutSessionManagement).self) {
            WorkoutSessionManager(
                hapticSoundManager: resolve(),
                healthKitManager: resolve(),
                mainRepository: resolve(),
                countdown: resolve(),
                elapsedTimeTracker: resolve(),
                logger: resolve()
            )
        }.scope(.application)
    }

    private static func registerViewModels() {
        register {
            ErrorViewModel()
        }
        .scope(.application)

        register {
            HomeViewModel(
                mainRepository: resolve(),
                workoutSessionManager: resolve(),
                logger: resolve()
            )
        }
        .scope(.shared)

        register {
            WelcomeViewModel(
                mainViewModel: resolve(),
                errorViewModel: resolve(),
                healthkitManager: resolve()
            )
        }
        .scope(.shared)

        register {
            PreferencesViewModel(
                errorViewModel: resolve(),
                mainRepository: resolve(),
                logger: resolve()
            )
        }
        .scope(.shared)

        register {
            HapticSoundViewModel(
                errorViewModel: resolve(),
                preferenceViewModel: resolve(),
                logger: resolve()
            )
        }
        .scope(.shared)

        #if DEBUG
        register {
            DebugLogViewModel(loggingManager: resolve())
        }
        .scope(.shared)
        #endif

        // Additional registration, so that `ObservedObjects`-conforming ViewModels can
        // also be inject through their protocols when required.

        register((any HomeViewModeling).self) { resolve(HomeViewModel.self) }
            .scope(.shared)

        register((any ErrorViewModeling).self) { resolve(ErrorViewModel.self) }
            .scope(.application)

        register((any PreferencesViewModeling).self) { resolve(PreferencesViewModel.self) }
            .scope(.shared)
    }

    private static func registerWorkoutViewModels() {
        register {
            WorkoutViewModel(
                mainViewModel: resolve(),
                errorViewModel: resolve(),
                workoutManager: resolve()
            )
        }
        .scope(.shared)

        register {
            WorkoutControlViewModel(dateTimeHelper: resolve(), workoutManager: resolve())
        }
        .scope(.shared)

        register {
            WorkoutDashboardViewModel(
                workoutManager: resolve(),
                mainRepository: resolve(),
                dateTimeHelper: resolve()
            )
        }
        .scope(.shared)

        register {
            WorkoutSummaryViewModel(workoutSessionManager: resolve(), dateTimeHelper: resolve())
        }
        .scope(.shared)
    }
}

#if DEBUG

/// Add custom Preview.
internal extension Resolver {

    /// Tools to create preview after registering some dependencies
    struct Preview<Content: View>: View {

        /// Closure where to register needed dependencies
        private let registration: ((Resolver) -> Void)?

        /// Closure where to build view to preview
        @ViewBuilder private let content: () -> Content

        /// Creates a preview to register some dependencies before to build the view to preview
        /// - Parameters:
        ///    - registration: The closure where to register needed dependencies
        ///    - content: The closure where to build view to preview
        init(registration: ((Resolver) -> Void)? = nil, content: @escaping () -> Content) {
            self.registration = registration
            self.content = content
        }

        var body: some View {
            Resolver.reset()

            // We need to create a child container, because otherwise, the new registrations
            // created by `registration` would be overridden by the registrations created in
            // `Resolver.registerAllServices()`. `Resolver.registerAllServices()` registers
            // dependency in the main container.
            //
            // It's called the first time a resolution is performed if `Resolver.registrationNeeded`
            // is `true`. Calling `Resolver.reset()` deletes the global cache as well as all
            // registration and containers and then set `Resolver.registrationNeeded` to `true`.
            Resolver.root = Resolver(child: Resolver.main)
            registration?(Resolver.root)

            return content()
        }

    }
}

#endif
