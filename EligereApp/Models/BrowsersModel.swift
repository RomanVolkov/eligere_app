import AppKit
import Foundation

public final class BrowsersModel: ObservableObject, Observable {
    @Published public var browsers: [Browser] = []

    public var config: Config!

    public var availableBrowsers: [Browser] {
        var values = browsers

        if self.config.useOnlyRunningBrowsers ?? false {
            values = browsers.filter { browser -> Bool in
                return NSWorkspace.shared.runningApplications.contains { app -> Bool in
                    return app.localizedName == browser.name
                }
            }
        }

        var tmp = [Browser]()
        for b in values {
            if b.isValid() {
                tmp.append(b)
            } else {
                Log.shared.log(
                    "Invalid browser configuration: \(b.name). Ignoring", level: .warning)
            }
        }
        values = tmp

        return values
    }

    public init(values: [Browser], config: Config?) {
        self.browsers = values
        self.config = config
    }
}
