import Foundation

@available(macOS 15.0, *)
public final class ConfigSaver {

    public static func save(_ config: Config) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(config)
            try data.write(to: ConfigPath.defaultPath)
        } catch {
            Log.shared.log("error saving config \(error)", level: .error)
        }
    }
}
