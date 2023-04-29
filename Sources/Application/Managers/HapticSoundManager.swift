//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import AVFoundation
import WatchKit
import Logging

// MARK: - Protocols
@MainActor
protocol HapticSoundManagement {
    var isAudioFeedbackEnabled: Bool { get set }
    var isHapticFeedbackEnabled: Bool { get set }
    var audioVolume: Float { get set }

    func notifyUser(that eventType: HapticSoundEventType)
}

// MARK: - Main Class
class HapticSoundManager: NSObject,
                          HapticSoundManagement {
    // MARK: Properties
    var isAudioFeedbackEnabled = true
    var isHapticFeedbackEnabled = false
    var audioVolume: Float = 0.8 {
        didSet { setAudioVolume(audioVolume) }
    }

    // MARK: Private Properties
    private let logger: Logger

    private var dingAudioPlayer: AVAudioPlayer?
    private var twoDingsAudioPlayer: AVAudioPlayer?
    private var threeDingsAudioPlayer: AVAudioPlayer?
    private var softDingAudioPlayer: AVAudioPlayer?

    nonisolated init(logger: Logger) {
        self.logger = logger
        super.init()

        do {
            if let dingUrl = SoundEffect.ding.soundUrl,
               let twoDingsUrl = SoundEffect.twoDings.soundUrl,
               let threeDingsUrl = SoundEffect.threeDings.soundUrl,
               let softDingUrl = SoundEffect.softDing.soundUrl {
                dingAudioPlayer = try AVAudioPlayer(contentsOf: dingUrl)
                twoDingsAudioPlayer = try AVAudioPlayer(contentsOf: twoDingsUrl)
                threeDingsAudioPlayer = try AVAudioPlayer(contentsOf: threeDingsUrl)
                softDingAudioPlayer = try AVAudioPlayer(contentsOf: softDingUrl)

                dingAudioPlayer?.delegate = self
                twoDingsAudioPlayer?.delegate = self
                threeDingsAudioPlayer?.delegate = self
                softDingAudioPlayer?.delegate = self

                dingAudioPlayer?.volume = audioVolume
                twoDingsAudioPlayer?.volume = audioVolume
                threeDingsAudioPlayer?.volume = audioVolume
                softDingAudioPlayer?.volume = audioVolume
            }
        } catch {
            logger.error(error)
        }
    }

    func notifyUser(that eventType: HapticSoundEventType) {
        switch eventType {
        case .workoutDidPause:
            playHapticFeedback(.stop)
            playSound(.softDing)
        case .workoutDidResume:
            playHapticFeedback(.start)
            playSound(.softDing)
        case .roundDidReachItsLastFewSeconds:
            playHapticFeedback(.success)
            playSound(.ding)
        case .roundDidEnd:
            playHapticFeedback(.stop)
            playSound(.twoDings)
        case .roundDidStart:
            playHapticFeedback(.start)
            playSound(.twoDings)
        case .workoutDidStart:
            playHapticFeedback(.start, repeatCount: 2)
            playSound(.threeDings)
        case .workoutDidEnd:
            playHapticFeedback(.stop, repeatCount: 2)
            playSound(.threeDings)
        }
    }

    func playHapticFeedback(_ type: WKHapticType, repeatCount: Int = 1) {
        guard isHapticFeedbackEnabled else {
            return
        }

        for i in 0..<repeatCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(i) * 0.8) {
                WKInterfaceDevice.current().play(type)
            }
        }
    }

    func playSound(_ soundEffect: SoundEffect) {
        guard isAudioFeedbackEnabled else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true)

            switch soundEffect {
            case .ding: dingAudioPlayer?.play()
            case .twoDings: twoDingsAudioPlayer?.play()
            case .threeDings: threeDingsAudioPlayer?.play()
            case .softDing: softDingAudioPlayer?.play()
            }
        } catch {
            logger.error(error)
        }
    }

    // MARK: Private Methods
    private func setAudioVolume(_ volume: Float) {
        dingAudioPlayer?.volume = volume
        twoDingsAudioPlayer?.volume = volume
        threeDingsAudioPlayer?.volume = volume
        softDingAudioPlayer?.volume = volume
    }
}

extension HapticSoundManager: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            logger.error(error)
        }
    }
}

// MARK: - Enums
enum HapticSoundEventType {
    case workoutDidPause
    case workoutDidResume
    case workoutDidStart
    case workoutDidEnd
    case roundDidStart
    case roundDidReachItsLastFewSeconds
    case roundDidEnd
}

enum SoundEffect: String {
    case ding = "ding"
    case twoDings = "ding.2"
    case threeDings = "ding.3"
    case softDing = "ding.soft"

    var soundUrl: URL? {
        if let soundPath = Bundle.main.path(forResource: rawValue, ofType: "wav") {
            return URL(fileURLWithPath: soundPath)
        }

        return nil
    }
}
