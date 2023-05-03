//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI
@testable import The_Bell

final class MockSpyHomeViewModel: HomeViewModeling {

    // MARK: Properties
    var buttonTitle: String = ""
    var buttonSubtitle: String = ""
    var navigationTitle: String = ""

    var isWelcomeMessageDisplayed = false
    var isWorkoutDisplayed = false
    var isNavigationBarHidden = false
    var navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode = .automatic

    var didCallOnboardingDidComplete = false

    // MARK: Methods
    func prepareWorkout() async { }

    func setIsWelcomeMessageDisplayed(_ value: Bool) {
        isWelcomeMessageDisplayed = value
    }

    func setIsWorkoutDisplayed(_ value: Bool) {
        isWorkoutDisplayed = value
    }

    func onboardingDidComplete() {
        didCallOnboardingDidComplete = true
    }
}
