//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import UIKit
import SwiftUI
import Resolver

// MARK: - Views
// Displays a list of preference settings.
struct PreferencesView: View {
    // MARK: Injected properties
    @InjectedObject var viewModel: PreferencesViewModel

    // MARK: Body
    var body: some View {
        // Some of the data provided by the view model is static and
        // could have been used in the view directly, but the view
        // model provides all of them for consistency.
        List {
            generalSection()
            workoutSection()
            acknowledgementSection()

            #if DEBUG
            debugSection()
            #endif
        }
        .accessibilityIdentifier("Preferences_List")
        .navigationTitle(L10n.Preference.title)
        .task { await viewModel.appear() }
    }

    // MARK: - Methods
    @ViewBuilder
    private func generalSection() -> some View {
        Section(viewModel.title(forSection: .general)) {
            NavigationLink {
                HapticSoundPreferenceView()
            } label: {
                Text(viewModel.listTitle(forRow: .soundAndHaptics))
            }
            .accessibilityIdentifier("Preferences_HapticSoundRow")

            IntegerPickerView(
                selectedValue: $viewModel.heartRate,
                range: viewModel.range(forRow: .maximumHeartRate),
                unit: viewModel.caption(forRow: .maximumHeartRate),
                label: viewModel.listTitle(forRow: .maximumHeartRate),
                shortLabel: viewModel.title(forRow: .maximumHeartRate)
            )
            .accessibilityIdentifier("Preferences_HeartRateRow")
        }
    }

    @ViewBuilder
    private func workoutSection() -> some View {
        Section {
            IntegerPickerView(
                selectedValue: $viewModel.roundCount,
                range: viewModel.range(forRow: .roundCount),
                unit: viewModel.caption(forRow: .roundCount),
                label: viewModel.listTitle(forRow: .roundCount),
                shortLabel: viewModel.title(forRow: .roundCount)
            )
            .accessibilityIdentifier("Preferences_RoundCountRow")

            DurationPickerView(
                minutes: $viewModel.roundMinuteDuration,
                seconds: $viewModel.roundSecondDuration,
                range: viewModel.range(forRow: .roundDuration),
                minuteStep: viewModel.step(forRowSegment: .roundMinutes),
                secondStep: viewModel.step(forRowSegment: .roundSeconds),
                label: viewModel.listTitle(forRow: .roundDuration),
                hint: viewModel.footnote(forRow: .roundDuration)
            )
            .accessibilityIdentifier("Preferences_RoundDurationRow")

            DurationPickerView(
                minutes: $viewModel.breakMinuteDuration,
                seconds: $viewModel.breakSecondDuration,
                range: viewModel.range(forRow: .breakDuration),
                minuteStep: viewModel.step(forRowSegment: .breakMinutes),
                secondStep: viewModel.step(forRowSegment: .breakSeconds),
                label: viewModel.listTitle(forRow: .breakDuration),
                hint: viewModel.footnote(forRow: .breakDuration)
            )
            .accessibilityIdentifier("Preferences_BreakDurationRow")

            DurationPickerView(
                minutes: $viewModel.lastStretchMinuteDuration,
                seconds: $viewModel.lastStretchSecondDuration,
                range: viewModel.range(forRow: .lastStretchDuration),
                minuteStep: viewModel.step(forRowSegment: .lastStretchMinutes),
                secondStep: viewModel.step(forRowSegment: .lastStretchSeconds),
                label: viewModel.listTitle(forRow: .lastStretchDuration),
                hint: viewModel.footnote(forRow: .lastStretchDuration)
            )
            .accessibilityIdentifier("Preferences_FinaleStageDurationRow")
        } header: {
            Text(viewModel.title(forSection: .workout))
        } footer: {
            Text(L10n.Preference.Footer.lastStretch)
        }
    }

    @ViewBuilder
    private func acknowledgementSection() -> some View {
        Section {
            NavigationLink {
                AcknowledgmentView()
            } label: {
                Text(viewModel.listTitle(forRow: .acknowledgement))
            }
            .accessibilityIdentifier("Preferences_AcknowledgementRow")
        } footer: {
            Text(viewModel.title(forSection: .version))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding([.top], 15)
        }
    }

#if DEBUG
    @ViewBuilder
    private func debugSection() -> some View {
        Section {
            NavigationLink {
                DebugView()
            } label: {
                Text("Debug")
            }
        }
    }
#endif
}

#if DEBUG

// MARK: - Previews
struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                PreferencesView()
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
            .previewDisplayName("Series 6 - 40mm")

            NavigationStack {
                PreferencesView()
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
            .previewDisplayName("Series 7 - 45mm")
        }
    }
}

#endif
