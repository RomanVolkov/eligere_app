import SwiftUI

@available(macOS 15.0, *)
public struct URLTesterView: View {
    @EnvironmentObject private var appState: AppState
    
    @State private var inputURL: String = ""
    @State private var result: RoutingResult?
    @State private var isTesting: Bool = false
    @State private var testTask: Task<Void, Never>?
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("URL Routing Tester")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(EligereColors.textColor)
            
            TextField("https://example.com", text: $inputURL)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14, design: .monospaced))
                .onChange(of: inputURL) {
                    debounceTest()
                }
            
            if let result = result {
                VStack(alignment: .leading, spacing: 8) {
                    resultRow(icon: "arrow.right.square", label: "Browser", value: result.browser.name)
                    resultRow(icon: "doc.text", label: "Rule", value: result.ruleType.rawValue)
                    
                    if result.cleanedURL.absoluteString != inputURL {
                        resultRow(icon: "link", label: "Cleaned URL", value: result.cleanedURL.absoluteString)
                    }
                    
                    if let expandedURL = result.expandedURL {
                        resultRow(icon: "arrow.up.forward.square", label: "Expanded URL", value: expandedURL.absoluteString)
                    }
                    
                    if let sourceApp = result.sourceApp {
                        resultRow(icon: "app.badge", label: "Source App", value: sourceApp)
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(EligereColors.cardBackground.opacity(0.5))
                )
            } else if !inputURL.isEmpty && !isTesting {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("No matching rule — UI picker would be shown")
                        .font(.system(size: 13))
                        .foregroundColor(EligereColors.subtleText)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(EligereColors.cardBackground.opacity(0.5))
                )
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(EligereColors.cardBackground)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        )
    }
    
    private func resultRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(EligereColors.accentColor)
                .font(.system(size: 12))
                .frame(width: 16, height: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(EligereColors.subtleText)
                Text(value)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(EligereColors.textColor)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
    
    private func debounceTest() {
        testTask?.cancel()
        guard !inputURL.isEmpty else {
            result = nil
            return
        }
        testTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await testURL()
        }
    }
    
    private func testURL() async {
        guard let url = URL(string: inputURL), !inputURL.isEmpty else {
            await MainActor.run { result = nil }
            return
        }
        
        await MainActor.run { isTesting = true }
        result = nil
        
        let router = URLRouter(appState: appState, urlOpener: MockURLOpener())
        let previousApp = Storage.shared.previousFocusedApp
        let routingResult = await router.routeURL(url, previousApp: previousApp)
        
        await MainActor.run {
            self.result = routingResult
            self.isTesting = false
        }
    }
}
