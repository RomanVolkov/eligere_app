import Foundation

enum ConfigPath {
    static let defaultConfigPath = Bundle.main.url(forResource: "default", withExtension: "toml")!
    static let configFileName: String = ".eligere.toml"
    static let configFolderPath: String = ".config/eligere/"

    static var defaultPath: URL {
        let home = URL(fileURLWithPath: NSHomeDirectory())
        let fileURL = home
            .appendingPathComponent(configFolderPath)
            .appendingPathComponent(ConfigPath.configFileName)
        return fileURL
    }

    static func isExist() -> Bool {
        return FileManager.default.fileExists(atPath: defaultPath.path)
    }
}
