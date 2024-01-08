//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

enum WorkoutState: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.running, .running): return true
        case (.completed, .completed): return true
        case (.paused, .paused): return true
        case (.error, .error): return true
        default: return false
        }
    }

    case idle
    case running
    case completed(WorkoutSummary?)
    case paused

    case error((any DisplayableError)?)

    var name: String {
        switch self {
        case .idle: return "idle"
        case .running: return "running"
        case .completed: return "completed"
        case .paused: return "paused"
        case .error: return "error"
        }
    }
}
