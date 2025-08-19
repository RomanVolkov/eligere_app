import Foundation
import SwiftUI

public final class AppState: ObservableObject {
    public let config: Config
    public let browsers: BrowsersModel

    @Published public var openingLink = false
    @Published public var url: URL?

    public init(config: Config, browsers: BrowsersModel) {
        self.config = config
        self.browsers = browsers

        browsers.browsers = config.browsers
    }
}
