import SwiftUI

@available(macOS 15.0, *)
public struct OpenLinkView: View {
    @EnvironmentObject public var appState: AppState

    @State private var isShiftPressed = false
    @State private var opacity: Double = 0

    private let urlOpener: URLOpenerProtocol = URLOpener()

    public init (isShiftPressed: Bool = false) {
        self.isShiftPressed = isShiftPressed
    }

    public var body: some View {
        BrowsersListView(isShiftPressed: $isShiftPressed)
            .environmentObject(appState)

        .background(BlurEffectView(material: .menu))
        .clipped()
        .windowResizeBehavior(.disabled)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.1)) {
                opacity = 1
            }
        }
        .onAppear {
            onAppearSetup()
        }
    }

    private func onAppearSetup() {
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            isShiftPressed = event.modifierFlags.contains(.shift)
            return event
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event -> NSEvent in
            guard let char: Character = event.characters?.first else { return event }
            guard let url: URL = self.appState.url else { return event }

            isShiftPressed = event.modifierFlags.contains(.shift)

            let list =  appState.browsers.availableBrowsers
            if let browser: Browser = list.first(where: { b -> Bool in
                return b.isKeyShortcut(char)
            }) {
                if isShiftPressed {
                    Storage.shared.lastPinnedTime = Date()
                    Storage.shared.pinnedBrowser = browser.name
                }
                urlOpener.open(url: url, with: browser)
            }

            return event
        }
    }
}

@available(macOS 15.0, *)
fileprivate struct OverlayView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack {
            ProgressView().scaleEffect(0.9)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
         }
    }
}


@available(macOS 15.0, *)
fileprivate struct BrowserView: View {

    @EnvironmentObject fileprivate var appState: AppState
    private var isShiftPressed: Bool
    private let urlOpener: URLOpenerProtocol = URLOpener()
    private let browser: Browser

    init(browser: Browser, isShiftPressed: Bool) {
        self.browser = browser
        self.isShiftPressed = isShiftPressed
    }

    var body: some View {
        VStack {
            Button {
                guard let url = self.appState.url else { return }
                urlOpener.open(url: url, with: browser)
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Image(nsImage: browser.image ?? NSImage())
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .if(isShiftPressed) { view in
                            view.background(EligereColors.accentColor)
                                .clipped()
                                .shadow(color: EligereColors.accentColor.opacity(0.5), radius: 3, x: 0, y: 1)
                                .cornerRadius(18.0)
                        }
                }
            }
            .buttonStyle(.plain)


            Text(browser.shortcut ?? "")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(EligereColors.accentColor)
                .shadow(color: EligereColors.accentColor.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .padding()
    }
}

@available(macOS 15.0, *)
fileprivate struct BrowsersListView: View {
    @EnvironmentObject fileprivate var appState: AppState
    @Binding fileprivate var isShiftPressed: Bool

    var body: some View {
        ZStack {
            HStack {
                ForEach(appState.browsers.availableBrowsers.filter { $0.hidden ?? false == false }, id: \.self) { browser in
                    BrowserView(browser: browser, isShiftPressed: isShiftPressed)
                        .environmentObject(appState)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}
