//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import WatchKit
import SwiftUI
import Resolver

// MARK: - Views
/// Contains the three workout views, _control_, _dashboard_
/// and _now playing_, displaying them in a TabView.
///
/// Additionally, it also manages the countdown view and the
/// summary view.
struct WorkoutView: View {
    // MARK: Injected Properties
    @InjectedObject var viewModel: WorkoutViewModel

    // MARK: Private State
    @State private var selectedTab: Int = 1

    // MARK: Body
    var body: some View {
        ZStack {
            error()
            dashboard()
            countdown()
            summary()
        }
        .task { await viewModel.appear() }
    }

    // MARK: Private View Builders
    @ViewBuilder
    private func dashboard() -> some View {
        if viewModel.currentScene == .dashboard {
            TabView(selection: $selectedTab) {
                WorkoutControlView()
                    .tag(0)
                WorkoutDashboardView()
                    .tag(1)
                NowPlayingView()
                    .tag(2)
            }
            .accessibilityIdentifier("Workout_TabView")
        }
    }

    @ViewBuilder
    private func countdown() -> some View {
        if viewModel.currentScene == .countdown {
            WorkoutCountdownView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private func summary() -> some View {
        if viewModel.currentScene == .summary {
            WorkoutSummaryView()
        }
    }

    @ViewBuilder
    private func error() -> some View {
        if viewModel.currentScene == .error {
            Image(systemName: "exclamationmark.octagon")
                .fontDesign(.rounded)
                .font(.largeTitle)
                .foregroundStyle(.red)
        }
    }
}

#if DEBUG

// MARK: Previews
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .previewDevice("Apple Watch SE (44mm) (2nd generation)")
    }
}

#endif
