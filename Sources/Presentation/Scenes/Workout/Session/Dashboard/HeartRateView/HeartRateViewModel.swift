//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import SwiftUI

@MainActor
/// Manages the image sequence displayed by ``HeartRateView``.
protocol HeartRateViewModeling: ObservableObject {
    // MARK: Properties
    /// The name of the image currently displayed. This property
    /// is updated multiple times per seconds to recreate a beating
    /// heart animation.
    var currentIcon: ImageResource { get }

    /// The current state, which informs which image sequence is used
    /// and how fast it animates.
    var heartRateStyle: HeartRateStyle { get }

    // MARK: Methods
    /// Updates the current state.
    func update(heartRate: HeartRateStyle) async
}

// TODO: Migrate To Phase Animation or TimelineView.
class HeartRateViewModel: HeartRateViewModeling {
    // MARK: Published Properties
    @Published var currentIcon: ImageResource = .heartbeatLoading0

    // MARK: Properties
    var heartRateStyle: HeartRateStyle = .loading {
        didSet { Task { await update(heartRate: heartRateStyle) } }
    }

    // MARK: Private Properties
    /// Contains a sequence of image names used to create the animation.
    private var speakerAnimation: [ImageResource] = []

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
            currentIcon = .heartbeatLoading0
            speakerAnimation = {
                (0...60).map { ImageResource(name: "heartbeat_loading_\($0)", bundle: .main) }
            }()

            timeInterval = 2.0 / 61.0
        case .beating(let bpm):
            currentIcon = .heartbeat0
            speakerAnimation = {
                (0...8).map { ImageResource(name: "heartbeat_\($0)", bundle: .main) }
            }()

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

        self.currentIcon = self.speakerAnimation[self.currentIconIndex]
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
