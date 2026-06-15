import Foundation

public final class Config: ObservableObject, Observable, Codable {

    public let browsers: [Browser]
    public let useOnlyRunningBrowsers: Bool?
    public let stripTrackingAttributes: Bool?
    public let expandShortenURLs: Bool?
    public let pinningSeconds: Int?
    public let logLevel: String?

    public init(
        browsers: [Browser],
        useOnlyRunningBrowsers: Bool,
        stripTrackingAttributes: Bool,
        expandShortenURLs: Bool,
        pinningSeconds: Int? = nil,
        logLevel: String? = nil
    ) {
        self.browsers = browsers
        self.useOnlyRunningBrowsers = useOnlyRunningBrowsers
        self.stripTrackingAttributes = stripTrackingAttributes
        self.expandShortenURLs = expandShortenURLs
        self.pinningSeconds = pinningSeconds
        self.logLevel = logLevel
    }
}
