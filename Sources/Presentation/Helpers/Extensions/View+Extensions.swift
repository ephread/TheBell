//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

extension View {
    /// Present the content of an error as an alert when `error`
    /// is different from `nil`.
    ///
    /// - Parameters:
    ///   - error: The error to display.
    ///   - onDismiss: a block to call when the alert is dismissed.
    func alert(
        error: Binding<(any DisplayableError)?>,
        onDismiss: @escaping () -> Void = { }
    ) -> some View {
        let title: String
        if let error = error.wrappedValue {
            title = "⚠️ \(error.title)"
        } else {
            title = ""
        }

        return alert(
            title,
            isPresented: .constant(error.wrappedValue != nil),
            actions: {
                Button(L10n.General.ok) {
                    error.wrappedValue = nil
                    onDismiss()
                }
            },
            message: {
                Text(error.wrappedValue?.message ?? "")
            }
        )
    }
}

// MARK: - Previews
struct ViewExtensions_Previews: PreviewProvider {
    @State static var error: (any DisplayableError)? = WorkoutError.couldNotEndWorkout(nil)

    static var previews: some View {
        Text("Hello World!")
            .alert(error: $error)
    }
}
