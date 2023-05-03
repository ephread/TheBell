//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver

// MARK: - Views
// Displays metrics about the ongoing workout.
struct WorkoutDashboardView: View {
    // MARK: Properties
    @InjectedObject var viewModel: WorkoutDashboardViewModel

    // MARK: Body
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: -5) {
                    Text(viewModel.currentRound)
                        .bellFont(.title)

                    Text(viewModel.remainingTime)
                        .bellFont(.time)
                        .foregroundColor(viewModel.remainingTimeColor)
                        .opacity(viewModel.isRemainingTimeVisible ? 1 : 0)
                        .accessibilityIdentifier("WorkoutDashboard_RemainingTimeLabel")

                    HStack {
                        Text(viewModel.totalCalories)
                            .bellFont(.metric)
                        VStack(alignment: .leading) {
                            Text(viewModel.totalCalorieUnit)
                        }
                        .bellFont(.title)
                    }

                    HStack {
                        Text(viewModel.currentHeartRate)
                            .bellFont(.metric)
                        Text(L10n.Workout.Unit.beatsPerMinutes)
                            .bellFont(.unit)
                        HeartRateView(viewModel: viewModel.heartRateViewModel)
                            .frame(width: 20, height: 20)
                    }

                    HStack {
                        Text(viewModel.heartRateZone)
                            .bellFont(.metric)
                            .foregroundColor(viewModel.heartRateZoneColor)
                        Text(L10n.Workout.Unit.maximumHeartRate)
                            .bellFont(.unit)
                    }
                }

                Spacer()
            }
        }
        .task { await viewModel.appear() }
    }
}

#if DEBUG

// MARK: - Previews
struct WorkoutInformationView_Previews: PreviewProvider {
    static let workoutSessionManager = WorkoutSessionManagerPreview()

    static var previews: some View {
        Resolver.Preview { preview in
            preview.register {
                WorkoutDashboardViewModel(
                    workoutManager: workoutSessionManager,
                    mainRepository: MainRepositoryPreview(),
                    dateTimeHelper: DateTimeHelper()
                )
            }
            .scope(.application)
        } content: {
            WorkoutDashboardView()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
                .previewDisplayName("Error | Series 7 - 45mm")
                .onAppear {
                    Task { await workoutSessionManager.startWorkout() }
                }
        }
    }
}

#endif
