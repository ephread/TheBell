//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import GRDB

/// Definition of a HIIT workout.
struct Workout: Sendable,
                Codable,
                Equatable,
                FetchableRecord,
                MutablePersistableRecord {
    // MARK: - Constants
    /// The amount of second between each entry in a duration picker.
    /// This property should be used to create the pickers for ``roundDuration``
    /// , ``lastStretchDuration`` and ``breakDuration``.
    static let durationPickerStep: Int = 5 // seconds

    // MARK: - Properties
    /// SQLite's auto increment ID.
    var id: Int64?

    /// The name of the workout.
    ///
    /// In the current version of the app, there is only one workout, named "main".
    var name: String

    /// The number of rounds in the workout.
    ///
    /// This value cannot be out of the range defined by ``Bounds/roundCountRange``.
    @Clamped(Bounds.roundCountRange) var roundCount: Int

    /// The duration of the rounds, in seconds.
    ///
    /// The duration cannot be fractional, thus the value is an `Int`, not a `TimeInterval`.
    /// Additionally, the value cannot be out of the range defined by ``Bounds/roundDurationRange``.
    @Clamped(Bounds.roundDurationRange) var roundDuration: Int

    /// The duration of the _last stretch_ of a round, in seconds.
    ///
    /// The app notifies users when a round is about to end. This value is used to determine
    /// when to trigger the notification. For instance, is the value is `30`, the user will be
    /// notified 30 seconds before the end of the round.
    ///
    /// The duration cannot be fractional, thus the value is an `Int`, not a `TimeInterval`.
    /// It also cannot be out of the range defined by ``Bounds/lastStretchDurationRange``.
    ///
    /// From a functional standpoint, it also cannot be more than half the duration of the round,
    /// but this requirement cannot be enforced here.
    @Clamped(Bounds.lastStretchDurationRange) var lastStretchDuration: Int

    /// The duration of the break, in seconds.
    ///
    /// There are recovery periods between rounds and they are know as _breaks_.
    ///
    /// The duration cannot be fractional, thus the value is an `Int`, not a `TimeInterval`.
    /// Additionally, the value cannot be out of the range defined by ``Bounds/breakDurationRange``.
    @Clamped(Bounds.breakDurationRange) var breakDuration: Int

    // MARK: - Static Properties
    /// A default workout.
    ///
    /// In the current version of the app, there is only one workout recorded.
    /// The user can change its parameters, but cannot create new workouts
    /// or switch between multiple workouts.
    static var main: Self {
        Self(
            name: "main",
            roundCount: 9,
            roundDuration: 180,
            lastStretchDuration: 30,
            breakDuration: 30
        )
    }

    // MARK: - Initialization

    /// Creates and initializes a new workout.
    ///
    /// See individual properties on ``Workout`` for more information about the parameters.
    ///
    /// - Parameters:
    ///   - name: The name of the workout.
    ///   - roundCount: The number of rounds in the workout.
    ///   - roundDuration: The duration of the round, in seconds.
    ///   - lastStretchDuration: The duration of the _last stretch_ of a round, in seconds.
    ///   - breakDuration: The duration of the break, in seconds.
    init(
        name: String,
        roundCount: Int,
        roundDuration: Int,
        lastStretchDuration: Int,
        breakDuration: Int
    ) {
        self.name = name
        self.roundCount = roundCount
        self.roundDuration = roundDuration
        self.lastStretchDuration = lastStretchDuration
        self.breakDuration = breakDuration
    }

    /// Decodes a workout.
    ///
    /// - Parameter decoder: The decoder containing the workout.
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try? values.decode(Int64.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        roundCount = try values.decode(Int.self, forKey: .roundCount)
        roundDuration = try values.decode(Int.self, forKey: .roundDuration)
        lastStretchDuration = try values.decode(Int.self, forKey: .lastStretchDuration)
        breakDuration = try values.decode(Int.self, forKey: .breakDuration)
    }

    // MARK: - Methods | Codable
    /// Encodes a workout.
    ///
    /// - Parameter encoder: The encoder to use.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)

        try container.encode(name, forKey: .name)
        try container.encode(roundCount, forKey: .roundCount)
        try container.encode(roundDuration, forKey: .roundDuration)
        try container.encode(lastStretchDuration, forKey: .lastStretchDuration)
        try container.encode(breakDuration, forKey: .breakDuration)
    }

    // MARK: - Methods | GRDB
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    // MARK: - Internal Types
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case roundCount
        case roundDuration
        case lastStretchDuration
        case breakDuration
    }

    // MARK: - Private Types
    enum Bounds {
        static let minNumberOfRounds = 2
        static let maxNumberOfRounds = 20

        static let minRoundDuration = 10
        static let maxRoundDuration = 900

        static let minLastStretchDuration = 5
        static let maxLastStretchDuration = 300

        static let minBreakDuration = 5
        static let maxBreakDuration = 300

        static let roundCountRange = minNumberOfRounds...maxNumberOfRounds
        static let roundDurationRange = minRoundDuration...maxRoundDuration
        static let lastStretchDurationRange = minLastStretchDuration...maxLastStretchDuration
        static let breakDurationRange = minBreakDuration...maxBreakDuration
    }

    // MARK: - Private Types
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let roundCount = Column(CodingKeys.roundCount)
        static let roundDuration = Column(CodingKeys.roundDuration)
        static let lastStretchDuration = Column(CodingKeys.lastStretchDuration)
        static let breakDuration = Column(CodingKeys.breakDuration)
    }
}
