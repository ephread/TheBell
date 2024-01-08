//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

extension HeartRateZone {
    /// Color to use when displaying the zone.
    var color: Color {
        return switch self {
        case .idle: Color(.idleHeartRate)
        case .veryLow: Color(.veryLowHeartRate)
        case .low: Color(.lowHeartRate)
        case .medium: Color(.mediumHeartRate)
        case .high: Color(.highHeartRate)
        case .veryHigh: Color(.veryHighHeartRate)
        }
    }
}
