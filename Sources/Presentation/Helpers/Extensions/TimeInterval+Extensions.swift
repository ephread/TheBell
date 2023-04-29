//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

extension TimeInterval {
    /// Formats self into day, hour, minutes, seconds.
    /// For instance `67` would be formatted to `"1m 7s"`.
    var formated: String? {
        return formated(unitsStyle: .abbreviated)
    }

    /// Formats self into day, hour, minutes, seconds,
    /// according to the given style.
    func formated(unitsStyle style: DateComponentsFormatter.UnitsStyle) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        formatter.maximumUnitCount = 2
        return formatter.string(from: self)
    }
}

extension Int {
    /// Formats self into day, hour, minutes, seconds.
    /// For instance `67` would be formatted to `"1m 7s"`.
    var timeFormated: String? {
        return TimeInterval(self).formated
    }

    /// Formats self into day, hour, minutes, seconds,
    /// according to the given style.
    func timeFormated(unitsStyle style: DateComponentsFormatter.UnitsStyle) -> String? {
        return TimeInterval(self).formated(unitsStyle: style)
    }
}
