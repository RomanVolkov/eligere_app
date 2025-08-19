import Foundation
import SwiftUI

final class URLRouter {
    private let appState: AppState
    private let urlOpener: URLOpenerProtocol

    init(appState: AppState, urlOpener: URLOpenerProtocol = URLOpener()) {
        self.appState = appState
        self.urlOpener = urlOpener
    }

    func openURL(_ url: URL, previousApp: FocusAppInfo?) async {
        var url = url

        Log.shared.log(
            "stripTrackingAttributes: \(self.appState.config.stripTrackingAttributes ?? false)",
            level: .debug)
        if self.appState.config.stripTrackingAttributes ?? false {
            Log.shared.log(
                "removeTrackingAttributes from \(url)", level: .debug)
            url = URLCleaner.removeTrackingAttributes(url: url)
            Log.shared.log(
                "removeTrackingAttributes - result \(url)", level: .debug)
        }
        do {
            Log.shared.log(
                "expandShortenURLs: \(self.appState.config.expandShortenURLs ?? false)",
                level: .debug)
            if self.appState.config.expandShortenURLs ?? false {
                Log.shared.log("resolveURL: \(url)", level: .debug)
                url = try await URLCleaner.resolveURL(url)
                Log.shared.log("resolveURL - result: \(url)", level: .debug)

                Log.shared.log(
                    "stripTrackingAttributes: \(self.appState.config.stripTrackingAttributes ?? false)",
                    level: .debug)
                if self.appState.config.stripTrackingAttributes ?? false {
                    Log.shared.log(
                        "removeTrackingAttributes from \(url)",
                        level: .debug)
                    url = URLCleaner.removeTrackingAttributes(url: url)
                    Log.shared.log(
                        "removeTrackingAttributes - result \(url)",
                        level: .debug)
                }
            }
        } catch {
            Log.shared.log("error \(error)", level: .error)
        }

        Log.shared.log(
            "check for number of available browsers: \(appState.browsers.availableBrowsers.count)",
            level: .debug)
        if appState.browsers.availableBrowsers.count == 1
            && appState.config.useOnlyRunningBrowsers ?? false
        {
            let browser = appState.browsers.availableBrowsers[0]
            Log.shared.log(
                "opening \(url) with \(browser.name) as it's only 1 available running browser",
                level: .debug)
            await urlOpener.open(url: url, with: browser)
            return
        }

        // Search for apps rules
        if let previousApp = previousApp {
            Log.shared.log("app rules", level: .debug)
            Log.shared.log("source app name: \(previousApp.name)", level: .debug)
            Log.shared.log(
                "available browsers: \(appState.browsers.availableBrowsers.map { $0.name })",
                level: .debug)
            for browser in appState.browsers.availableBrowsers {
                for app in browser.apps ?? [] {
                    Log.shared.log("browser app: \(app)", level: .debug)
                    if app == previousApp.name {
                        Log.shared.log(
                            "force-opening \(url.absoluteString) with \(browser.name)",
                            level: .debug)
                        await urlOpener.open(url: url, with: browser)
                        return
                    }
                }
            }
        }

        // Search for domain and path matching
        Log.shared.log("domain and path rules", level: .debug)
        Log.shared.log("available browsers: \(appState.browsers.availableBrowsers.map { $0.name })", level: .debug)

        var bestMatch: (browser: Browser, match: String)? = nil

        for browser in appState.browsers.availableBrowsers {
            // Check for domain and path matches
            for domain in browser.domains ?? [] {
                Log.shared.log("checking \(url.absoluteString.lowercased()) for \(browser.name) domain/path \(domain.lowercased())", level: .debug)

                if url.absoluteString.lowercased().contains(domain.lowercased()) {
                    if bestMatch == nil || domain.count > bestMatch!.match.count {
                        bestMatch = (browser, domain.lowercased())
                    }
                }
            }
        }

        if let bestMatch = bestMatch {
            Log.shared.log("force-opening \(url.absoluteString) with \(bestMatch.browser.name) for match \(bestMatch.match)", level: .debug)
            await urlOpener.open(url: url, with: bestMatch.browser)
            return
        }

        // Trying to find the default browsers to use
        Log.shared.log("searching for default one", level: .debug)
        for browser in appState.browsers.availableBrowsers {
            if browser.default ?? false {
                Log.shared.log("using \(browser.name) as default one for \(url)", level: .debug)
                await urlOpener.open(url: url, with: browser)
                return
            }
        }

        // Using pinned browser if exists
        Log.shared.log(
            "pinningSeconds: \(appState.config.pinningSeconds?.description ?? "<no value>"); pinnedBrowser: \(Storage.shared.pinnedBrowser ?? "<no value>"); lastPinnedTime: \(Storage.shared.lastPinnedTime?.description ?? "<no value>")",
            level: .debug)
        if let pinningSeconds = appState.config.pinningSeconds,
            let pinnedBrowser = Storage.shared.pinnedBrowser,
            let lastPinnedTime = Storage.shared.lastPinnedTime
        {
            if Date().timeIntervalSince(lastPinnedTime)
                < TimeInterval(pinningSeconds)
            {
                Log.shared.log(
                    "trying to open pinned browser \(pinnedBrowser)",
                    level: .debug)
                if let browser = appState.browsers.availableBrowsers.first(where: {
                    $0.name == pinnedBrowser
                }) {
                    await urlOpener.open(url: url, with: browser)
                    return
                }
            }
        }

        Log.shared.log("assign \(url) to urlData", level: .debug)
        await MainActor.run {
            self.appState.url = url
            WindowManager.shared.centerWindow()
        }
    }
}
