import Foundation

public enum RuleType: String, Codable, CaseIterable, Sendable {
    case onlyRunning = "Only running browser"
    case sourceApp = "Source app rule"
    case domain = "Domain rule"
    case `default` = "Default browser"
    case pinned = "Pinned browser"
    case none = "No match"
}

public struct RoutingResult: Sendable {
    public let browser: Browser
    public let ruleType: RuleType
    public let cleanedURL: URL
    public let expandedURL: URL?
    public let sourceApp: String?
    
    public var displayDescription: String {
        var parts: [String] = []
        parts.append("Browser: \(browser.name)")
        parts.append("Rule: \(ruleType.rawValue)")
        if let sourceApp = sourceApp {
            parts.append("Source app: \(sourceApp)")
        }
        return parts.joined(separator: "\n")
    }
}
