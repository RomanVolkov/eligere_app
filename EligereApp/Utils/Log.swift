import Foundation
import Logging
import Puppy

@available(macOS 15.0, *)
final public class Log {

    private let logger: Logger

    private init() {
        let console = ConsoleLogger("dev.eligere.console")

        let fileLogger = try! FileLogger(
            "dev.eligere.filelogger", fileURL: Self.logPath, flushMode: .always)

        var puppy = Puppy()
        #if DEBUG
            puppy.add(console)
        #endif
        puppy.add(fileLogger)

        LoggingSystem.bootstrap {
            var handler = PuppyLogHandler(label: $0, puppy: puppy)
            // Set the logging level.
            handler.logLevel = .trace

            return handler
        }

        logger = Logger(label: "dev.eligere.logger")
    }

    nonisolated public static let shared = Log()

    public static let logPath: URL = {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        return home.appendingPathComponent(".eligere.log")
    }()

    public var config: Config!

    public func log(_ message: String, level: Log.Level) {
        let lowLevel: Level
        if let value = Level(rawValue: config?.logLevel ?? "debug)") {
            lowLevel = value
        } else {
            lowLevel = .debug
            self.logger.log(
                level: level.toPuppyLog, Logger.Message(stringLiteral: "fallback to .debug log level"))
        }

        if level.order < lowLevel.order { return }

        let message =
            Date().ISO8601Format() + " - " + level.rawValue.uppercased() + ": "
            + message
        self.logger.log(
            level: level.toPuppyLog, Logger.Message(stringLiteral: message))
    }
}

@available(macOS 15.0, *)
extension Log {
    /// The log level.
    ///
    /// Log levels are ordered by their severity, with `.trace` being the least severe and
    /// `.critical` being the most severe.
    public enum Level: String, Codable, CaseIterable {
        /// Appropriate for messages that contain information normally of use only when
        /// tracing the execution of a program.
        case trace

        /// Appropriate for messages that contain information normally of use only when
        /// debugging a program.
        case debug

        /// Appropriate for informational messages.
        case info

        /// Appropriate for conditions that are not error conditions, but that may require
        /// special handling.
        case notice

        /// Appropriate for messages that are not error conditions, but more severe than
        /// `.notice`.
        case warning

        /// Appropriate for error conditions.
        case error

        /// Appropriate for critical error conditions that usually require immediate
        /// attention.
        ///
        /// When a `critical` message is logged, the logging backend (`LogHandler`) is free to perform
        /// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
        /// debugging.
        case critical

        fileprivate var toPuppyLog: Logger.Level {
            return Logger.Level.init(rawValue: self.rawValue)!
        }

        fileprivate var order: Int {
            switch self {
            case .trace:
                return 0
            case .debug:
                return 1
            case .info:
                return 2
            case .notice:
                return 3
            case .warning:
                return 4
            case .error:
                return 5
            case .critical:
                return 6
            }
        }
    }

}
