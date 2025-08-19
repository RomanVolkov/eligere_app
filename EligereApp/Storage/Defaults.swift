import Foundation
import Security

public final class Storage {
    private let defaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.dev.eligere.group")!

    private init() {}

    nonisolated(unsafe) public static let shared = Storage()

    public var lastPinnedTime: Date? {
        get {
            return defaults.value(forKey: "lastPinnedTime") as? Date
        }
        set {
            defaults.set(newValue, forKey: "lastPinnedTime")
        }
    }

    public var pinnedBrowser: String? {
        get {
            return defaults.string(forKey: "pinnedBrowser")
        }
        set {
            defaults.set(newValue, forKey: "pinnedBrowser")
        }
    }

    public var previousFocusedApp: FocusAppInfo? {
        guard let data = sharedDefaults.data(forKey: "previous-app") else {
            return nil
        }
        do {
            let info = try JSONDecoder().decode(FocusAppInfo.self, from: data)
            return info
        } catch {
            Log.shared.log("Failed to decode FocusAppInfo: \(error)", level: .error)
        }
        return nil
    }
}
