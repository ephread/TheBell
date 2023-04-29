//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

@MainActor
/// Manages the image sequence displayed by ``HeartRateView``.
protocol HeartRateViewModeling: ObservableObject {
    // MARK: Properties
    /// The name of the image currently displayed. This property
    /// is updated multiple times per seconds to recreate a beating
    /// heart animation.
    var currentIconName: String { get }

    /// The current state, which informs which image sequence is used
    /// and how fast it animates.
    var heartRateStyle: HeartRateStyle { get }

    // MARK: Methods
    /// Updates the current state.
    func update(heartRate: HeartRateStyle) async
}

class HeartRateViewModel: HeartRateViewModeling {
    // MARK: Published Properties
    @Published var currentIconName: String = Asset.Images.heartbeatLoading0.name

    // MARK: Properties
    var heartRateStyle: HeartRateStyle = .loading {
        didSet { Task { await update(heartRate: heartRateStyle) } }
    }

    // MARK: Private Properties
    /// Contains a sequence of image names used to create the animation.
    private var speakerAnimation: [String] = []

    /// The index of the current image displayed, from ``speakerAnimation``.
    private var currentIconIndex: Int = 0

    /// The timer updating the current image.
    private var timer: RepeatingTimer?

    // MARK: Initialization
    init(heartRateStyle: HeartRateStyle = .loading) {
        self.heartRateStyle = heartRateStyle
        Task { await update(heartRate: heartRateStyle) }
    }

    // MARK: Methods
    func update(heartRate: HeartRateStyle) async {
        await timer?.cancel()

        let timeInterval: CGFloat
        switch heartRate {
        case .loading:
            currentIconName = Asset.Images.heartbeatLoading0.name
            speakerAnimation = { (0...60).map { "heartbeat_loading_\($0)" } }()
            timeInterval = 2.0 / 61.0
        case .beating(let bpm):
            currentIconName = Asset.Images.heartbeat0.name
            speakerAnimation = { (0...8).map { "heartbeat_\($0)" } }()
            timeInterval = (60.0 / CGFloat(bpm)) / 9.0
        }

        timer = RepeatingTimer(timeInterval: timeInterval) { [weak self] in
            await self?.updateIcon()
        }

        await timer?.start()
    }

    // MARK: Private Methods
    private func updateIcon() async {
        if self.currentIconIndex >= self.speakerAnimation.count - 1 {
            self.currentIconIndex = 0
        } else {
            self.currentIconIndex += 1
        }

        self.currentIconName = self.speakerAnimation[self.currentIconIndex]
    }
}

// MARK: Enums
/// The style of the beating heart.
enum HeartRateStyle: Equatable {
    /// Displays a loading animation.
    case loading
    /// Displays a beating animation, following the given BPM.
    case beating(bpm: Int)
}
