//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

@testable import The_Bell

final class SpyHapticSoundManager: HapticSoundManagement {
    // MARK: Properties
    var isAudioFeedbackEnabled = true
    var isHapticFeedbackEnabled = false
    var audioVolume: Float = 0.8

    // MARK: Spy Properties
    var didNotifyUser = false

    // MARK: Methods
    func notifyUser(that eventType: HapticSoundEventType) {
        didNotifyUser = true
    }
}
