import Testing
@testable import Eligere

struct BrowserNameTests {

    @Test func allCasesHaveDisplayName() {
        for browserName in BrowserName.allCases {
            #expect(!browserName.displayName.isEmpty)
            #expect(browserName.displayName == browserName.rawValue)
        }
    }

    @Test func allCasesHaveDefaultShortcut() {
        for browserName in BrowserName.allCases {
            let shortcut = BrowserName.defaultShortcuts[browserName]
            #expect(shortcut != nil, "Missing shortcut for \(browserName)")
            #expect(shortcut?.count == 1, "Shortcut for \(browserName) should be single character")
        }
    }

    @Test func knownBrowsersCount() {
        #expect(BrowserName.allCases.count == 10)
    }

    @Test func rawValues() {
        #expect(BrowserName.safari.rawValue == "Safari")
        #expect(BrowserName.googleChrome.rawValue == "Google Chrome")
        #expect(BrowserName.firefox.rawValue == "Firefox")
        #expect(BrowserName.arc.rawValue == "Arc")
        #expect(BrowserName.brave.rawValue == "Brave Browser")
        #expect(BrowserName.edge.rawValue == "Microsoft Edge")
        #expect(BrowserName.opera.rawValue == "Opera")
        #expect(BrowserName.vivaldi.rawValue == "Vivaldi")
        #expect(BrowserName.orion.rawValue == "Orion")
        #expect(BrowserName.duckDuckGo.rawValue == "DuckDuckGo")
    }

    @Test func initFromRawValue() {
        #expect(BrowserName(rawValue: "Safari") == .safari)
        #expect(BrowserName(rawValue: "Google Chrome") == .googleChrome)
        #expect(BrowserName(rawValue: "Firefox") == .firefox)
        #expect(BrowserName(rawValue: "Unknown Browser") == nil)
    }
}
