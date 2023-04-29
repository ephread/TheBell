//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Foundation
import Logging
import Puppy
import SwiftUI
import OSLog

// MARK: - Protocols
protocol LoggingManagement {
    // MARK: Methods
    func logDirectoryURL() throws -> URL
    func createLogDirectory() throws
    func makeLogger() -> Logging.Logger
    func getCurrentLogs() -> [URL]
}

// MARK: - Main Class
class LoggingManager: LoggingManagement {
    // MARK: Private Properties
    private let fileManager: FileManager

    // MARK: Initialization
    init(fileManager: FileManager) {
        self.fileManager = fileManager

        do {
            try createLogDirectory()
        } catch {
            os_log("Could not create the log directory: \(error.localizedDescription)")
        }
    }

    // MARK: Methods
    // This method throws in theory, but not in practice.
    func logDirectoryURL() throws -> URL {
        var url = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        url.appendPathComponent("logs")
        return url
    }

    func createLogDirectory() throws {
        let url = try logDirectoryURL()

        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    func makeLogger() -> Logging.Logger {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return Logger(label: "")
        }
        #endif

        var puppy = Puppy()

        #if DEBUG
        puppy.add(makeConsoleLogger())
        #endif

        do {
            puppy.add(try makeFileLogger())
        } catch {
            // If the logger can't be created we just log the error through OSLog
            // and create an empty logger.
            os_log("Could not create the file logger: \(error)")
        }

        LoggingSystem.bootstrap { label in
            var handler = PuppyLogHandler(label: label, puppy: puppy)
            // Set the logging level.
            #if DEBUG
            handler.logLevel = .trace
            #else
            handler.logLevel = .info
            #endif
            return handler
        }

        return Logger(label: "com.ephread.TheBell.swiftlog")
    }

    func getCurrentLogs() -> [URL] {
        do {
            let url = try logDirectoryURL()
            let items = try fileManager.contentsOfDirectory(atPath: url.path)

            return items.compactMap { url.appendingPathComponent($0) }
        } catch {
            os_log("Could not list the logs: \(error)")
            return []
        }
    }

    // MARK: Private Methods
    #if DEBUG
    private func makeConsoleLogger() -> ConsoleLogger {
        ConsoleLogger("com.ephread.TheBell.console", logFormat: LogFormatter())
    }
    #endif

    private func makeFileLogger() throws -> FileRotationLogger {
        let url = try logDirectoryURL()
        let fileURL = url.appendingPathComponent("the-bell.log")

        let rotationConfig = RotationConfig(
            suffixExtension: .date_uuid,
            maxFileSize: 1_024 * 1_024,
            maxArchivedFilesCount: 3
        )

        #if DEBUG
        let logLevel: LogLevel = .trace
        #else
        let logLevel: LogLevel = .info
        #endif

        return try FileRotationLogger(
            "com.ephread.TheBell.file",
            logLevel: logLevel,
            logFormat: LogFormatter(),
            fileURL: fileURL,
            rotationConfig: rotationConfig
        )
    }

    // MARK: Inner Types
    struct LogFormatter: LogFormattable {
        private let dateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSZ"
            return formatter
        }()

        // swiftlint:disable:next function_parameter_count
        func formatMessage(
            _ level: LogLevel,
            message: String,
            tag: String,
            function: String,
            file: String,
            line: UInt,
            swiftLogInfo: [String: String],
            label: String,
            date: Date,
            threadID: UInt64
        ) -> String {
            let date = dateFormat.string(from: date)
            let fileName = fileName(file)

            // swiftlint:disable:next line_length
            return "\(date) The Bell[\(threadID)] [\(level)] \(fileName)#L.\(line) \(function) \(message)"
        }
    }
}
