import Foundation
import AppKit

@available(macOS 10.15, *)
public actor MacFileOpener {
    private let applicationName: String
    private let bundleIdentifier: String

    /// Initialize the file opener with an application name and its bundle identifier
    /// - Parameters:
    ///   - applicationName: The name of the application (e.g., "TextEdit")
    ///   - bundleIdentifier: The bundle identifier of the application (e.g., "com.apple.TextEdit")
    public init(applicationName: String, bundleIdentifier: String) {
        self.applicationName = applicationName
        self.bundleIdentifier = bundleIdentifier
    }

    /// Find the URL for the application
    /// - Returns: URL of the application
    /// - Throws: Error if application cannot be found
    private func findApplicationURL() throws -> URL {
        guard let applicationURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            throw FileOpenError.applicationNotFound(bundleIdentifier: bundleIdentifier)
        }
        return applicationURL
    }

    /// Open a file using the specific application
    /// - Parameters:
    ///   - filePath: The full path to the file to be opened
    ///   - openWithApp: Whether to use the specific application or default system handler
    public func openWithWorkspace(filePath: String, openWithApp: Bool = false) throws {
        // Verify file exists
        guard FileManager.default.fileExists(atPath: filePath) else {
            throw FileOpenError.fileNotFound(path: filePath)
        }

        let fileURL = URL(fileURLWithPath: filePath)

        if openWithApp {
            // Find and use the specific application URL
            let appURL = try findApplicationURL()

            do {
                try NSWorkspace.shared.open([fileURL], withApplicationAt: appURL, configuration: [:])
            } catch {
                throw FileOpenError.workspaceOpenFailed(description: error.localizedDescription)
            }
        } else {
            NSWorkspace.shared.open(fileURL)
        }
    }

    /// Enum to handle specific file opening errors with Sendable compliance
    enum FileOpenError: Error, Sendable {
        case fileNotFound(path: String)
        case applicationNotFound(bundleIdentifier: String)
        case workspaceOpenFailed(description: String)

        var localizedDescription: String {
            switch self {
            case .fileNotFound(let path):
                return "File not found at path: \(path)"
            case .applicationNotFound(let bundleIdentifier):
                return "Application not found with bundle identifier: \(bundleIdentifier)"
            case .workspaceOpenFailed(let description):
                return "Failed to open file: \(description)"
            }
        }
    }
}
