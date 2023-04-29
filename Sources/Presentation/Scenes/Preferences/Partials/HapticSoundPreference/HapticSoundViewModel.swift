//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Combine
import Logging

// MARK: - Protocols
@MainActor
protocol HapticSoundViewModeling: ObservableObject,
                                  ViewModeling {
    // MARK: Properties
    var isAudioFeedbackEnabled: Bool { get set }
    var isHapticFeedbackEnabled: Bool { get set }
    var audioVolume: Float { get set }

    var audioTitle: String { get }
    var hapticTitle: String { get }
    var audioFootnote: String { get }
    var hapticFootnote: String { get }

    var volumeRange: ClosedRange<Float> { get }
}

// MARK: - Main Class
class HapticSoundViewModel: HapticSoundViewModeling {
    // MARK: Published Properties
    @Published var isAudioFeedbackEnabled = false
    @Published var isHapticFeedbackEnabled = false
    @Published var audioVolume: Float = 0

    // MARK: Properties
    var audioTitle: String { L10n.Preference.Audio.title }
    var hapticTitle: String { L10n.Preference.Haptic.title }
    var audioFootnote: String { L10n.Preference.Audio.footer }
    var hapticFootnote: String { L10n.Preference.Haptic.footer }

    let volumeRange: ClosedRange<Float> = 0...10

    // MARK: Private Properties
    private let errorViewModel: any ErrorViewModeling
    private let preferenceViewModel: any PreferencesViewModeling
    private let logger: Logger
    private var preferences: UserPreference?

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Initialization
    nonisolated init(
        errorViewModel: any ErrorViewModeling,
        preferenceViewModel: any PreferencesViewModeling,
        logger: Logger
    ) {
        self.errorViewModel = errorViewModel
        self.logger = logger
        self.preferenceViewModel = preferenceViewModel
    }

    // MARK: Methods
    func appear() async {
        await getDataFromPreferenceViewModel()

        $isAudioFeedbackEnabled.sink { [weak self] value in
            self?.preferenceViewModel.isAudioFeedbackEnabled = value
        }
        .store(in: &cancellables)

        $isHapticFeedbackEnabled.sink { [weak self] value in
            self?.preferenceViewModel.isHapticFeedbackEnabled = value
        }
        .store(in: &cancellables)

        $audioVolume.sink { [weak self] value in
            self?.preferenceViewModel.audioVolume = value
        }
        .store(in: &cancellables)
    }

    // MARK: Private Methods
    private func getDataFromPreferenceViewModel() async {
        // Because preferenceViewModel.appear() is guaranteed to have been
        // called before Self.preferenceViewModel, we can be confident
        // the data is correct.
        isAudioFeedbackEnabled = preferenceViewModel.isAudioFeedbackEnabled
        isHapticFeedbackEnabled = preferenceViewModel.isHapticFeedbackEnabled
        audioVolume = preferenceViewModel.audioVolume
    }
}
