import Foundation

public struct BrowserSuggestion: Sendable {
    public let name: String
    public let shortcut: String
    public let isInstalled: Bool
}

public final class BrowserDetector: Sendable {
    
    private static let knownBrowsers: [(name: String, shortcut: String)] = BrowserName.allCases.map { ($0.displayName, BrowserName.defaultShortcuts[$0] ?? "") }
    
    public static func detectInstalledBrowsers() -> [BrowserSuggestion] {
        let appsDir = try? FileManager.default.url(
            for: .applicationDirectory,
            in: .localDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        guard let appsDir = appsDir else { return [] }
        
        let installedApps = (try? FileManager.default.contentsOfDirectory(
            at: appsDir,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )) ?? []
        
        let installedNames = Set(installedApps.map { $0.deletingPathExtension().lastPathComponent })
        
        var suggestions: [BrowserSuggestion] = []
        for (name, shortcut) in knownBrowsers {
            let isInstalled = installedNames.contains(name)
            if isInstalled {
                suggestions.append(BrowserSuggestion(name: name, shortcut: shortcut, isInstalled: true))
            }
        }
        
        return suggestions
    }
    
    private static func loadDefaultConfigHeader() -> String? {
        guard let url = Bundle.main.url(forResource: "default", withExtension: "toml"),
              let content = try? String(contentsOf: url, encoding: .utf8)
        else {
            return nil
        }
        
        let header = content
            .components(separatedBy: "\n[[browsers]]")
            .first?
            .trimmingCharacters(in: .newlines)
        
        return header
    }
    
    public static func generateTOML(suggestions: [BrowserSuggestion]) -> String {
        var lines: [String] = []
        
        if let header = loadDefaultConfigHeader() {
            lines.append(header)
        } else {
            lines.append("useOnlyRunningBrowsers = false")
            lines.append("stripTrackingAttributes = true")
            lines.append("expandShortenURLs = true")
            lines.append("pinningSeconds = 30")
            lines.append("logLevel = \"warning\"")
        }
        
        lines.append("")
        
        for (index, suggestion) in suggestions.enumerated() {
            lines.append("[[browsers]]")
            lines.append("# Name of a browser from \"/Applications\" folder. Required property.")
            lines.append("name = \"\(suggestion.name)\"")
            lines.append("# Keyboard shortcut to open this browser.")
            lines.append("shortcut = \"\(suggestion.shortcut)\"")
            
            if index == 0 {
                lines.append("default = true")
            }
            
            lines.append("")
        }
        
        return lines.joined(separator: "\n")
    }
}
