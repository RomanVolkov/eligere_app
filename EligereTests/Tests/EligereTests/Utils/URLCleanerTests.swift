import Testing
import Foundation
@testable import Eligere

struct URLCleanerTests {

    @Test func removeTrackingUtms() {
        let url = URL(string: "https://example.com/page?utm_source=twitter&utm_medium=social&name=value")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(!cleaned.absoluteString.contains("utm_source"))
        #expect(!cleaned.absoluteString.contains("utm_medium"))
        #expect(cleaned.absoluteString.contains("name=value"))
    }

    @Test func removeTrackingGclid() {
        let url = URL(string: "https://example.com/ad?gclid=12345")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(!cleaned.absoluteString.contains("gclid"))
    }

    @Test func removeTrackingFbclid() {
        let url = URL(string: "https://example.com/post?fbclid=abc123")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(!cleaned.absoluteString.contains("fbclid"))
    }

    @Test func removeTrackingAttributionId() {
        let url = URL(string: "https://example.com/campaign?attribution_id=xyz")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(!cleaned.absoluteString.contains("attribution_id"))
    }

    @Test func noTrackingParams() {
        let url = URL(string: "https://example.com/page?name=value&other=123")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(cleaned == url)
    }

    @Test func noQueryAtAll() {
        let url = URL(string: "https://example.com/page")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(cleaned == url)
    }

    @Test func preservesOtherParams() {
        let url = URL(string: "https://example.com/page?utm_campaign=test&ref=home&foo=bar")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(cleaned.absoluteString.contains("ref=home"))
        #expect(cleaned.absoluteString.contains("foo=bar"))
        #expect(!cleaned.absoluteString.contains("utm_campaign"))
    }

    @Test func multipleTrackingParams() {
        let url = URL(string: "https://example.com/page?utm_source=a&gclid=b&fbclid=c&attribution_id=d&keep=me")!
        let cleaned = URLCleaner.removeTrackingAttributes(url: url)
        #expect(cleaned.absoluteString.contains("keep=me"))
        #expect(!cleaned.absoluteString.contains("utm_source"))
        #expect(!cleaned.absoluteString.contains("gclid"))
        #expect(!cleaned.absoluteString.contains("fbclid"))
        #expect(!cleaned.absoluteString.contains("attribution_id"))
    }
}
