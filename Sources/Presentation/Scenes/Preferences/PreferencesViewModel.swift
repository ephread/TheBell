//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Logging

// MARK: - Protocols
/// Provides content to `PreferencesView`. Property names
/// should be straightforward.
@MainActor
protocol PreferencesViewModeling: ObservableObject,
                                  ViewModeling {
    // MARK: Properties
    var heartRate: Int { get }
    var roundCount: Int { get }

    var roundMinuteDuration: Int { get }
    var roundSecondDuration: Int { get }

    var breakMinuteDuration: Int { get }
    var breakSecondDuration: Int { get }

    var lastStretchMinuteDuration: Int { get }
    var lastStretchSecondDuration: Int { get }

    var isAudioFeedbackEnabled: Bool { get set }
    var isHapticFeedbackEnabled: Bool { get set }
    var audioVolume: Float { get set }

    // MARK: Methods
    /// Provides the picker's range of valid values for
    /// the given preference row.
    func range(forRow row: PreferenceRowRange) -> ClosedRange<Int>

    /// Provides the step by which increase the picker values
    /// for the given preference row.
    func step(forRowSegment: PreferenceRowStep) -> Int

    /// Provides the title for the given preference section.
    func title(forSection section: PreferenceSection) -> String

    /// Provides the picker's list title (row title) for the given preference row.
    func listTitle(forRow row: PreferenceRow) -> String

    /// Provides the picker's title for the given preference row.
    func title(forRow row: PreferenceRow) -> String?

    /// Provides the picker's caption for the given preference row.
    func caption(forRow row: PreferenceRow) -> String

    /// Provides the picker's footnote for the given preference row.
    func footnote(forRow row: PreferenceFootnote) -> String
}

// MARK: - Main Class
/// Concrete implementation of ``PreferencesViewModeling``.
class PreferencesViewModel: PreferencesViewModeling {
    // MARK: Inner structs.
    enum Constants {
        static let secondStep = 5
        static let minuteStep = 1
    }

    // MARK: Published Properties
    @Published var heartRate: Int = 0
    @Published var roundCount: Int = 0

    @Published var roundMinuteDuration: Int = 0
    @Published var roundSecondDuration: Int = 0

    @Published var breakMinuteDuration: Int = 0
    @Published var breakSecondDuration: Int = 0

    @Published var lastStretchMinuteDuration: Int = 0
    @Published var lastStretchSecondDuration: Int = 0

    var isAudioFeedbackEnabled = false
    var isHapticFeedbackEnabled = false
    var audioVolume: Float = 0

    // MARK: Private Properties
    private let errorViewModel: any ErrorViewModeling
    private let mainRepository: any MainDataStorage
    private let logger: Logger

    /// Stores workout-related preferences.
    private var workout: Workout?

    /// Stores general preferences.
    private var preferences: UserPreference?

    // MARK: Initialization
    nonisolated init(
        errorViewModel: any ErrorViewModeling,
        mainRepository: any MainDataStorage,
        logger: Logger
    ) {
        self.errorViewModel = errorViewModel
        self.mainRepository = mainRepository
        self.logger = logger
    }

    // MARK: Methods
    func appear() async {
        if workout == nil || preferences == nil {
            // The view appeared for the first time.
            await reloadData()
        } else {
            // The view reappears, this means the stack was popped and
            // updates performed by other view models must be saved.
            await validateAndSaveData()
        }
    }

    func range(forRow range: PreferenceRowRange) -> ClosedRange<Int> {
        switch range {
        case .maximumHeartRate: return 120...200
        case .roundCount: return 2...20

        case .roundDuration: return 10...900
        case .breakDuration: return 5...300
        case .lastStretchDuration:
            let roundDuration = roundMinuteDuration * 60 + roundSecondDuration
            let upperBound = lastStretchUpperBound(roundDuration: roundDuration)

            if upperBound == 0 {
                // This can't happen in a real case, because 'roundDuration'
                // is at least '10', which means `upperBound` is at least '5'.
                return 0...0
            } else {
                return 5...upperBound
            }
        }
    }

    func step(forRowSegment rowSegment: PreferenceRowStep) -> Int {
        switch rowSegment {
        case .roundMinutes, .breakMinutes, .lastStretchMinutes:
            return Constants.minuteStep
        case .roundSeconds, .breakSeconds, .lastStretchSeconds:
            return Constants.secondStep
        }
    }

    func title(forSection section: PreferenceSection) -> String {
        switch section {
        case .general:
            return L10n.Preference.Header.general.uppercased()
        case .workout:
            return L10n.Preference.Header.workout.uppercased()
        case .acknowledgement:
            return L10n.Preference.Footer.lastStretch
        case .version:
            if let infoDictionary = Bundle.main.infoDictionary,
               let version = infoDictionary["CFBundleShortVersionString"] as? String,
               let buildNumber = infoDictionary["CFBundleVersion"] as? String {
                return L10n.Preference.Footer.version(version, buildNumber)
            }

            return L10n.Preference.Footer.version("?", "?")
        }
    }

    func listTitle(forRow row: PreferenceRow) -> String {
        return switch row {
        case .soundAndHaptics: L10n.Preference.soundAndHaptics
        case .maximumHeartRate: L10n.Preference.maximumHeartRate
        case .roundCount: L10n.Preference.roundCount
        case .roundDuration: L10n.Preference.roundDuration
        case .breakDuration: L10n.Preference.breakDuration
        case .lastStretchDuration: L10n.Preference.lastStretchDuration
        case .acknowledgement: L10n.Preference.acknowledgement
        }
    }

    func title(forRow row: PreferenceRow) -> String? {
        return switch row {
        case .maximumHeartRate: L10n.Preference.MaximumHeartRate.short
        case .roundDuration: L10n.Preference.RoundDuration.short
        case .breakDuration: L10n.Preference.BreakDuration.short
        case .lastStretchDuration: L10n.Preference.LastStretchDuration.short
        default: nil
        }
    }

    func caption(forRow row: PreferenceRow) -> String {
        switch row {
        case .maximumHeartRate: return L10n.Preference.MaximumHeartRate.caption
        case .roundCount: return L10n.Preference.RoundCount.caption
        default: return ""
        }
    }

    func footnote(forRow row: PreferenceFootnote) -> String {
        switch row {
        case .roundDuration:
            let range = range(forRow: .roundDuration)
            return L10n.Preference.Duration.footnote(
                range.lowerBound.timeFormated ?? "",
                range.upperBound.timeFormated ?? ""
            )
        case .breakDuration:
            let range = range(forRow: .breakDuration)
            return L10n.Preference.Duration.footnote(
                range.lowerBound.timeFormated ?? "",
                range.upperBound.timeFormated ?? ""
            )
        case .lastStretchDuration:
            let range = range(forRow: .lastStretchDuration)
            return L10n.Preference.LastStretchDuration.footnote(
                range.lowerBound.timeFormated ?? "",
                range.upperBound.timeFormated ?? ""
            )
        }
    }

    // MARK: Private Methods
    private func reloadData() async {
        workout = await mainRepository.getMainWorkout()
        preferences = await mainRepository.getUserPreferences()

        if let preferences = preferences {
            heartRate = preferences.maximumHeartRate

            isAudioFeedbackEnabled = preferences.isAudioFeedbackEnabled
            isHapticFeedbackEnabled = preferences.isHapticFeedbackEnabled
            audioVolume = preferences.audioVolume * 10
        }

        if let workout = workout {
            roundCount = workout.roundCount

            let roundTimeComponents = timeComponents(from: workout.roundDuration)
            roundMinuteDuration = roundTimeComponents.minutes
            roundSecondDuration = roundTimeComponents.seconds

            let breakTimeComponents = timeComponents(from: workout.breakDuration)
            breakMinuteDuration = breakTimeComponents.minutes
            breakSecondDuration = breakTimeComponents.seconds

            let lastStretchTimeComponents = timeComponents(from: workout.lastStretchDuration)
            lastStretchMinuteDuration = lastStretchTimeComponents.minutes
            lastStretchSecondDuration = lastStretchTimeComponents.seconds
        }
    }

    private func halfRoundDuration(fromRoundDuration roundDuration: Int) -> Int {
        (roundDuration / 2).roundedDown(toMultipleOf: Constants.secondStep)
    }

    private func lastStretchUpperBound(roundDuration: Int) -> Int {
        let halfDuration = halfRoundDuration(fromRoundDuration: roundDuration)
        return min(Workout.Bounds.maxLastStretchDuration, halfDuration)
    }

    private func timeComponents(from duration: Int) -> (minutes: Int, seconds: Int) {
        let seconds = (duration % 60) - ((duration % 60) % Constants.secondStep)
        let minutes = (duration / 60) - ((duration / 60) % Constants.minuteStep)

        return (minutes: minutes, seconds: seconds)
    }

    private func validateAndSaveData() async {
        if var preferences = preferences {
            preferences.maximumHeartRate = heartRate

            preferences.isAudioFeedbackEnabled = isAudioFeedbackEnabled
            preferences.isHapticFeedbackEnabled = isHapticFeedbackEnabled
            preferences.audioVolume = audioVolume / 10

            do {
                self.preferences = try await mainRepository.save(preferences: preferences)
            } catch let error as DatabaseError {
                errorViewModel.push(error: error)
            } catch {
                // Nothing else to do, because mainRepository can only throw `DatabaseError`.
            }
        }

        if var workout = workout {
            workout.roundCount = roundCount
            workout.roundDuration = roundMinuteDuration * 60 + roundSecondDuration
            workout.breakDuration = breakMinuteDuration * 60 + breakSecondDuration
            workout.lastStretchDuration = lastStretchMinuteDuration * 60 + lastStretchSecondDuration

            let halfDuration = halfRoundDuration(fromRoundDuration: workout.roundDuration)
            if workout.lastStretchDuration > Workout.Bounds.maxLastStretchDuration ||
               workout.lastStretchDuration > halfDuration {
                let duration = lastStretchUpperBound(roundDuration: workout.roundDuration)
                workout.lastStretchDuration = duration

                // Also updating the local state.
                let lastStretchTimeComponents = timeComponents(from: workout.lastStretchDuration)
                lastStretchMinuteDuration = lastStretchTimeComponents.minutes
                lastStretchSecondDuration = lastStretchTimeComponents.seconds
            }

            do {
                self.workout = try await mainRepository.save(workout: workout)
            } catch let error as DatabaseError {
                errorViewModel.push(error: error)
            } catch {
                // Nothing else to do, because mainRepository can only throw `DatabaseError`.
            }
        }
    }
}

// MARK: Enums

/// All Preference sections
enum PreferenceSection: CaseIterable {
    case general, workout, acknowledgement, version
}

/// All Preference rows.
enum PreferenceRow {
    case soundAndHaptics
    case maximumHeartRate
    case roundCount
    case roundDuration
    case breakDuration
    case lastStretchDuration
    case acknowledgement
}

/// Preference rows supporting a range of value.
enum PreferenceRowRange {
    case maximumHeartRate
    case roundCount
    case roundDuration
    case breakDuration
    case lastStretchDuration
}

/// Steps for each pickers.
enum PreferenceRowStep {
    case roundMinutes
    case roundSeconds
    case breakMinutes
    case breakSeconds
    case lastStretchMinutes
    case lastStretchSeconds
}

/// All Preference Rows containing footnotes.
enum PreferenceFootnote {
    case roundDuration
    case breakDuration
    case lastStretchDuration
}
