//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//
// Copyright © 2022 Łukasz Rutkowski
// Licensed under the terms of the MIT License
//

import Foundation
import OSLog

// Inspired by https://github.com/Tunous/DebouncedOnChange; MIT licensed.

extension Task {

    /// Asynchronously runs the given `operation` in its own task
    /// after the specified number of `seconds`.
    ///
    /// - Parameters:
    ///   - time: The amount of time to wait in seconds.
    ///   - operation: The operation to execute.
    /// - Returns: The cancellable task.
    @discardableResult
    public static func delayed(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async -> Void
    ) -> Self where Success == Void, Failure == Never {
        Self {
            do {
                let nanoseconds = UInt64(seconds * TimeInterval(NSEC_PER_SEC))
                try await Task<Never, Never>.sleep(nanoseconds: nanoseconds)
                await operation()
            } catch {
                // Do nothing, because if the task raises an exception, it means it was cancelled.
            }
        }
    }
}
