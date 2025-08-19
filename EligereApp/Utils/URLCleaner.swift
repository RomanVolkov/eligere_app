import Foundation

public final class URLCleaner {
    private init () {}

    private static let trackingParameterPrefixes = ["utmn_", "utm_", "gclid", "fbclid", "attribution_id"]

    // returns original URL in case of errors
    public static func removeTrackingAttributes(url inputURL: URL) -> URL {
        let url = inputURL

        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        let filteredQueryItems = urlComponents.queryItems?.filter { queryItem in
            return !trackingParameterPrefixes.contains { prefix in
                queryItem.name.hasPrefix(prefix)
            }
        }

        urlComponents.queryItems = filteredQueryItems

        return urlComponents.url ?? inputURL
    }

    public static func resolveURL(_ url: URL) async throws -> URL {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        let session = URLSession(configuration: config)

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 3

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              let finalURL = httpResponse.url else {
            throw URLError(.badServerResponse)
        }

        return finalURL
    }
}
