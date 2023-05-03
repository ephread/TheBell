//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver

// MARK: - Views

/// Displays a countdown before starting the workout.
struct WorkoutCountdownView: View {
    // MARK: Bindings
    @ObservedObject var viewModel: WorkoutViewModel

    // MARK: Private State
    /// The current step of the countdown, see ``AnimationStep``
    /// for more information.
    @State private var step: AnimationStep = .empty

    /// Whether the label is visible. This property is updated
    /// during the countdown animation.
    @State private var isLabelVisible = false

    // MARK: Private Properties
    private var countdownLabel: String {
        switch step {
        case .ready: return "Ready"
        case .three: return "3"
        case .two: return "2"
        case .one: return "1"
        case .empty: return ""
        }
    }

    // MARK: Body
    var body: some View {
        Text(countdownLabel)
            .opacity(isLabelVisible ? 1 : 0)
            .font(.title)
            .fontDesign(.rounded)
            .fontWeight(.semibold)
            .onAppear {
                if viewModel.currentScene == .countdown {
                    animateViews()
                }
            }
    }

    // MARK: Private Methods

    // TODO: Revamp animation.
    // The animation uses old dispatches to animate, for a lack of better options.
    // This is old code which could be modernized. An animation using a progress gauge
    // would be nicer instead.
    private func animateViews() {

        let now: DispatchTime = .now()

        for (index, step) in zip(AnimationStep.allCases.indices, AnimationStep.allCases) {
            DispatchQueue.main.asyncAfter(deadline: fadeInDeadline(from: now, index: index)) {
                self.step = step
                withAnimation(.easeIn(duration: 0.2)) {
                    isLabelVisible = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: fadeOutDeadline(from: now, index: index)) {
                withAnimation(.easeIn(duration: 0.4)) {
                    isLabelVisible = false
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: dismissDeadline(from: now)) {
            Task { await viewModel.didCompleteCountdown() }
        }
    }

    private func fadeInDeadline(from now: DispatchTime, index: Int) -> DispatchTime {
        now + 0.3 + 1.0 * CGFloat(index)
    }

    private func fadeOutDeadline(from now: DispatchTime, index: Int) -> DispatchTime {
        now + 0.8 + 1.0 * CGFloat(index)
    }

    private func dismissDeadline(from now: DispatchTime) -> DispatchTime {
        now + CGFloat(AnimationStep.allCases.count - 1) * 1.0 + 1.0
    }

    // MARK: Private Types
    enum AnimationStep: CaseIterable {
        case ready, three, two, one, empty
    }
}

#if DEBUG

// MARK: - Previews
struct WorkoutCountdownView_Previews: PreviewProvider {
    @StateObject static var viewModel = WorkoutViewModelPreview(
        mainViewModel: Resolver.resolve(),
        errorViewModel: Resolver.resolve(),
        workoutManager: Resolver.resolve()
    )

    @State static var isPresented = false

    static var previews: some View {
        VStack {
            Button {
                viewModel.startCountdown()
                isPresented = true
            } label: {
                Text("Start Countdown")
            }
        }
        .sheet(isPresented: $isPresented) {
            WorkoutCountdownView(viewModel: viewModel)
        }
    }
}

#endif
