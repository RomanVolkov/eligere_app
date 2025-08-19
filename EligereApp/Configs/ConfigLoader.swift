import Foundation

@available(macOS 15.0, *)
public final class ConfigLoader {
    public static func configExists() -> Bool {
        FileManager.default.fileExists(atPath: ConfigPath.defaultPath.path)
    }

    public static func load() -> Config? {
        do {
            let config = try TOMLParser.decode(at: ConfigPath.defaultPath)
            return config
        } catch {
            let message = "Error loading config file: \(error)"
            Log.shared.log(message, level: .critical)
            return nil
        }
    }

    public static func copyDefaultConfig() throws {
        let fileManager = FileManager.default
        let destinationURL = ConfigPath.defaultPath

        let directoryURL = destinationURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil)

        try fileManager.copyItem(at: ConfigPath.defaultConfigPath, to: destinationURL)
    }

}
