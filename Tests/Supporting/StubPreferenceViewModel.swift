//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Combine
import GRDB

@testable import The_Bell

final class StubPreferenceViewModel: PreferencesViewModeling {
    // MARK: Properties
    var heartRate = 0

    var roundCount = 0

    var roundMinuteDuration = 0
    var roundSecondDuration = 0

    var breakMinuteDuration = 0
    var breakSecondDuration = 0

    var lastStretchMinuteDuration = 0
    var lastStretchSecondDuration = 0

    var isAudioFeedbackEnabled = false
    var isHapticFeedbackEnabled = false
    var audioVolume: Float = 0.0

    // MARK: Methods
    func range(forRow row: The_Bell.PreferenceRowRange) -> ClosedRange<Int> {
        return 0...0
    }

    func step(forRowSegment: The_Bell.PreferenceRowStep) -> Int {
        return 0
    }

    func title(forSection section: The_Bell.PreferenceSection) -> String {
        return ""
    }

    func title(forRow row: The_Bell.PreferenceRow) -> String {
        return ""
    }

    func caption(forRow row: The_Bell.PreferenceRow) -> String {
        return ""
    }

    func footnote(forRow row: The_Bell.PreferenceFootnote) -> String {
        return ""
    }
}
