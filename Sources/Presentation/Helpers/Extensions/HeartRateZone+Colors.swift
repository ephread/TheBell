//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

extension HeartRateZone {
    /// Color to use when displaying the zone.
    var color: Color {
        switch self {
        case .idle: return Asset.Colors.idleHeartRate.swiftUIColor
        case .veryLow: return Asset.Colors.veryLowHeartRate.swiftUIColor
        case .low: return Asset.Colors.lowHeartRate.swiftUIColor
        case .medium: return Asset.Colors.mediumHeartRate.swiftUIColor
        case .high: return Asset.Colors.highHeartRate.swiftUIColor
        case .veryHigh: return Asset.Colors.veryHighHeartRate.swiftUIColor
        }
    }
}
