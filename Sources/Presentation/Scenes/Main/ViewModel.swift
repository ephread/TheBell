//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

/// Base protocol for all view models.
protocol ViewModeling: ObservableObject {
    /// Call this method when the view appears.
    func appear() async
}

extension ViewModeling {
    func appear() async { }
}
