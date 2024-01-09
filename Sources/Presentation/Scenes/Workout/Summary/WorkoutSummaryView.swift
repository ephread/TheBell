//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import WatchKit
import SwiftUI
import Resolver

// MARK: - Views
/// Contains a summary of the last completed workout and is
/// displayed immediately after a workout stops.
struct WorkoutSummaryView: View {
    // MARK: Properties
    @InjectedObject var viewModel: WorkoutSummaryViewModel

    // MARK: Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                title()
                totalDuration()
                activeEnergy()
                totalEnergy()
                heartRate()
                dateTime()

                Spacer()
                    .frame(height: 32)
            }
        }
        .accessibilityIdentifier("WorkoutSummary_ScrollView")
        .task { await viewModel.appear() }
        .toolbar {
            // TODO: Replace by proper sheet.
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    Task { await viewModel.dismiss() }
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityIdentifier("WorkoutSummary_DoneButton")
            }
        }
    }

    // MARK: Private Methods
    @ViewBuilder
    private func title() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.summaryTitle)
                .bellFont(.title)
            Text(viewModel.completionPercentageLabel)
                .foregroundStyle(Color(.totalTime))
                .font(.footnote)
                .fontWeight(.medium)
        }
        .scenePadding(.horizontal)

        Divider()
            .padding(.vertical, 8)
    }

    @ViewBuilder
    private func totalDuration() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.totalDurationTitle)
                .bellFont(.title)
            Text(viewModel.totalDurationLabel)
                .foregroundStyle(Color(.totalTime))
                .bellFont(.time2)
        }
        .scenePadding(.horizontal)

        Divider()
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func activeEnergy() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.activeEnergyTitle)
                .foregroundStyle(Color.white)
                .bellFont(.title)

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.activeEnergyLabel)
                    .foregroundStyle(Color(.energyBurned))
                    .bellFont(.metric)

                Text(viewModel.energyUnitLabel)
                    .foregroundStyle(Color(.energyBurned))
                    .bellFont(.unit)
            }
        }
        .scenePadding(.horizontal)

        Divider()
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func totalEnergy() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.totalEnergyTitle)
                .foregroundStyle(Color.white)
                .bellFont(.title)

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.totalEnergyLabel)
                    .foregroundStyle(Color(.energyBurned))
                    .bellFont(.metric)

                Text(viewModel.energyUnitLabel)
                    .foregroundStyle(Color(.energyBurned))
                    .bellFont(.unit)
            }
        }
        .scenePadding(.horizontal)

        Divider()
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func heartRate() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.heartRateTitle)
                .foregroundStyle(Color.white)
                .bellFont(.title)

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.averageHeartRateLabel)
                    .foregroundStyle(Color(.heartRate))
                    .bellFont(.metric)

                Text(viewModel.heartRateUnitLabel)
                    .foregroundStyle(Color(.heartRate))
                    .bellFont(.unit)
            }

            VStack(alignment: .leading) {
                Text(viewModel.heartRateRangeTitle)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .bellFont(.title)

                Text(viewModel.heartRateRangeLabel)
                    .foregroundStyle(Color(.heartRate))
                    .bellFont(.title)
            }
        }
        .scenePadding(.horizontal)

        Divider()
            .padding(.bottom, 8)
    }

    @ViewBuilder
    private func dateTime() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.dateTitle)
                .foregroundStyle(Color.white)
                .bellFont(.title)

            Text(viewModel.timeRangeLabel)
                .foregroundStyle(Color.white.opacity(0.6))
                .bellFont(.title)
        }
        .scenePadding(.horizontal)
    }
}

#if DEBUG

// MARK: - Previews
struct WorkoutSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.Preview { resolver in
            resolver.register {
                WorkoutSummaryViewModel(
                    workoutSessionManager: WorkoutSessionManagerPreview(),
                    dateTimeHelper: DateTimeHelper(),
                    summary: .preview
                )
            }
        } content: {
            NavigationStack {
                WorkoutSummaryView()
                    .previewDevice("Apple Watch SE (44mm) (2nd generation)")
                    .navigationTitle(L10n.Workout.Summary.title)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#endif
