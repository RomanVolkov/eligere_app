import Foundation

public enum BrowserName: String, CaseIterable, Sendable {
    case safari = "Safari"
    case googleChrome = "Google Chrome"
    case arc = "Arc"
    case firefox = "Firefox"
    case brave = "Brave Browser"
    case edge = "Microsoft Edge"
    case opera = "Opera"
    case vivaldi = "Vivaldi"
    case orion = "Orion"
    case duckDuckGo = "DuckDuckGo"

    public var displayName: String { rawValue }

    public static var defaultShortcuts: [BrowserName: String] {
        return [
            .safari: "s",
            .googleChrome: "c",
            .arc: "a",
            .firefox: "f",
            .brave: "b",
            .edge: "e",
            .opera: "o",
            .vivaldi: "v",
            .orion: "r",
            .duckDuckGo: "d",
        ]
    }
}
