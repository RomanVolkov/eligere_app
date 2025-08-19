import AppKit
import Foundation

struct Info: Codable {
    let bundleIdentifier: String
    let name: String
    let timestamp: Date

    init(from app: NSRunningApplication) {
        self.bundleIdentifier = app.bundleIdentifier ?? "unknown"
        self.name = app.localizedName ?? "unknown"
        self.timestamp = Date()
    }
}
