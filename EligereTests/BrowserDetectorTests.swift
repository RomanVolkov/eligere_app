import Testing
import Foundation
@testable import Eligere

struct BrowserDetectorTests {

    @Test func generateTOMLIncludesHeaders() {
        let suggestions = [
            BrowserSuggestion(name: "Safari", shortcut: "s", isInstalled: true)
        ]
        let toml = BrowserDetector.generateTOML(suggestions: suggestions)
        #expect(toml.contains("useOnlyRunningBrowsers"))
        #expect(toml.contains("stripTrackingAttributes"))
        #expect(toml.contains("expandShortenURLs"))
        #expect(toml.contains("pinningSeconds"))
        #expect(toml.contains("logLevel"))
    }

    @Test func generateTOMLIncludesBrowsers() {
        let suggestions = [
            BrowserSuggestion(name: "Safari", shortcut: "s", isInstalled: true),
            BrowserSuggestion(name: "Firefox", shortcut: "f", isInstalled: true),
        ]
        let toml = BrowserDetector.generateTOML(suggestions: suggestions)
        #expect(toml.contains("[[browsers]]"))
        #expect(toml.contains(#"name = "Safari""#))
        #expect(toml.contains(#"name = "Firefox""#))
        #expect(toml.contains(#"shortcut = "s""#))
        #expect(toml.contains(#"shortcut = "f""#))
        #expect(toml.contains("default = true"))
    }

    @Test func generateTOMLEmptyList() {
        let toml = BrowserDetector.generateTOML(suggestions: [])
        #expect(toml.contains("useOnlyRunningBrowsers"))
        #expect(!toml.contains("[[browsers]]"))
    }

    @Test func generateTOMLFirstIsDefault() {
        let suggestions = [
            BrowserSuggestion(name: "Arc", shortcut: "a", isInstalled: true),
            BrowserSuggestion(name: "Safari", shortcut: "s", isInstalled: true),
            BrowserSuggestion(name: "Chrome", shortcut: "c", isInstalled: true),
        ]
        let toml = BrowserDetector.generateTOML(suggestions: suggestions)
        let browserBlocks = toml.components(separatedBy: "[[browsers]]").dropFirst()
        #expect(browserBlocks.count == 3)
    }
}
