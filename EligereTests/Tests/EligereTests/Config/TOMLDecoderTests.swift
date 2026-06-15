import Testing
@testable import Eligere

struct TOMLDecoderTests {

    @Test func decodeSimpleConfig() throws {
        let toml = #"""
        useOnlyRunningBrowsers = true
        stripTrackingAttributes = false
        expandShortenURLs = false
        pinningSeconds = 60
        logLevel = "debug"

        [[browsers]]
        name = "Safari"
        shortcut = "s"
        domains = ["apple.com"]
        """#

        let config = try TOMLParser.decode(stringValue: toml)
        #expect(config.useOnlyRunningBrowsers == true)
        #expect(config.stripTrackingAttributes == false)
        #expect(config.expandShortenURLs == false)
        #expect(config.pinningSeconds == 60)
        #expect(config.logLevel == "debug")
        #expect(config.browsers.count == 1)
        #expect(config.browsers[0].name == "Safari")
        #expect(config.browsers[0].shortcut == "s")
        #expect(config.browsers[0].domains == ["apple.com"])
    }

    @Test func decodeMultipleBrowsers() throws {
        let toml = #"""
        [[browsers]]
        name = "Safari"
        shortcut = "s"

        [[browsers]]
        name = "Google Chrome"
        shortcut = "c"
        default = true
        """#

        let config = try TOMLParser.decode(stringValue: toml)
        #expect(config.browsers.count == 2)
        #expect(config.browsers[0].name == "Safari")
        #expect(config.browsers[1].name == "Google Chrome")
        #expect(config.browsers[1].default == true)
    }

    @Test func decodeConfigWithoutBrowsers() throws {
        let toml = #"""
        useOnlyRunningBrowsers = false
        stripTrackingAttributes = true
        expandShortenURLs = true
        """#

        #expect(throws: Error.self) {
            try TOMLParser.decode(stringValue: toml)
        }
    }

    @Test func decodeConfigWithEmptyBrowsers() throws {
        let toml = #"""
        useOnlyRunningBrowsers = false
        stripTrackingAttributes = true
        expandShortenURLs = true

        [[browsers]]
        name = "Safari"
        """#

        let config = try TOMLParser.decode(stringValue: toml)
        #expect(config.browsers.count == 1)
    }

    @Test func decodeBrowserWithProfile() throws {
        let toml = #"""
        [[browsers]]
        name = "Google Chrome"
        profile = "Work"
        shortcut = "c"
        domains = ["github.com"]
        """#

        let config = try TOMLParser.decode(stringValue: toml)
        #expect(config.browsers[0].name == "Google Chrome")
        #expect(config.browsers[0].profile == "Work")
        #expect(config.browsers[0].domains == ["github.com"])
    }

    @Test func decodeBrowserWithApps() throws {
        let toml = #"""
        [[browsers]]
        name = "Arc"
        shortcut = "a"
        apps = ["Slack", "Messages"]
        """#

        let config = try TOMLParser.decode(stringValue: toml)
        #expect(config.browsers[0].apps == ["Slack", "Messages"])
    }

    @Test func decodeBrowserWithArguments() throws {
        let toml = #"""
        [[browsers]]
        name = "Firefox"
        shortcut = "f"
        arguments = ["--new-tab"]
        """#

        let config = try TOMLParser.decode(stringValue: toml)
        #expect(config.browsers[0].arguments == ["--new-tab"])
    }

    @Test func decodeInvalidConfigThrows() {
        let toml = "not valid toml {{{"
        #expect(throws: Error.self) {
            try TOMLParser.decode(stringValue: toml)
        }
    }
}
