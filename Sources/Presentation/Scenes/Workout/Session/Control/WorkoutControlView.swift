//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver

// MARK: - Views
// TODO: Investigate why this view takes so long to load.
/// Displays elapsed time and workout controls.
struct WorkoutControlView: View {
    // MARK: Properties
    @InjectedObject var viewModel: WorkoutControlViewModel

    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: -5) {
            Text(L10n.Workout.Label.totalTime.uppercased())
                .bellFont(.title)
            Text(viewModel.elapsedTime)
                .accessibilityIdentifier("WorkoutControl_ElapsedTimeLabel")
                .bellFont(.metric)
                .opacity(viewModel.isElapsedTimeVisible ? 1 : 0)

            Spacer()

            HStack {
                VStack {
                    Button {
                        Task { await viewModel.endWorkout() }
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .font(.title2)
                            .foregroundStyle(Color(.end))
                    }
                    .buttonStyle(.workoutControl(color: Color(.endBackground)))
                    .accessibilityIdentifier("WorkoutControl_EndButton")

                    Text(L10n.General.Button.end)
                        .bellFont(.caption)
                }

                VStack {
                    Button {
                        Task { await viewModel.pauseResumeWorkout() }
                    } label: {
                        Image(systemName: viewModel.isWorkoutPaused ? "arrow.clockwise" : "pause")
                            .fontWeight(.semibold)
                            .font(.title2)
                            .foregroundStyle(Color(.pause))
                    }
                    .buttonStyle(.workoutControl(color: Color(.pauseBackground)))
                    .accessibilityIdentifier("WorkoutControl_PauseResumeButton")

                    Text(
                        viewModel.isWorkoutPaused
                            ? L10n.General.Button.resume
                            : L10n.General.Button.pause
                    )
                    .bellFont(.caption)
                }

            }
        }
        .frame(maxHeight: .infinity)
        .task { await viewModel.appear() }
    }
}

#if DEBUG

// MARK: - Previews
struct WorkoutControlView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutControlView()
    }
}

#endif
