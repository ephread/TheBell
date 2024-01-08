//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver

// MARK: - Views
/// Displayed the first time the app is launched or until the user
/// completed the HealthKit permission prompt.
struct WelcomeView: View {
    // MARK: Properties
    @InjectedObject var viewModel: WelcomeViewModel

    // MARK: Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(.welcome)
                    .padding(.top, 20)

                Text(L10n.Welcome.description)
                    .multilineTextAlignment(.leading)

                Button {
                    Task { await viewModel.requestAccessToHealthStore() }
                } label: {
                    HStack {
                        if viewModel.isRequestingAccessToTheHealthStore {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.black)
                        } else {
                            Text(L10n.Welcome.grantPermissions)
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .foregroundStyle(Color.black)
                .disabled(viewModel.isRequestingAccessToTheHealthStore)
                .accessibilityIdentifier("Welcome_PermissionButton")
            }

        }
        .accessibilityIdentifier("Welcome_ScrollView")
    }
}

#if DEBUG

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 40mm"))
                .previewDisplayName("Series 6 - 40mm")

            WelcomeView()
                .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 7 - 45mm"))
                .previewDisplayName("Series 7 - 45mm")
        }
    }
}

#endif
