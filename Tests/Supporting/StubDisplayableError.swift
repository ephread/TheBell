//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
@testable import The_Bell

struct StubDisplayableError: DisplayableError {
    // MARK: Properties
    let title: String
    let message: String

    let underlyingError: Error? = nil
}

extension StubDisplayableError: Equatable {
    static func == (lhs: StubDisplayableError, rhs: StubDisplayableError) -> Bool {
        lhs.title == rhs.title && lhs.message == rhs.message
    }
}
