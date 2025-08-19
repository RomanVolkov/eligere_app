import AppKit
import ServiceManagement
import SwiftUI

final class AppDelegate: NSResponder, NSApplicationDelegate {
    var appState: AppState!

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Log.shared.log("applicationDidFinishLaunching", level: .debug)
        registerBackgroundService()

        let window = NSApplication.shared.mainWindow
        window?.setFrameAutosaveName("")
        window?.disableSnapshotRestoration()

        adjustWindow(forOpenURL: false)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        Log.shared.log("open urls: \(urls)", level: .debug)

        let previousApp = Storage.shared.previousFocusedApp
        if let previousApp = previousApp {
            Log.shared.log("source app: \(previousApp.debugDescription)", level: .debug)
        } else {
            Log.shared.log("Missing previousFocusedApp info", level: .debug)
        }
        guard let url = urls.first else { return }

        adjustWindow(forOpenURL: true)

        Log.shared.log("set openingLink to true", level: .debug)
        self.appState.openingLink = true

        DispatchQueue.main.async {
            WindowManager.shared.centerWindow()
        }

        let router = URLRouter(appState: self.appState)
        Task {
            await router.openURL(url, previousApp: previousApp)
        }
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        NSApp.mainWindow?.tabbingMode = .disallowed
        return nil
    }
}

func registerBackgroundService() {
    let backgroundServiceIdentifier = "dev.eligere.agent"

    if #available(macOS 13.0, *) {
        do {
            try SMAppService.loginItem(identifier: backgroundServiceIdentifier).register()
            Log.shared.log("Background service registered successfully", level: .debug)

        } catch {
            Log.shared.log("Failed to register background service: \(error)", level: .error)
        }
    } else {
        let success = SMLoginItemSetEnabled(backgroundServiceIdentifier as CFString, true)
        print("Background service registration (legacy): \(success)")
    }
}

func adjustWindow(forOpenURL: Bool) {
    NSApplication.shared.windows.forEach { window in
        if forOpenURL {
            window.styleMask = [.docModalWindow]
            window.styleMask.remove(NSWindow.StyleMask.resizable)
        }
    }
}
