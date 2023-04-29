//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

#if DEBUG

import SwiftUI

// MARK: - Protocols
protocol DebugLogViewModeling: ViewModeling {
    // MARK: Properties
    var logs: [TransferableLog] { get }
}

// MARK: - Main
@MainActor
class DebugLogViewModel: ViewModeling {
    // MARK: Properties
    @Published var logs: [TransferableLog] = []

    // MARK: Private Properties
    private let loggingManager: any LoggingManagement

    // MARK: Initialization
    nonisolated init(loggingManager: any LoggingManagement) {
        self.loggingManager = loggingManager
    }

    // MARK: Methods
    func appear() async {
        logs = loggingManager.getCurrentLogs().map { url in
            TransferableLog(url: url, name: url.lastPathComponent)
        }
    }
}

// MARK: - Data Structure
/// Represents a log file than can be shared.
struct TransferableLog: Hashable, Transferable {
    // MARK: Properties
    /// The URL on-disk.
    let url: URL

    /// The name of the log.
    let name: String

    // MARK: Transferable
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .text) { transferable in
            SentTransferredFile(transferable.url)
        }
    }
}

#endif
