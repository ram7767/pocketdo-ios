import Foundation
import OSLog

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "app"

    static let network = Logger(subsystem: subsystem, category: "network")
    static let database = Logger(subsystem: subsystem, category: "database")
    static let ui = Logger(subsystem: subsystem, category: "ui")

    static func debug(_ msg: String, category: Logger = AppLogger.ui) {
        category.debug("\(msg)")
    }
}
