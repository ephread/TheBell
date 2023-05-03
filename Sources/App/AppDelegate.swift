//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import WatchKit
import HealthKit
import AVFoundation
import Resolver
import Logging

class AppDelegate: NSObject,
                   WKApplicationDelegate,
                   ObservableObject {

    // MARK: Private Properties
    @Injected private var logger: Logger
    @Injected private var workoutSessionManager: any WorkoutSessionManagement

    // MARK: WKApplicationDelegate Methods
    func applicationDidFinishLaunching() {
        logger.info("Application did finish launching.")
        initializeAudioSession()

        // Since 'handleActiveWorkoutRecovery()' is never called, we
        // try to restore any pre-existing workout as soon as the app
        // has loaded instead.
        Task { await workoutSessionManager.tryToRecoverWorkout() }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application
        // was inactive. If the application was previously in the background,
        // optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an
        // incoming phone call or SMS message) or when the user quits the application
        // and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        logger.info( "Handling Background Tasks…")

        // Sent when the system needs to launch the application in the background to
        // process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call,
                // make sure to set your expiration date
                snapshotTask.setTaskCompleted(
                    restoredDefaultState: true,
                    estimatedSnapshotExpiration: Date.distantFuture,
                    userInfo: nil
                )
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

    func handleActiveWorkoutRecovery() {
        // For some reason, this method is never ever called.
        // It might have to do with WKApplicationDelegateAdaptor.
        logger.info("Handling Workout Recovery…")
    }

    // MARK: Private Methods
    private func initializeAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: .duckOthers)
            logger.info( "Audio Session successfully initialized.")
        } catch {
            logger.error(error)
        }
    }
}
