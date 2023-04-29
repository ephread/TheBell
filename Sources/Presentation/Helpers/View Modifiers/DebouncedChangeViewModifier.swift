//
// Copyright © 2020-2023 Frédéric Maquin <fred@ephread.com>
// Copyright © 2022 Łukasz Rutkowski
// All Rights Reserved
//

import SwiftUI

// Inspired by https://github.com/Tunous/DebouncedOnChange; MIT licensed.

// MARK: Private Modifier
private struct DebouncedChangeViewModifier<Value: Equatable>: ViewModifier {
    // MARK: Properties
    let trigger: Value
    let debounceTime: TimeInterval
    let action: (Value) -> Void

    // MARK: Private State
    @State private var debouncedTask: Task<Void, Never>?

    // MARK: Body
    func body(content: Content) -> some View {
        content.onChange(of: trigger) { value in
            debouncedTask?.cancel()
            debouncedTask = Task.delayed(seconds: debounceTime) { @MainActor in
                action(value)
            }
        }
    }
}

// MARK: View Extension
extension View {
    /// Performs an action when a specified value changes, after the given `debounceTime`.
    ///
    /// Calls to this modifier are debounced. Each time the value changes before
    /// `debounceTime` elapses, the previous action is cancelled and the next
    /// action is scheduled to run after that time elapses again.
    ///
    /// This modifier uses `onChange` internally, so refer to its documentation for
    /// more information.
    ///
    /// - Parameters:
    ///   - value: The value to check when determining whether to run the closure.
    ///            The value must conform to the ``Equatable`` protocol.
    ///   - debounceTime: The time in seconds to wait after each value change
    ///                   before running the `action` closure.
    ///   - action: A closure to run when the value changes. The closure
    ///             takes a `newValue` parameter that indicates the updated value.
    /// - Returns: A view that runs an action when the specified value changes
    ///            and after the given time elapses.
    public func onChange<Value: Equatable>(
        of value: Value,
        debounceTime: TimeInterval,
        perform action: @escaping (_ newValue: Value) -> Void
    ) -> some View {
        self.modifier(
            DebouncedChangeViewModifier(trigger: value, debounceTime: debounceTime, action: action)
        )
    }
}
