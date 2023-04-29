//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
import Resolver

@main
struct TheBellApp: App {
    // MARK: Private Adaptor
    @WKApplicationDelegateAdaptor private var extensionDelegate: AppDelegate

    // MARK: Private Adaptor
    @InjectedObject private var errorViewModel: ErrorViewModel

    // MARK: Body
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .alert(error: $errorViewModel.currentError) {
                errorViewModel.dismiss()
            }
        }
    }
}
