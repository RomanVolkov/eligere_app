import AppKit
import Foundation

public protocol URLOpenerProtocol {
    @MainActor
    func open(url: URL, with browser: Browser, withTermination: Bool)
    @MainActor
    func open(url: URL, with browser: Browser)
}

public extension URLOpenerProtocol {
    @MainActor
    func open(url: URL, with browser: Browser) {
        self.open(url: url, with: browser, withTermination: true)
    }
}

public final class URLOpener: URLOpenerProtocol {
    public init() {} 

    @MainActor
    public func open(url: URL, with browser: Browser, withTermination: Bool = true) {
        guard let appURL = browser.appURL else { return }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.arguments = browser.arguments ?? []

        Log.shared.log("\(configuration.arguments)", level: .debug)

        NSWorkspace.shared.open(
            [url],
            withApplicationAt: appURL,
            configuration: configuration,
            completionHandler: nil
        )

        if withTermination {
            NSApplication.shared.terminate(nil)
        }
    }
}

public final class MockURLOpener: URLOpenerProtocol {
    public init() {} 

    @MainActor
    public func open(url: URL, with browser: Browser, withTermination: Bool = true) {
        Log.shared.log("MockURLOpener open called for url \(url)", level: .debug)
    }
}

