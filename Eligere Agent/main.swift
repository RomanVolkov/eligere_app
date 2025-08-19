import Foundation
import AppKit

        let app = NSApplication.shared
        app.setActivationPolicy(.accessory) // Runs in background without dock icon

        // Start the tracking service
        _ = AppTrackingService.shared

        // Keep the app running
        app.run()
