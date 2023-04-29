//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import HealthKit

enum EnergyUnit: String, Codable {
    case joule
    case kilojoule
    case calorie
    case kilocalorie

    var longName: String {
        switch self {
        case .joule: return L10n.Unit.Energy.joules
        case .kilojoule: return L10n.Unit.Energy.kilojoules
        case .calorie: return L10n.Unit.Energy.calories
        case .kilocalorie: return L10n.Unit.Energy.kilocalories
        }
    }

    var shortName: String {
        switch self {
        case .joule: return L10n.Unit.Energy.Short.joules
        case .kilojoule: return L10n.Unit.Energy.Short.kilojoules
        case .calorie: return L10n.Unit.Energy.Short.calories
        case .kilocalorie: return L10n.Unit.Energy.Short.kilocalories
        }
    }

    var hkUnit: HKUnit {
        switch self {
        case .joule: return HKUnit.joule()
        case .kilojoule: return HKUnit.jouleUnit(with: .kilo)
        case .calorie: return HKUnit.smallCalorie()
        case .kilocalorie: return HKUnit.kilocalorie()
        }
    }

    func label(of type: EnergyBurnedType, style: EnergyBurnedStyle) -> String {
        switch (type, style) {
        case (.active, .long): return L10n.Workout.Unit.active(longName)
        case (.active, .short): return L10n.Workout.Unit.Active.short(shortName.uppercased())
        case (.basal, .long): return L10n.Workout.Unit.basal(longName)
        case (.basal, .short): return L10n.Workout.Unit.Basal.short(shortName.uppercased())
        case (.total, .long): return L10n.Workout.Unit.total(longName)
        case (.total, .short): return L10n.Workout.Unit.Total.short(shortName.uppercased())
        }
    }
}

enum EnergyBurnedType {
    case active, basal, total
}

enum EnergyBurnedStyle {
    case long, short
}
