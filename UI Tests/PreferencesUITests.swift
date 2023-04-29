//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest

class PreferencesUITests: XCTestCase {
    // MARK: Tests
    func testThatSoundHapticPreferencesAreSaved() throws {
        let app = launch()
        let preferenceButton = scrollAndTapOnPreferenceButton(app: app)

        let hapticSoundRow = app.buttons["Preferences_HapticSoundRow"]
        hapticSoundRow.tap()

        let audioFeedbackSwitch = app.switches["Preferences_HapticSound_AudioFeedback"]
        audioFeedbackSwitch.tap()

        let volumeSlider = app.sliders["Preferences_HapticSound_AudioVolume"]
        volumeSlider.adjust(toNormalizedSliderPosition: 0.2)

        let hapticSoundList = app.collectionViews["Preferences_HapticSound_List"]
        hapticSoundList.swipeUp()

        let hapticFeedbackButton = app.buttons["Preferences_HapticSound_HapticFeedback"]
        if hapticFeedbackButton.waitForExistence(timeout: 2) {
            hapticFeedbackButton.tap()
        }

        // Back Buttons
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        preferenceButton.tap()
        hapticSoundRow.tap()

        XCTAssertFalse(audioFeedbackSwitch.isSelected)
        XCTAssertEqual(volumeSlider.normalizedSliderPosition, 0.2, accuracy: 0.01)

        hapticSoundList.swipeUp()

        if hapticFeedbackButton.waitForExistence(timeout: 2) {
            XCTAssertTrue(audioFeedbackSwitch.isSelected)
        }
    }

    func testMaximumHeartRateIsSavedAndUpdated() throws {
        let app = launch()
        testIntegerPickerRow(in: app, named: "Preferences_HeartRateRow", against: "200")
    }

    func testRoundCountIsSavedAndUpdated() throws {
        let app = launch()
        testIntegerPickerRow(in: app, named: "Preferences_RoundCountRow", against: "20")

        XCTAssertTrue(app.buttons["Main_WorkoutButton"].label.contains("20"))
    }

    func testRoundAndLastStageDurationIsSavedAndUpdated() throws {
        // Testing both together ensures that the UI reflects that
        // the final stage's valid range depends on the round duration.
        let app = launch()
        testDurationPickerRow(in: app, named: "Preferences_RoundDurationRow", against: "55")
        testDurationPickerRow(in: app, named: "Preferences_FinaleStageDurationRow", against: "25")
    }

    func testBreakDurationIsSavedAndUpdated() throws {
        let app = launch()
        testDurationPickerRow(in: app, named: "Preferences_BreakDurationRow", against: "55")
    }

    func testThatAcknowledgmentIsReachable() throws {
        let app = launch()
        scrollAndTapOnPreferenceButton(app: app)

        let preferenceList = app.collectionViews["Preferences_List"]
        preferenceList.swipeUp()

        let button = app.buttons["Preferences_AcknowledgementRow"]
        if button.waitForExistence(timeout: 2) {
            button.tap()
        }

        app.scrollViews["Preferences_FinaleStageDuration_ScrollView"].swipeUp()
    }

    // MARK: Private Helpers
    private func testIntegerPickerRow(
        in app: XCUIApplication,
        named rowName: String,
        against value: String
    ) {
        let preferenceButton = scrollAndTapOnPreferenceButton(app: app)

        let button = app.buttons[rowName]
        button.tap()

        let picker = app.otherElements["Preferences_IntegerPicker"]
        // Swiping up twice ensure we reach 20. I haven't found a better way,
        // since the "picker" registers as an "other element".
        picker.swipeUp()
        picker.swipeUp()

        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(button.label.contains(value))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        preferenceButton.tap()

        XCTAssertTrue(button.label.contains(value))
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    private func testDurationPickerRow(
        in app: XCUIApplication,
        named rowName: String,
        against value: String
    ) {
        let preferenceButton = scrollAndTapOnPreferenceButton(app: app)

        let preferenceList = app.collectionViews["Preferences_List"]
        preferenceList.swipeUpSlowly()

        let button = app.buttons[rowName]
        if button.waitForExistence(timeout: 2) {
            button.tap()
        }

        let minutePicker = app.otherElements["Preferences_Duration_MinutePicker"]
        // Swiping up twice ensure we reach 0. I haven't found a better way,
        // since the "picker" registers as an "other element".
        minutePicker.swipeDown()
        minutePicker.swipeDown()

        let secondPicker = app.otherElements["Preferences_Duration_SecondPicker"]
        // Swiping up twice ensure we reach 25/55. I haven't found a better way,
        // since the "picker" registers as an "other element".
        secondPicker.swipeUp()
        secondPicker.swipeUp()

        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(button.label.contains(value))

        app.navigationBars.buttons.element(boundBy: 0).tap()
        preferenceButton.tap()

        preferenceList.swipeUpSlowly()

        XCTAssertTrue(button.label.contains(value))

        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    @discardableResult
    private func scrollAndTapOnPreferenceButton(app: XCUIApplication) -> XCUIElement {
        app.scrollViews["Main_ScrollView"].swipeUp()

        let preferenceButton = app.buttons["Main_PreferencesButton"]
        if preferenceButton.waitForExistence(timeout: 2) {
            preferenceButton.tap()
        }

        return preferenceButton
    }

    private func launch() -> XCUIApplication {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
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
