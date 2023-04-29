//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

enum IntervalType {
    case round(Int, Int)
    case lastSeconds(Int, Int)
    case `break`(Int, Int)
}

enum TimerStyle {
    case normal
    case lastStretch
    case `break`
}
