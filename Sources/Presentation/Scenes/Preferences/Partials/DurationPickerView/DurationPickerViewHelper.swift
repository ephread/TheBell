//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

struct DurationPickerViewHelper {
    /// Creates an array of options for a second picker from a `range`
    /// of valid seconds, striding through using `step`.
    ///
    /// This methods understands that one minutes equals sixty seconds.
    /// For instance:
    ///     1. if `range.upperBound` is greater than 60 and `step` is `10`,
    ///        the method will return `[0, 10, 20, 30, 40, 50]`;
    ///     2. if `range.lowerBound` is `5`, `range.upperBound` is 23 and
    ///        `step` is `5`, the method will return `[5, 10, 15, 20, 40, 50]`.
    ///
    /// **Preconditions**
    ///
    /// - `range` must be a positive range. (0...0) is valid, and
    ///     the method will return an empty array;
    /// - `step` must be strictly positive; striding backwards
    ///     is not supported and striding with a step of 0 makes
    ///     no sense.
    ///
    /// **Expectations**
    ///
    /// - `step` should be lower than the length of `range`
    ///    for obvious reasons. If `step` is bigger than the
    ///    range, the method will return an empty array.
    ///
    /// - Parameters:
    ///   - range: The range of seconds from which create the options.
    ///   - step: The step (**in seconds**) used to stride through `range`.
    /// - Returns: An array of options for the picker.
    func makeSecondOptions(range: ClosedRange<Int>, step: Int) -> [Int] {
        precondition(step > 0, "'step' must be strictly positive.")
        precondition(range.lowerBound >= 0 && range.upperBound >= 0, "'range' must be positive.")

        if range.upperBound >= 60 && range.upperBound != range.lowerBound {
            return Array(stride(from: 0, through: 60 - step, by: step))
        } else {
            let sLowerBound = max(step, range.lowerBound)
            let sUpperBound = range.upperBound

            return Array(stride(from: sLowerBound, through: sUpperBound, by: step))
        }
    }

    /// Creates an array of options for a minute picker from a `range`
    /// of valid seconds, striding through using `step`.
    ///
    /// This methods understands that one minutes equals sixty seconds.
    /// For instance:
    ///     1. if `range.upperBound` is lower than 60 this method returns
    ///        an array containing zero;
    ///     2. if `range.lowerBound` is `5`, range.upperBound` is 300 and
    ///        `step` is `1`, the method will return `[0, 1, 2, 3, 4, 5]`;
    ///     3. if `range.lowerBound` is `65`, range.upperBound` is 300 and
    ///        `step` is `2`, the method will return `[1, 3, 5]`.
    ///
    /// **Preconditions**
    ///
    /// - `range` must be a positive range. (0...0) is valid, and
    ///     the method will return an empty array;
    /// - `step` must be strictly positive; striding backwards
    ///     is not supported and striding with a step of 0 makes
    ///     no sense.
    ///
    /// **Expectations**
    ///
    /// - `step` should be lower than the length of `range`
    ///    for obvious reasons. If `step` is bigger than the
    ///    range, the method will return an empty array.
    ///
    /// - Parameters:
    ///   - range: The range of seconds from which create the options.
    ///   - step: The step (**in minutes**) used to stride through `range`.
    /// - Returns: An array of options for the picker.
    func makeMinuteOptions(range: ClosedRange<Int>, step: Int) -> [Int] {
        precondition(step > 0, "'step' must be strictly positive")
        precondition(range.lowerBound >= 0 && range.upperBound >= 0, "'range' must be positive.")

        if range.upperBound >= 60 {
            let mLowerBound = min(step, range.lowerBound / 60)
            let mUpperBound = range.upperBound / 60

            return Array(stride(from: mLowerBound, through: mUpperBound, by: step))
        } else {
            return [0]
        }
    }

    /// Validates that the provided `minutes` and `seconds` specify a duration that
    /// is contained in `range`. If this isn't the case, it returns the
    /// closest `minutes`/`duration` tuple specifying a valid duration.
    ///
    /// - Parameters:
    ///   - range: The range of seconds to test against.
    ///   - minutes: The minutes to validate.
    ///   - seconds: The seconds to validate.
    /// - Returns: `nil` is the provided values are valid, valid updated values otherwise.
    func validateAndUpdateTimeComponents(
        range: ClosedRange<Int>,
        minutes: Int,
        seconds: Int
    ) -> (minutes: Int, seconds: Int)? {
        let newDuration = minutes * 60 + seconds
        if !range.contains(newDuration) {
            let closestDuration = max(min(newDuration, range.upperBound), range.lowerBound)
            return (minutes: closestDuration / 60, seconds: closestDuration % 60)
        } else {
            return nil
        }
    }
}
