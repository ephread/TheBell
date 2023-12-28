//
// Copyright © 2023 Frédéric Maquin <fred@ephread.com>
// Licensed under the terms of the Apache License 2.0
//

import Logging

// Convenience extensions to log an error.
extension Logging.Logger {
    /// Log a message passing the log level as a parameter.
    ///
    /// This method logs at the ``Logging.LogLevel.error`` level.
    ///
    /// - parameters:
    ///    - error: The error to be logged. Internal this method will
    ///             call ``Error.localizedDescription``.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message.
    ///    - file: The file this log message originates from (there's usually
    ///            no need to pass it explicitly as it defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's
    ///                usually no need to pass it explicitly as it defaults to
    ///                `#function`).
    ///    - line: The line this log message originates from (there's usually
    ///            no need to pass it explicitly as it defaults to `#line`).
    func error(
        _ error: @autoclosure () -> any Error,
        metadata: @autoclosure () -> Logging.Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.log(
            level: .error,
            Logger.Message(stringLiteral: error().localizedDescription),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }
}
