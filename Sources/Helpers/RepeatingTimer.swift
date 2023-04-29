//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation

/// Repeats until cancel and execute the given action.
/// This timer executes on the Main Actor and expects
/// closures that execute on the Main Actor as well.
@MainActor
class RepeatingTimer {
    // MARK: Private Properties
    private let timeInterval: TimeInterval
    private let block: (@MainActor @Sendable () async -> Void)?
    private var repeatingTask: Task<Void, Never>?

    // MARK: Initialization
    /// Create a timer that repeatedly calls `block` every `timeInterval`
    /// until cancelled.
    ///
    /// - Parameters:
    ///   - timeInterval: The interval between each tick of the timer.
    ///   - block: The block to execute.
    init(
        timeInterval: TimeInterval,
        block: (@MainActor @Sendable @escaping () async -> Void)
    ) {
        self.timeInterval = timeInterval
        self.block = block
    }

    // MARK: Methods
    func start() async {
        await tick()
    }

    func cancel() async {
        repeatingTask?.cancel()
        repeatingTask = nil
    }

    // MARK: Private Methods
    private func tick() async {
        repeatingTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(timeInterval))

            if Task.isCancelled {
                repeatingTask = nil
                return
            } else {
                await block?()
                await tick()
            }
        }
    }
}
