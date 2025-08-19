import AppKit
import Foundation

final class AppTrackingService: NSObject {
    static let shared = AppTrackingService()

    private let userDefaults = UserDefaults(suiteName: "group.dev.eligere.group")!
    private let workspace = NSWorkspace.shared

    private var currentApp: Info?
    private var previousApp: Info?

    override init() {
        super.init()
        setupNotifications()
        updateCurrentApp()
    }

    private func setupNotifications() {
        workspace.notificationCenter.addObserver(
            self,
            selector: #selector(appDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }

    @objc private func appDidActivate(_ notification: Notification) {
        guard
            let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication
        else {
            return
        }

        // Skip our own app to avoid tracking when we become active
        if app.bundleIdentifier == Bundle.main.bundleIdentifier {
            return
        }

        updateWithNewApp(app)
    }

    private func updateCurrentApp() {
        if let frontmostApp = workspace.frontmostApplication {
            updateWithNewApp(frontmostApp)
        }
    }

    private func updateWithNewApp(_ app: NSRunningApplication) {
        previousApp = currentApp
        currentApp = Info(from: app)

        saveToSharedStorage()
    }

    private func saveToSharedStorage() {
        if let currentApp = currentApp,
            let currentData = try? JSONEncoder().encode(currentApp)
        {
            userDefaults.set(currentData, forKey: "current-app")
        }

        if let previousApp = previousApp,
            let previousData = try? JSONEncoder().encode(previousApp)
        {
            userDefaults.set(previousData, forKey: "previous-app")
        }

        userDefaults.synchronize()
    }
}
