import AppKit
import SwiftUI

@main
struct EligereApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var appState: AppState
    @State private var isPresentingPurchaseView = false

    init() {
        var loadedConfig: Config! = ConfigLoader.load()

        if loadedConfig == nil && !ConfigLoader.configExists() {
            Log.shared.log("No config -> generate default one", level: .critical)
            do {
                try ConfigLoader.copyDefaultConfig()
            }
            catch {
                Log.shared.log("Exiting: Failed to copy default config: \(error)", level: .critical)
                fatalError()
            }
            loadedConfig = ConfigLoader.load()
        } else if ConfigLoader.load() == nil {
            Log.shared.log("Exiting: Config cannot be loaded", level: .critical)
            fatalError()
        }

        let state = AppState(
            config: loadedConfig,
            browsers: BrowsersModel(values: loadedConfig.browsers, config: loadedConfig)
        )

        self.appState = state

        appDelegate.appState = self.appState

        Log.shared.config = self.appState.config
    }

    var body: some Scene {
        Window("Eligere", id: "EligereApp") {
            ContentView()
                .environmentObject(appState)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

    // New view to handle conditional rendering
    private struct ContentView: View {
        @EnvironmentObject var appState: AppState

        public init() {
        }

        var body: some View {
            Group {
                if appState.openingLink {
                    OpenLinkView()
                } else {
                    MainAppView()
                }
            }
            .onAppear {
                WindowManager.shared.centerWindow()
            }
            .onChange(of: self.appState.url) {
                WindowManager.shared.centerWindow()
            }
        }
    }
}
