//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
@testable import The_Bell

final class MockErrorViewModel: ErrorViewModeling {
    // MARK: Properties
    var currentError: (any DisplayableError)?

    // MARK: Methods
    func push(error: any DisplayableError, onDismiss: (() -> Void)?) { }
    func push(error: any DisplayableError) { }
    func dismiss() { }
}
