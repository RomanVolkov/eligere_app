import Foundation
import SwiftUI

final class URLRouter {
    private let appState: AppState
    private let urlOpener: URLOpenerProtocol

    init(appState: AppState, urlOpener: URLOpenerProtocol = URLOpener()) {
        self.appState = appState
        self.urlOpener = urlOpener
    }

    /// Pure routing logic: returns a `RoutingResult` if a match is found, or `nil` if the UI picker should be shown.
    func routeURL(_ url: URL, previousApp: FocusAppInfo?) async -> RoutingResult? {
        var cleanedURL = url
        var expandedURL: URL?

        if self.appState.config.stripTrackingAttributes ?? false {
            cleanedURL = URLCleaner.removeTrackingAttributes(url: cleanedURL)
        }

        do {
            if self.appState.config.expandShortenURLs ?? false {
                expandedURL = try await URLCleaner.resolveURL(cleanedURL)
                cleanedURL = expandedURL ?? cleanedURL

                if self.appState.config.stripTrackingAttributes ?? false {
                    cleanedURL = URLCleaner.removeTrackingAttributes(url: cleanedURL)
                }
            }
        } catch {
            Log.shared.log("resolveURL error: \(error)", level: .error)
        }

        let availableBrowsers = appState.browsers.availableBrowsers

        if availableBrowsers.count == 1 && appState.config.useOnlyRunningBrowsers ?? false {
            return RoutingResult(
                browser: availableBrowsers[0],
                ruleType: .onlyRunning,
                cleanedURL: cleanedURL,
                expandedURL: expandedURL,
                sourceApp: nil
            )
        }

        // Search for apps rules
        if let previousApp = previousApp {
            for browser in availableBrowsers {
                for app in browser.apps ?? [] {
                    if app == previousApp.name {
                        return RoutingResult(
                            browser: browser,
                            ruleType: .sourceApp,
                            cleanedURL: cleanedURL,
                            expandedURL: expandedURL,
                            sourceApp: previousApp.name
                        )
                    }
                }
            }
        }

        // Search for domain and path matching
        var bestMatch: (browser: Browser, match: String)? = nil
        for browser in availableBrowsers {
            for domain in browser.domains ?? [] {
                if cleanedURL.absoluteString.lowercased().contains(domain.lowercased()) {
                    if bestMatch == nil || domain.count > bestMatch!.match.count {
                        bestMatch = (browser, domain.lowercased())
                    }
                }
            }
        }

        if let bestMatch = bestMatch {
            return RoutingResult(
                browser: bestMatch.browser,
                ruleType: .domain,
                cleanedURL: cleanedURL,
                expandedURL: expandedURL,
                sourceApp: nil
            )
        }

        // Default browser
        if let defaultBrowser = availableBrowsers.first(where: { $0.default ?? false }) {
            return RoutingResult(
                browser: defaultBrowser,
                ruleType: .default,
                cleanedURL: cleanedURL,
                expandedURL: expandedURL,
                sourceApp: nil
            )
        }

        // Pinned browser
        if let pinningSeconds = appState.config.pinningSeconds,
            let pinnedBrowserId = Storage.shared.pinnedBrowserId ?? Storage.shared.pinnedBrowser,
            let lastPinnedTime = Storage.shared.lastPinnedTime,
            Date().timeIntervalSince(lastPinnedTime) < TimeInterval(pinningSeconds),
            let browser = availableBrowsers.first(where: { $0.id == pinnedBrowserId || $0.name == pinnedBrowserId })
        {
            return RoutingResult(
                browser: browser,
                ruleType: .pinned,
                cleanedURL: cleanedURL,
                expandedURL: expandedURL,
                sourceApp: nil
            )
        }

        return nil
    }

    func openURL(_ url: URL, previousApp: FocusAppInfo?) async {
        if let result = await routeURL(url, previousApp: previousApp) {
            Log.shared.log(
                "Routing: \(result.ruleType.rawValue) → \(result.browser.name) for \(result.cleanedURL)",
                level: .debug
            )
            await urlOpener.open(url: result.cleanedURL, with: result.browser)
        } else {
            Log.shared.log("assign \(url) to urlData", level: .debug)
            await MainActor.run {
                self.appState.url = url
                WindowManager.shared.centerWindow()
            }
        }
    }
}
