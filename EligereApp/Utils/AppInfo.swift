import Foundation


public final class AppInfo {
    private init() {}

    public static var versionString: String {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            return "Unknown Version"
        }

        let marketingVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = infoDictionary["CFBundleVersion"] as? String ?? "Unknown"

        return "\(marketingVersion) - \(buildNumber)"
    }
}
