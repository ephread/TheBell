//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest

class WelcomeUITests: XCTestCase {
    // MARK: Tests
    func testWelcomeNavigation() throws {
        let app = launch()

        let welcomeScrollView = app.scrollViews["Welcome_ScrollView"]
        welcomeScrollView.swipeUp()

        let requestAccessButton = app.buttons["Welcome_RequestAccessButton"]
        if requestAccessButton.waitForExistence(timeout: 2) {
            requestAccessButton.tap()
        }

        let mainScrollView = app.scrollViews["Main_ScrollView"]
        if mainScrollView.waitForExistence(timeout: 2) {
            XCTAssertTrue(mainScrollView.exists)
        }
    }

    // MARK: Private Helpers
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()

        app.uninstall()
        app.launchArguments = ["--fake-healthkit", "--reset-database"]
        app.launch()

        return app
    }
}
