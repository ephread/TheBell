//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import GRDB

/// User-editable preferences for the entire app.
struct UserPreference: Sendable,
                       Codable,
                       Equatable,
                       FetchableRecord,
                       MutablePersistableRecord {
    // MARK: - Properties
    /// SQLite's auto increment ID.
    var id: Int64?

    /// When set to `true` the app will notify the user of their progression
    /// during a workout using sounds.
    var isAudioFeedbackEnabled: Bool

    /// When set to `true` the app will notify the user of their progression
    /// during a workout using haptic feedback.
    var isHapticFeedbackEnabled: Bool

    /// The maximum heart rate of the user.
    ///
    /// This value is used to compute the exertion factor also know as the _effort_ zone.
    /// Additionally, this value cannot be out of the range
    /// defined by ``Bounds/maximumHeartRateRange``.
    @Clamped(Bounds.maximumHeartRateRange) var maximumHeartRate: Int

    /// The volume of audio notifications.
    ///
    /// The user can defined how loud the audio feedback should be.
    ///
    /// Additionally, this value cannot be out of the range defined by ``Bounds/audioVolumeRange``.
    @Clamped(Bounds.audioVolumeRange) var audioVolume: Float

    // MARK: - Static Properties
    /// The default preference object.
    ///
    /// This is a unique object. The UserPreferences table contains only one row
    /// that can be updated by the user.
    static var `default`: Self {
        return Self(
            isAudioFeedbackEnabled: true,
            isHapticFeedbackEnabled: false,
            maximumHeartRate: 192,
            audioVolume: 0.8
        )
    }

    // MARK: - Initialization
    /// Creates an initializes a new preference object.
    ///
    /// See individual properties on ``UserPreference`` for more information about the parameters.
    ///
    /// - Parameters:
    ///   - isAudioFeedbackEnabled: `true` to enable audio feedback, `false` otherwise.
    ///   - isHapticFeedbackEnabled: `true` to enable haptic feedback, `false` otherwise.
    ///   - maximumHeartRate: The maximum heart rate of the user.
    ///   - audioVolume: The volume of audio notifications.
    init(
        isAudioFeedbackEnabled: Bool,
        isHapticFeedbackEnabled: Bool,
        maximumHeartRate: Int,
        audioVolume: Float
    ) {
        self.isAudioFeedbackEnabled = isAudioFeedbackEnabled
        self.isHapticFeedbackEnabled = isHapticFeedbackEnabled
        self.maximumHeartRate = maximumHeartRate
        self.audioVolume = audioVolume
    }

    /// Decodes the preferences.
    ///
    /// - Parameter decoder: The decoder containing the preferences.
    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try? values.decode(Int64.self, forKey: .id)
        isAudioFeedbackEnabled = try values.decode(Bool.self, forKey: .isAudioFeedbackEnabled)
        isHapticFeedbackEnabled = try values.decode(Bool.self, forKey: .isHapticFeedbackEnabled)

        maximumHeartRate = try values.decode(Int.self, forKey: .maximumHeartRate)
        audioVolume = try values.decode(Float.self, forKey: .audioVolume)
    }

    // MARK: - Methods | Codable
    /// Encodes the preferences.
    ///
    /// - Parameter encoder: The encoder to use.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)

        try container.encode(isAudioFeedbackEnabled, forKey: .isAudioFeedbackEnabled)
        try container.encode(isHapticFeedbackEnabled, forKey: .isHapticFeedbackEnabled)

        try container.encode(maximumHeartRate, forKey: .maximumHeartRate)
        try container.encode(audioVolume, forKey: .audioVolume)
    }

    // MARK: - Methods | GRDB
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    // MARK: - Internal Types
    enum Bounds {
        static let minMaximumHeartRate = 120
        static let maxMaximumHeartRate = 220

        static let minAudioVolume: Float = 0.0
        static let maxAudioVolume: Float = 1.0

        static let maximumHeartRateRange = minMaximumHeartRate...maxMaximumHeartRate
        static let audioVolumeRange = minAudioVolume...maxAudioVolume
    }

    // MARK: - Private Types
    private enum CodingKeys: String, CodingKey {
        case id

        case isAudioFeedbackEnabled
        case isHapticFeedbackEnabled

        case maximumHeartRate
        case audioVolume
    }

    private enum Columns {
        static let id = Column(CodingKeys.id)

        static let maximumHeartRate = Column(CodingKeys.maximumHeartRate)
        static let audioVolume = Column(CodingKeys.audioVolume)

        static let isAudioFeedbackEnabled = Column(CodingKeys.isAudioFeedbackEnabled)
        static let isHapticFeedbackEnabled = Column(CodingKeys.isHapticFeedbackEnabled)
    }
}
