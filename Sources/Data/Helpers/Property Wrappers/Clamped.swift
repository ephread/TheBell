//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

/// A property wrapper that clamps its value to given boundaries.
@propertyWrapper
struct Clamped<T>: Sendable, Equatable where T: Comparable, T: Sendable {
    private var value: T
    let min: T
    let max: T

    var projectedValue: Self {
        return self
    }

    init(_ range: ClosedRange<T>) {
        self.value = range.lowerBound
        self.min = range.lowerBound
        self.max = range.upperBound
    }

    var wrappedValue: T {
        get { value }
        set { value = Swift.min(Swift.max(min, newValue), max) }
    }
}
