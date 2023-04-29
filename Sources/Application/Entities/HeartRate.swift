//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import UIKit

struct HeartRate {
    let measured: Int
    let maximum: Int

    var zone: HeartRateZone {
        let hr = Double(measured)
        let mhr = Double(maximum)

        if hr < 0.5 * mhr {
            return .idle
        } else if hr >= 0.5 * mhr && hr < 0.6 * mhr {
            return .veryLow
        } else if hr >= 0.6 * mhr && hr < 0.7 * mhr {
            return .low
        } else if hr >= 0.7 * mhr && hr < 0.8 * mhr {
            return .medium
        } else if hr >= 0.8 * mhr && hr < 0.9 * mhr {
            return .high
        } else {
            return .veryHigh
        }
    }

    var percent: Double {
        return Double(measured) / Double(maximum)
    }
}

extension HeartRate: Equatable { }

enum HeartRateZone {
    case idle
    case veryLow
    case low
    case medium
    case high
    case veryHigh
}
