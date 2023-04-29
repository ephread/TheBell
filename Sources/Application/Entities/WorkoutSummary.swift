//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

///
struct WorkoutSummary: Hashable {
    let activeEnergyBurned: Int?
    let totalEnergyBurned: Int?

    let averageHeartRate: Int?
    let minimumHeartRate: Int?
    let maximumHeartRate: Int?

    let startDate: Date
    let endDate: Date

    let totalDuration: TimeInterval
    let expectedTotalDuration: TimeInterval

    let energyUnit: EnergyUnit
}
