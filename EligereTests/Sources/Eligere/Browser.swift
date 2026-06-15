import AppKit
import Foundation

public struct Browser: Codable, Observable, Equatable, Hashable, Sendable {
    public let name: String
    public let profile: String?
    public let shortcut: String?
    public let domains: [String]?
    public let apps: [String]?

    public let `default`: Bool?
    public let hidden: Bool?
    public let arguments: [String]?

    public var id: String {
        if let profile = profile, !profile.isEmpty {
            return "\(name):\(profile)"
        }
        return name
    }

    public var displayName: String {
        if let profile = profile, !profile.isEmpty {
            return "\(name) (\(profile))"
        }
        return name
    }

    public var appName: String {
        return name + ".app"
    }

    public var appURL: URL? {
        return try? FileManager.default.url(
            for: .applicationDirectory, in: .localDomainMask, appropriateFor: nil,
            create: false
        ).appendingPathComponent(appName)
    }

    public var image: NSImage? {
        return NSWorkspace.shared.runningApplications.first { $0.localizedName == self.name }?.icon
            ?? NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
    }

    public func isKeyShortcut(_ key: Character) -> Bool {
        return shortcut ?? "" == String(key) || shortcut?.uppercased() ?? "" == String(key)
    }

    public func isValid() -> Bool {
        guard let appURL = appURL else { return false }
        return FileManager.default.fileExists(atPath: appURL.path)
    }

    public static func == (lhs: Browser, rhs: Browser) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
