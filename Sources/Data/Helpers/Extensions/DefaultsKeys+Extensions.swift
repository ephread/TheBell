//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Defaults

// swiftlint:disable line_length
/// User Default Keys
extension Defaults.Keys {
    static let hasSeenWelcomeMessage = Key<Bool>("hasSeenWelcomeMessage", default: false)

    // Rounds
    static let elapsedTimeInCurrentWorkout = Key<TimeInterval?>("workout.elapsedTimeInCurrentWorkout")
    static let remainingDurationInCurrentRound = Key<TimeInterval?>("workout.currentRound")
    static let currentRound = Key<Int?>("workout.remainingDurationInCurrentRound")
    static let isWorkoutInBetweenRounds = Key<Bool?>("workout.isWorkoutInBetweenRounds")

    // Database
    static let isUsingDatabase2 = Key<Bool>("workout.isUsingDatabase2", default: false)

    // Debug
    static let notifyErrorOnEnd = Key<Bool>("debug.notifyErrorOnEnd", default: false)
    static let notifyErrorOnPause = Key<Bool>("debug.notifyErrorOnPause", default: false)
    static let notifyErrorOnSave = Key<Bool>("debug.notifyErrorOnSave", default: false)
    static let crashOnPause = Key<Bool>("debug.crashOnPause", default: false)
}
