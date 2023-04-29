//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

#if DEBUG

import SwiftUI

// A simple view to preview Asynchronous timer.

@MainActor
class TimerPreviewViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTimeLabel: TimeInterval = 0

    private var timer: RepeatingTimer?
    private var elapsedTimeTracker: ElapsedTimeTracker?
    private var roundCountdownTimer: RoundCountdownTimer?

    private let dateTimeHelper = DateTimeHelper()

    var elapsedTimeLabel: String {
        let components = dateTimeHelper.timeComponents(from: elapsedTime)
        return "\(components.hours):\(components.minutes):\(components.seconds)"
    }

    init() {
        timer = RepeatingTimer(timeInterval: 2) {
            self.count += 1
        }

        elapsedTimeTracker = ElapsedTimeTracker()
        roundCountdownTimer = RoundCountdownTimer()
    }

    func appear() async {
        await timer?.start()
        await elapsedTimeTracker?.startTracking(from: .now) { timeInterval in
            self.elapsedTime = timeInterval
        }
        await roundCountdownTimer?.start(with: 300) { timeInterval in
            self.remainingTimeLabel = timeInterval
        }
    }
}

struct TimerPreview: View {
    @ObservedObject var sut = TimerPreviewViewModel()

    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                Text("COU:")
                Text("ELA:")
                Text("REM:")
            }

            VStack(alignment: .leading) {
                Text("\(sut.count)")
                Text(sut.elapsedTimeLabel)
                Text("\(sut.remainingTimeLabel)")
            }
        }
        .task {
            Task { await sut.appear() }
        }

    }
}

struct Timer_Previews: PreviewProvider {
    static var previews: some View {
        TimerPreview()
    }
}

#endif
