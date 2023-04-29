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

                Button {
                    Task { await viewModel.dismiss() }
                } label: {
                    Text(L10n.General.Button.done)
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("WorkoutSummary_DoneButton")

            }
        }
        .accessibilityIdentifier("WorkoutSummary_ScrollView")
        .task { await viewModel.appear() }
    }

    // MARK: Private Methods
    @ViewBuilder
    private func title() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.summaryTitle)
                .bellFont(.title)
            Text(viewModel.completionPercentageLabel)
                .foregroundColor(Asset.Colors.totalTime.swiftUIColor)
                .font(.footnote)
        }

        Divider()
    }

    @ViewBuilder
    private func totalDuration() -> some View {
        VStack(alignment: .leading, spacing: -4) {
            Text(viewModel.totalDurationTitle)
                .bellFont(.title)
            Text(viewModel.totalDurationLabel)
                .foregroundColor(Asset.Colors.totalTime.swiftUIColor)
                .bellFont(.time2)

            Divider()
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private func activeEnergy() -> some View {
        VStack(alignment: .leading, spacing: -3) {
            Text(viewModel.activeEnergyTitle)
                .foregroundColor(Color.white)
                .bellFont(.title)

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.activeEnergyLabel)
                    .foregroundColor(Asset.Colors.energyBurned.swiftUIColor)
                    .bellFont(.metric)

                Text(viewModel.energyUnitLabel)
                    .foregroundColor(Asset.Colors.energyBurned.swiftUIColor)
                    .bellFont(.unit)
            }

            Divider()
                .padding(.top, 3)
        }
    }

    @ViewBuilder
    private func totalEnergy() -> some View {
        VStack(alignment: .leading, spacing: -3) {
            Text(viewModel.totalEnergyTitle)
                .foregroundColor(Color.white)
                .bellFont(.title)

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.totalEnergyLabel)
                    .foregroundColor(Asset.Colors.energyBurned.swiftUIColor)
                    .bellFont(.metric)

                Text(viewModel.energyUnitLabel)
                    .foregroundColor(Asset.Colors.energyBurned.swiftUIColor)
                    .bellFont(.unit)
            }

            Divider()
                .padding(.top, 3)
        }
    }

    @ViewBuilder
    private func heartRate() -> some View {
        VStack(alignment: .leading, spacing: -3) {
            Text(viewModel.heartRateTitle)
                .foregroundColor(Color.white)
                .bellFont(.title)

            HStack(alignment: .firstTextBaseline) {
                Text(viewModel.averageHeartRateLabel)
                    .foregroundColor(Asset.Colors.heartRate.swiftUIColor)
                    .bellFont(.metric)

                Text(viewModel.heartRateUnitLabel)
                    .foregroundColor(Asset.Colors.heartRate.swiftUIColor)
                    .bellFont(.unit)
            }

            VStack(alignment: .leading) {
                Text(viewModel.heartRateRangeTitle)
                    .foregroundColor(Color.white.opacity(0.6))
                    .bellFont(.title)

                Text(viewModel.heartRateRangeLabel)
                    .foregroundColor(Asset.Colors.heartRate.swiftUIColor)
                    .bellFont(.title)

                Divider()
            }
        }
    }

    @ViewBuilder
    private func dateTime() -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.dateTitle)
                .foregroundColor(Color.white)
                .bellFont(.title)

            Text(viewModel.timeRangeLabel)
                .foregroundColor(Color.white.opacity(0.6))
                .bellFont(.title)
        }
    }
}

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
