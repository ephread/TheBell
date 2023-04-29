//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import XCTest

extension XCUIElement {
    /// Sends a "slow" swipe-up gesture.
    func swipeUpSlowly() {
        let starCoordinates = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoordinates = starCoordinates.withOffset(CGVector(dx: 0, dy: -10))
        starCoordinates.press(forDuration: 0.001, thenDragTo: endCoordinates)
    }
}
