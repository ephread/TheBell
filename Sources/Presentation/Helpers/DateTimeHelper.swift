//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

// MARK: - Protocols
/// Provides convenience methods to display dates and times.
protocol DateTimeHelping {
    // MARK: Methods
    func workoutSummaryDate(from date: Date) -> String
    func workoutSummaryTime(from date: Date) -> String
    func timeComponents(from duration: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int)
}

// MARK: - Main Class
class DateTimeHelper: DateTimeHelping {
    // MARK: Private Properties
    private lazy var workoutSummaryDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    private lazy var workoutSummaryTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    // MARK: Methods
    func workoutSummaryDate(from date: Date) -> String {
        workoutSummaryDateFormatter.string(from: date)
    }

    func workoutSummaryTime(from date: Date) -> String {
        workoutSummaryTimeFormatter.string(from: date)
    }

    func timeComponents(from duration: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        guard duration.isFinite, !duration.isNaN,
              duration > 0, duration < TimeInterval(Int.max) else {
            return (hours: 0, minutes: 0, seconds: 0)
        }

        let hours = self.hours(from: duration)
        let minutes = self.minutes(from: duration)
        let seconds = self.seconds(from: duration)

        return (hours: hours, minutes: minutes, seconds: seconds)
    }

    // MARK: Private Method
    private func hours(from timeInterval: TimeInterval) -> Int {
        return Int(timeInterval) / 3_600
    }

    private func minutes(from timeInterval: TimeInterval) -> Int {
        return Int(timeInterval) % 3_600 / 60
    }

    private func seconds(from timeInterval: TimeInterval) -> Int {
        return Int(timeInterval) % 3_600 % 60
    }
}
