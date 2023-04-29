//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

extension Int {
    /// Round to the closest number that is both:
    ///     1. lower than or equal to `self`,
    ///     2. a multiple of `m`.
    ///
    /// For instance, if m = 6, 40 would round to 36 and
    /// -40 would round to -42.
    ///
    /// This method expects specific inputs:
    ///     - `self` must be positive.
    ///     - `m` must be strictly positive.
    ///     - `m` must be lower than or equal to self.
    ///
    /// If either `self` or `m` equals zero, this method returns zero.
    /// If `m` is greater than `self`, this method returns zero.
    ///
    /// - Parameter m: a number of which the resulting
    ///                number should be a multiple.
    /// - Returns: the rounded number.
    func roundedDown(toMultipleOf m: Self) -> Self {
        guard self > 0, m > 0, m <= self else { return 0 }

        return self - (self % m)
    }
}
