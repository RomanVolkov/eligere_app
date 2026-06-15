import Testing
import Foundation
@testable import Eligere

struct RoutingResultTests {

    @Test func allRuleTypesHaveRawValues() {
        let types: [RuleType] = [.onlyRunning, .sourceApp, .domain, .default, .pinned, .none]
        let expectedRawValues = [
            "Only running browser",
            "Source app rule",
            "Domain rule",
            "Default browser",
            "Pinned browser",
            "No match"
        ]
        #expect(types.map(\.rawValue) == expectedRawValues)
    }

    @Test func allRuleTypesAreCaseIterable() {
        #expect(RuleType.allCases.count == 6)
    }

    @Test func routingResultDescriptionContainsBrowserName() {
        let browser = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let url = URL(string: "https://apple.com")!
        let result = RoutingResult(browser: browser, ruleType: .domain, cleanedURL: url, expandedURL: nil, sourceApp: nil)
        #expect(result.displayDescription.contains("Safari"))
        #expect(result.displayDescription.contains("Domain rule"))
    }

    @Test func routingResultWithSourceApp() {
        let browser = Browser(name: "Chrome", profile: nil, shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let url = URL(string: "https://example.com")!
        let result = RoutingResult(browser: browser, ruleType: .sourceApp, cleanedURL: url, expandedURL: nil, sourceApp: "Slack")
        #expect(result.displayDescription.contains("Chrome"))
        #expect(result.displayDescription.contains("Source app rule"))
        #expect(result.displayDescription.contains("Slack"))
    }

    @Test func routingResultWithExpandedURL() {
        let browser = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let cleaned = URL(string: "https://example.com")!
        let expanded = URL(string: "https://expanded.example.com")!
        let result = RoutingResult(browser: browser, ruleType: .domain, cleanedURL: cleaned, expandedURL: expanded, sourceApp: nil)
        #expect(result.cleanedURL == cleaned)
        #expect(result.expandedURL == expanded)
    }
}
