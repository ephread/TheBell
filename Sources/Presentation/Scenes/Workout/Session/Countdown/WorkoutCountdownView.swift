//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver

// TODO: Document & Use constants for some animation durations.

// MARK: Private Types

private struct StrokeAnimationProperties {
    var progress: CGFloat = 0
    var lineWidth: CGFloat = 0
}

private struct TextAnimationProperties {
    var opacity: CGFloat = 0
    var scale = CGSize(width: 0.2, height: 0.2)
}

private enum CountdownPhase: String, Hashable, CaseIterable {
    case ready, three, two, one

    var label: String {
        return switch self {
        case .ready: "Ready"
        case .three: "3"
        case .two: "2"
        case .one: "1"
        }
    }

    var fontSize: CGFloat {
        return switch self {
        case .ready: 30
        default: 60
        }
    }

    var delay: TimeInterval {
        return switch self {
        case .ready: 0.8
        case .three: 2.5
        case .two: 4.0
        case .one: 5.5
        }
    }
}

// MARK: - Views

struct CountdownStroke: View {

    let trigger: Bool

    var body: some View {
        KeyframeAnimator(
            initialValue: StrokeAnimationProperties(),
            trigger: trigger
        ) { value in
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(.gradientTop), Color(.gradientBottom)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(
                            lineWidth: value.lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(.gray)
                    .opacity(0.3)

                Circle()
                    .trim(from: 0.0, to: min(value.progress, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [Color(.gradientTop), Color(.gradientBottom)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(
                            lineWidth: value.lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
            }
        } keyframes: { _ in
            KeyframeTrack(\.progress) {
                LinearKeyframe(0.0, duration: 0.7)

                CubicKeyframe(1.0, duration: 1.0)
                LinearKeyframe(1.0, duration: 0.7)

                CubicKeyframe(0.66, duration: 1.0)
                LinearKeyframe(0.66, duration: 0.5)

                CubicKeyframe(0.33, duration: 1.0)
                LinearKeyframe(0.33, duration: 0.5)

                CubicKeyframe(0.001, duration: 1.0)
                LinearKeyframe(0.001, duration: 0.5)

                LinearKeyframe(0.001, duration: 0.3)
            }

            KeyframeTrack(\.lineWidth) {
                SpringKeyframe(15, duration: 0.3)
                LinearKeyframe(15, duration: 6.6)
                SpringKeyframe(0, duration: 0.3)
                MoveKeyframe(0)
            }
        }
    }
}

struct CountdownText: View {

    let trigger: Bool

    var body: some View {
        ZStack {
            ForEach(CountdownPhase.allCases, id: \.self) { phase in
                Text(phase.label)
                    .font(Font.system(size: phase.fontSize))
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    .keyframeAnimator(
                        initialValue: TextAnimationProperties(),
                        trigger: trigger
                    ) { view, value in
                        view
                            .opacity(value.opacity)
                            .scaleEffect(value.scale)
                    } keyframes: { _ in
                        KeyframeTrack(\.opacity) {
                            LinearKeyframe(0.0, duration: phase.delay)
                            SpringKeyframe(1.0, duration: 0.5)
                            LinearKeyframe(1.0, duration: 1.0)
                            SpringKeyframe(0.0, duration: 0.5)
                            MoveKeyframe(0)
                        }

                        KeyframeTrack(\.scale) {
                            SpringKeyframe(CGSize(width: 0.2, height: 0.2), duration: phase.delay)
                            SpringKeyframe(CGSize(width: 1.0, height: 1.0), duration: 0.5)
                            LinearKeyframe(CGSize(width: 1.0, height: 1.0), duration: 1)
                            SpringKeyframe(CGSize(width: 0.2, height: 0.2), duration: 0.5)
                        }
                    }
            }
        }
    }
}

/// Displays a countdown before starting the workout.
struct WorkoutCountdownView: View {
    // MARK: Bindings
    @ObservedObject var viewModel: WorkoutViewModel

    @State private var isAnimating = false

    // MARK: Body
    var body: some View {
        ZStack {
            CountdownStroke(trigger: isAnimating)
            CountdownText(trigger: isAnimating)
        }
        .task {
            Task.delayed(seconds: 0.2) { @MainActor in
                if viewModel.currentScene == .countdown {
                    isAnimating = true
                }
            }

            Task.delayed(seconds: 7.1) { @MainActor in
                await viewModel.didCompleteCountdown()
            }
        }
    }
}

#if DEBUG

// MARK: - Previews
struct WorkoutCountdownViewPreview: View {
    @StateObject private var viewModel = WorkoutViewModelPreview(
        mainViewModel: Resolver.resolve(),
        errorViewModel: Resolver.resolve(),
        workoutManager: Resolver.resolve()
    )

    @State private var isPresented = false

    var body: some View {
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

#Preview {
    WorkoutCountdownViewPreview()
}

#endif
