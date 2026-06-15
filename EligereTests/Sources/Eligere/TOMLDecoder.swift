import Foundation
import TOMLKit

public final class TOMLParser {

    public static func decode(at path: URL) throws -> Config {
        let data = try Data(contentsOf: path)
        let stringValue = String(data: data, encoding: .utf8) ?? ""
        return try decode(stringValue: stringValue)
    }

    public static func decode(stringValue: String) throws -> Config {
        let table = try TOMLTable(string: stringValue)
        let config = try TOMLDecoder().decode(Config.self, from: table)
        return config
    }
}
