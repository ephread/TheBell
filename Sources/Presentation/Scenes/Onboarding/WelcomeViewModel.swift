//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Defaults
import SwiftUI

// MARK: - Protocols
/// Provides data to the welcome view, where users
/// can give access to HealthKit.
@MainActor
protocol WelcomeViewModeling: AnyObject,
                              ViewModeling {
    /// `true` is the view model is currently requesting
    /// access to HealthKit's data store. Views can use this
    /// property to disable user input.
    var isRequestingAccessToTheHealthStore: Bool { get }

    /// Requests access to the health store asynchronously.
    func requestAccessToHealthStore() async
}

// MARK: - Main Class
class WelcomeViewModel: ObservableObject,
                        WelcomeViewModeling {
    // MARK: Properties
    @Published var isRequestingAccessToTheHealthStore = false

    // MARK: Private Properties
    /// A reference to the main view model is necessary to dismiss the sheet
    /// once the permissions have been set by the user.
    private let mainViewModel: any HomeViewModeling
    private let errorViewModel: any ErrorViewModeling
    private let healthkitManager: any HealthKitManagement

    // MARK: Initialization
    nonisolated init(
        mainViewModel: any HomeViewModeling,
        errorViewModel: any ErrorViewModeling,
        healthkitManager: any HealthKitManagement
    ) {
        self.mainViewModel = mainViewModel
        self.errorViewModel = errorViewModel
        self.healthkitManager = healthkitManager
    }

    // MARK: Methods
    func requestAccessToHealthStore() async {
        isRequestingAccessToTheHealthStore = true

        // Ensures user interaction is re-enabled if an error occurred.
        defer { isRequestingAccessToTheHealthStore = false }

        do {
            try await self.healthkitManager.requestAccessToHealthStore()

            Defaults[.hasSeenWelcomeMessage] = true

            try await self.healthkitManager.loadPreferredEnergyUnit()

            withAnimation {
                mainViewModel.isWelcomeMessageDisplayed = false
            }
        } catch let error as HealthKitError {
            errorViewModel.push(error: error) { [weak self] in
                withAnimation {
                    self?.mainViewModel.isWelcomeMessageDisplayed = false
                }
            }
        } catch {
            // Nothing else to do, because `requestAccessToHealthStore` and
            // `loadPreferredEnergyUnit` can only throw errors of type HealthKitError
        }
    }
}
