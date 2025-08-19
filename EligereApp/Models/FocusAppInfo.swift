import Foundation

// reimplementation of `Info` from background service to decode into
public struct FocusAppInfo: Codable, CustomDebugStringConvertible {
    let bundleIdentifier: String
    let name: String
    let timestamp: Date

    public var debugDescription: String {
        return "\(self.bundleIdentifier) - \(self.name)"
    }
}
