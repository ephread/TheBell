//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import UIKit
import SwiftUI
import Resolver

struct HapticSoundPreferenceView: View {
    @InjectedObject var viewModel: HapticSoundViewModel

    var body: some View {
        List {
            Section {
                Toggle(isOn: $viewModel.isAudioFeedbackEnabled) {
                    Text(viewModel.audioTitle)
                }
                .accessibilityIdentifier("Preferences_HapticSound_AudioFeedback")
                .tint(Asset.Colors.accentColor.swiftUIColor)

                Slider(
                    value: $viewModel.audioVolume,
                    in: viewModel.volumeRange,
                    step: 1
                ) { // False Positive // swiftlint:disable:this vertical_parameter_alignment_on_call
                    Text(viewModel.audioTitle)
                } minimumValueLabel: {
                    Text(Image(systemName: "speaker.fill"))
                        .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                } maximumValueLabel: {
                    Text(Image(systemName: "speaker.wave.3.fill"))
                        .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                }
                .accessibilityIdentifier("Preferences_HapticSound_AudioVolume")
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .tint(Asset.Colors.accentColor.swiftUIColor)

            } footer: {
                Text(viewModel.audioFootnote)
            }

            Section {
                Toggle(isOn: $viewModel.isHapticFeedbackEnabled) {
                    Text(viewModel.hapticTitle)
                }
                .accessibilityIdentifier("Preferences_HapticSound_HapticFeedback")
                .tint(Asset.Colors.accentColor.swiftUIColor)
            } footer: {
                Text(viewModel.hapticFootnote)
            }
        }
        .accessibilityIdentifier("Preferences_HapticSound_List")
        .navigationTitle(L10n.Preference.soundAndHaptics)
        .task { await viewModel.appear() }
    }
}

#if DEBUG

struct HapticSoundPreferenceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                HapticSoundPreferenceView()
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
            .previewDisplayName("Series 6 - 40mm")

            NavigationStack {
                HapticSoundPreferenceView()
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
            .previewDisplayName("Series 7 - 45mm")
        }
    }
}

#endif
