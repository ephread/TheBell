//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Defaults
import SwiftUI

// MARK: - Protocols
/// Manages an error currently displayed on screen.
@MainActor
protocol ErrorViewModeling: ViewModeling {
    /// The current error to display.
    ///
    /// This property is readonly so that side effects can be managed
    /// through ``setCurrentError(_:)``.
    var currentError: (any DisplayableError)? { get }

    func push(error: any DisplayableError, onDismiss: (() -> Void)?)
    func push(error: any DisplayableError)

    func dismiss()
}

// MARK: - Main Class
/// A concrete implementation of ``ErrorViewModeling``.
/// TODO: Write documentation.
class ErrorViewModel: ErrorViewModeling {
    // MARK: Published Properties
    /// Error to be displayed by the view.
    @Published var currentError: (any DisplayableError)?

    // MARK: Private Properties
    /// The current error.
    private var currentActionableError: ActionableError?

    /// Queue of error to display.
    private var errorQueue: [ActionableError] = []

    // MARK: Initialization
    nonisolated init() { }

    // MARK: Method
    func push(error: any DisplayableError) {
        push(error: error, onDismiss: nil)
    }

    func push(error: any DisplayableError, onDismiss: (() -> Void)?) {
        errorQueue.append(ActionableError(error: error, action: onDismiss))
        popAndDisplayNextError()
    }

    func dismiss() {
        currentActionableError?.action?()
        currentActionableError = nil
        currentError = nil

        popAndDisplayNextError()
    }

    // MARK: - Private Methods
    private func popAndDisplayNextError() {
        // If currentError isn't nil, it needs to be dismissed by the user first.
        guard currentError == nil, currentActionableError == nil else { return }

        // If the queue is empty, no error to show.
        guard !errorQueue.isEmpty else { return }

        let actionableError = errorQueue.removeLast()
        currentActionableError = actionableError

        withAnimation {
            currentError = actionableError.error
        }
    }

    // MARK: - Data structure
    /// An error with its related action.
    struct ActionableError {
        let error: any DisplayableError
        let action: (() -> Void)?
    }
}
