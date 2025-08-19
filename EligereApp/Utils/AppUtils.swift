import AppKit

final class AppUtils {
    private init() {}

    public static func isCurrentAppDefaultBrowser() -> Bool {
        guard let currentAppBundleIdentifier = Bundle.main.bundleIdentifier else {
            Log.shared.log("Could not retrieve current app's bundle identifier", level: .warning)
            return false
        }

        guard
            let defaultBrowserBundleIdentifier = LSCopyDefaultHandlerForURLScheme(
                "http" as CFString)?.takeRetainedValue() as? String
        else {
            Log.shared.log("Could not retrieve default browser", level: .warning)
            return false
        }

        return currentAppBundleIdentifier == defaultBrowserBundleIdentifier
    }
}
