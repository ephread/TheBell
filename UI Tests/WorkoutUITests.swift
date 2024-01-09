//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest

class WorkoutUITests: XCTestCase {
    // MARK: Tests
    func testWorkoutNavigation() throws {
        // Since we can't bypass HealthKit's permissions, UI tests use
        // a fake version of HealthKitManager. It doesn't make sense
        // to write a complex automated test that doesn't test
        // the real logic, therefore we are only testing the navigation here.
        let app = launch()

        let mainList = app.collectionViews["Main_List"]
        let workoutButton = app.buttons["Main_WorkoutButton"]
        workoutButton.tap()

        let workoutTabView = app.otherElements["Workout_TabView"]
        if workoutTabView.waitForExistence(timeout: 10) {
            workoutTabView.swipeLeft()
            workoutTabView.swipeRight()
            workoutTabView.swipeRight()
        }

        let pauseResumeButton = app.buttons["WorkoutControl_PauseResumeButton"]
        pauseResumeButton.tap()

        workoutTabView.swipeLeft()
        workoutTabView.swipeRight()

        pauseResumeButton.tap()

        workoutTabView.swipeLeft()
        workoutTabView.swipeRight()

        let endButton = app.buttons["WorkoutControl_EndButton"]
        endButton.tap()

        app.scrollViews["WorkoutSummary_ScrollView"].swipeUp()
        let doneButton = app.buttons["WorkoutSummary_DoneButton"]

        // Using 'firstMatch' because SwiftUI attaches the identifier to
        // multiple buttons down the hierarchy.
        if doneButton.firstMatch.waitForExistence(timeout: 2) {
            doneButton.firstMatch.tap()
        }

        XCTAssertTrue(mainList.exists)
    }

    // MARK: Private Helpers
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()

        app.uninstall()
        app.launchArguments = ["--fake-healthkit", "--no-welcome", "--reset-database"]
        app.launch()

        return app
    }

    private func performWelcomeProgressionIfNecessary(app: XCUIApplication) {
        if app.scrollViews["Welcome_ScrollView"].exists {
            app.scrollViews["Welcome_ScrollView"].swipeUp()

            let requestAccessButton = app.buttons["Welcome_RequestAccessButton"]
            if requestAccessButton.waitForExistence(timeout: 2) {
                requestAccessButton.tap()
            }
        }
    }
}
