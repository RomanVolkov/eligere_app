import Testing
@testable import Eligere

struct BrowserTests {

    @Test func idWithoutProfile() {
        let browser = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.id == "Safari")
    }

    @Test func idWithProfile() {
        let browser = Browser(name: "Google Chrome", profile: "Work", shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.id == "Google Chrome:Work")
    }

    @Test func displayNameWithoutProfile() {
        let browser = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.displayName == "Safari")
    }

    @Test func displayNameWithProfile() {
        let browser = Browser(name: "Google Chrome", profile: "Personal", shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.displayName == "Google Chrome (Personal)")
    }

    @Test func appName() {
        let browser = Browser(name: "Firefox", profile: nil, shortcut: "f", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.appName == "Firefox.app")
    }

    @Test func equalitySameName() {
        let a = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let b = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(a == b)
    }

    @Test func equalityDifferentName() {
        let a = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let b = Browser(name: "Chrome", profile: nil, shortcut: nil, domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(a != b)
    }

    @Test func equalitySameProfile() {
        let a = Browser(name: "Google Chrome", profile: "Work", shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let b = Browser(name: "Google Chrome", profile: "Work", shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(a == b)
    }

    @Test func equalityDifferentProfile() {
        let a = Browser(name: "Google Chrome", profile: "Work", shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        let b = Browser(name: "Google Chrome", profile: "Personal", shortcut: "c", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(a != b)
    }

    @Test func isKeyShortcut() {
        let browser = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.isKeyShortcut("s"))
        #expect(browser.isKeyShortcut("S"))
        #expect(!browser.isKeyShortcut("c"))
    }

    @Test func setDefaultAndHidden() {
        let browser = Browser(name: "Safari", profile: nil, shortcut: "s", domains: nil, apps: nil, default: nil, hidden: nil, arguments: nil)
        #expect(browser.default == nil)
        #expect(browser.hidden == nil)

        let defaultBrowser = Browser(name: "Chrome", profile: nil, shortcut: "c", domains: nil, apps: nil, default: true, hidden: nil, arguments: nil)
        #expect(defaultBrowser.default == true)

        let hiddenBrowser = Browser(name: "Arc", profile: nil, shortcut: "a", domains: nil, apps: nil, default: nil, hidden: true, arguments: nil)
        #expect(hiddenBrowser.hidden == true)
    }

    @Test func arguments() {
        let browser = Browser(name: "Firefox", profile: nil, shortcut: "f", domains: nil, apps: nil, default: nil, hidden: nil, arguments: ["--new-tab"])
        #expect(browser.arguments == ["--new-tab"])
    }

    @Test func domainsAndApps() {
        let browser = Browser(name: "Arc", profile: nil, shortcut: "a", domains: ["github.com", "apple.com"], apps: ["Slack"], default: nil, hidden: nil, arguments: nil)
        #expect(browser.domains == ["github.com", "apple.com"])
        #expect(browser.apps == ["Slack"])
    }
}
