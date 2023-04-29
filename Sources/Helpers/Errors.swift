//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import GRDB

enum HealthKitError: DisplayableError {
    case healthKitNotAvailable

    case accessRefused(Error?)
    case storeNotReady
    case unitNotAvailable(Error?)
    case databaseError(DatabaseError)

    var title: String {
        return L10n.Error.title
    }

    var message: String {
        switch self {
        case .healthKitNotAvailable: return L10n.Error.Message.healthKitNotAvailable
        case .accessRefused: return L10n.Error.Message.accessRefused
        case .storeNotReady: return L10n.Error.Message.storeNotReady
        case .unitNotAvailable: return L10n.Error.Message.unitNotAvailable
        case .databaseError(let error): return error.message
        }
    }

    var underlyingError: Error? {
        switch self {
        case .accessRefused(let error): return error
        case .unitNotAvailable(let error): return error
        case .databaseError(let error): return error.underlyingError
        default: return nil
        }
    }

    var errorDescription: String? {
        if let underlyingError {
            return underlyingError.localizedDescription
        } else {
            return message
        }
    }
}

enum WorkoutError: DisplayableError {
    case couldNotAccessHealthStore

    case couldNotStartWorkout
    case couldNotStartDataCollection(Error?)

    case couldNotEndDataCollection(Error?)
    case couldNotEndWorkout(Error?)

    case couldNotRestoreWorkout(Error?)

    case workoutAlreadyRunning
    case authorizationDenied

    var title: String {
        return L10n.Error.title
    }

    var message: String {
        switch self {
        case .couldNotAccessHealthStore: return L10n.Error.Message.couldNotAccessHealthStore
        case .couldNotStartWorkout: return L10n.Error.Message.couldNotStartWorkout
        case .couldNotStartDataCollection: return L10n.Error.Message.couldNotStartDataCollection
        case .couldNotEndDataCollection: return L10n.Error.Message.couldNotEndDataCollection
        case .couldNotEndWorkout: return L10n.Error.Message.couldNotEndWorkout
        case .couldNotRestoreWorkout: return L10n.Error.Message.couldNotRestoreWorkout
        case .workoutAlreadyRunning: return L10n.Error.Message.workoutAlreadyRunning
        case .authorizationDenied: return L10n.Error.Message.authorizationDenied
        }
    }

    var underlyingError: Error? {
        switch self {
        case .couldNotStartDataCollection(let error): return error
        case .couldNotEndDataCollection(let error): return error
        case .couldNotEndWorkout(let error): return error
        case .couldNotRestoreWorkout(let error): return error
        default: return nil
        }
    }

    var errorDescription: String? {
        if let underlyingError {
            return underlyingError.localizedDescription
        } else {
            return message
        }
    }
}

enum DatabaseError: DisplayableError {
    case databaseError(GRDB.DatabaseError)
    case persistenceError(GRDB.PersistenceError)
    case unknownError(Error)

    var title: String {
        return L10n.Error.title
    }

    var message: String {
        return L10n.Error.Message.database(errorCode)
    }

    var errorCode: String {
        switch self {
        case .databaseError(let error): return "DB\(error.extendedResultCode.rawValue)"
        case .persistenceError: return "DBP1"
        case .unknownError: return "DBU1"
        }
    }

    var underlyingError: Error? {
        switch self {
        case .databaseError(let error): return error
        case .persistenceError(let error): return error
        case .unknownError(let error): return error
        }
    }

    var errorDescription: String? {
        if let underlyingError {
            return underlyingError.localizedDescription
        } else {
            return message
        }
    }
}

protocol DisplayableError: LocalizedError {
    var title: String { get }
    var message: String { get }

    var underlyingError: Error? { get }
}

#if DEBUG

struct FakeError: LocalizedError {
    var errorDescription: String? = "Fake Error"
}

#endif
