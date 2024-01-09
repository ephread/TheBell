//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest

extension XCUIApplication {
    /// Uninstall the given app from the carousel.
    ///
    /// - Parameter name: The name of the app to uninstall.
    func uninstall(name: String? = nil) {
        let carousel = XCUIApplication(bundleIdentifier: "com.apple.Carousel")

        // Make sure The Bell is not running.
        self.terminate()

        // Either use the provided App Name or retrieve it from the test runner.
        let appName = self.appName(from: name)

        // Using '.firstMatch' makes sense on iPad because of the dock
        // (multiple icons for the same app), but on the Watch it's
        // probably unnecessary.
        let icon = carousel.icons[appName].firstMatch

        guard icon.waitForExistence(timeout: 1) else {
            print("Failed to find app icon named \(appName), ignoring.")
            return
        }

        // Long press the icon.
        icon.press(forDuration: 2)

        // Tap on the close button (top left corner in LTR).
        let iconFrame = icon.frame
        let carouselFrame = carousel.frame

        let vector = CGVector(
            dx: (iconFrame.minX + 3) / carouselFrame.maxX,
            dy: (iconFrame.minY + 3) / carouselFrame.maxY
        )

        carousel.coordinate(withNormalizedOffset: vector).tap()

        // Confirm removal (English-only).
        carousel.alerts.buttons["Delete App"].tap()
        carousel.alerts.buttons["OK"].tap()
    }

    private func appName(from name: String?) -> String {
        if let name = name {
            return name
        } else {
            // swiftlint:disable:next force_cast
            let uiTestRunnerName = Bundle.main.infoDictionary?["CFBundleName"] as! String
            return uiTestRunnerName.replacingOccurrences(of: " UI Tests-Runner", with: "")
        }
    }
}
