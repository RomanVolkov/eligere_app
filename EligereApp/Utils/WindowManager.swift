import SwiftUI

class WindowManager: ObservableObject {
    static let shared = WindowManager()

    func centerWindow() {
        DispatchQueue.main.async {
            for window in NSApplication.shared.windows {
                window.center()
                window.makeKeyAndOrderFront(nil)
                window.disableSnapshotRestoration()
            }
        }
    }
}
