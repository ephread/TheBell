//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver
import Defaults

// MARK: - Views
/// Main view of the app. Users can start a workout or navigate
/// to the preference screen
struct HomeView: View {
    // MARK: Properties
    @InjectedObject private var viewModel: HomeViewModel

    // MARK: Body
    var body: some View {
        ZStack {
            if viewModel.isWelcomeMessageDisplayed {
                WelcomeView()
            } else if viewModel.isWorkoutDisplayed {
                WorkoutView()
            } else {
                List {
                    Button {
                        Task { await viewModel.prepareWorkout() }
                    } label: {
                        VStack(spacing: 10) {
                            Image(Asset.Images.workoutButtonIcon.name)

                            VStack {
                                Text(viewModel.buttonTitle)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .textCase(.uppercase)
                                Text(viewModel.buttonSubtitle)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black.opacity(0.5))
                                    .textCase(.uppercase)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.workout)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .accessibilityIdentifier("Main_WorkoutButton")
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())

                    NavigationLink {
                        PreferencesView()
                    } label: {
                        Text(L10n.Preference.title)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .foregroundColor(Asset.Colors.accentColor.swiftUIColor)
                }
                .accessibilityIdentifier("Main_ScrollView")
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarHidden(viewModel.isNavigationBarHidden)
        .navigationBarTitleDisplayMode(viewModel.navigationBarDisplayMode)
        .task { await viewModel.appear() }
    }
}

// MARK: - Previews
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Defaults[.hasSeenWelcomeMessage] = true

        return Group {
            NavigationStack {
                HomeView()
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
            .previewDisplayName("Series 6 - 40mm")

            NavigationStack {
                HomeView()
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
            .previewDisplayName("Series 7 - 45mm")
        }
    }
}

#if DEBUG

/// Previews error logic.
struct MainViewError_Previews: PreviewProvider {
    private static let errorViewModel = ErrorViewModel()

    static var previews: some View {
        Defaults[.hasSeenWelcomeMessage] = true

        return Resolver.Preview { preview in
            preview.register {
                errorViewModel
            }
            .scope(.application)
        } content: {
            NavigationStack {
                HomeView()
                    .onAppear {
                        errorViewModel.currentError = HealthKitError.storeNotReady
                    }
            }
            .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
            .previewDisplayName("Error | Series 7 - 45mm")
        }
    }
}

#endif
