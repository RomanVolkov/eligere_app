import Foundation
import SwiftUI

@available(macOS 15.0, *)
public struct MainAppView: View {

    @State private var opacity: Double = 0
    @State private var showDefaultButton = false

    @State private var headerHoverEffect: Bool = false
    @State private var showLicenseActivation: Bool = false

    @EnvironmentObject private var appState: AppState

    private static let viewWidth = 450.0
    private static let viewHeight = 600.0

    // Animation properties
    @State private var isAnimating = false

    public init() {
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Section with hover effect
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("Eligere")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(EligereColors.accentColor)
                        .shadow(color: EligereColors.accentColor.opacity(0.5), radius: 3, x: 0, y: 1)
                        .scaleEffect(headerHoverEffect ? 1.02 : 1.0)

                    Text(AppInfo.versionString)
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(EligereColors.subtleText)

                    Text("https://eligere.dev/")
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(EligereColors.accentColor.opacity(0.8))
                        .padding(.top, 2)
                }
                .padding(.bottom, 20)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        headerHoverEffect = hovering
                    }
                }

                // Button Group
                VStack(spacing: 15) {
                    // Config Button
                    HStack {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(ConfigPath.defaultPath.path(), forType: .string)
                        }) {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                    .foregroundColor(EligereColors.accentColor)
                                Text("Copy config path")
                                    .fontWeight(.medium)
                                    .foregroundColor(EligereColors.textColor)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(DarkHoverButtonStyle())

                        Button {
                            self.openConfig()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(EligereColors.accentColor)
                        }
                        .buttonStyle(.borderless)
                        .tooltip("edit the config with TextEdit.app")
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                    }

                    // Log Button
                    HStack {
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(Log.logPath.path(), forType: .string)
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(EligereColors.accentColor)
                                Text("Copy log path")
                                    .fontWeight(.medium)
                                    .foregroundColor(EligereColors.textColor)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(DarkHoverButtonStyle())

                        Button {
                            self.openConsoleWithLogs()
                        } label: {
                            Image(systemName: "text.justify")
                                .font(.title2)
                                .foregroundColor(EligereColors.accentColor)
                        }
                        .buttonStyle(.borderless)
                        .tooltip("open logs with Console.app")
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 30)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(EligereColors.cardBackground)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .padding()

            Spacer()

            // Default Browser Banner
            if showDefaultButton {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.25))
                                .frame(width: 36, height: 36)
                            Image(systemName: "exclamationmark.square.fill")
                                .foregroundColor(Color.orange)
                                .font(.system(size: 16, weight: .semibold))
                        }

                        Text("Eligere is not the macOS default browser")
                            .foregroundColor(EligereColors.textColor)
                            .font(.system(size: 15, weight: .medium))
                    }

                    Text("Unless Eligere is the default browser, rules will not apply")
                        .font(.system(size: 13))
                        .foregroundColor(EligereColors.subtleText)
                        .padding(.leading, 51)

                    Button(action: {
                        self.triggerSetAsDefault()
                    }) {
                        Text("Make default browser")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.orange.opacity(0.25))
                            )
                            .foregroundColor(Color.orange)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(EligereColors.cardBackground)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 450.0, height: 600, alignment: .top)
        .background(BlurEffectView(material: .menu))
        .opacity(opacity)
        .onAppear {
            self.onAppear()
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                self.isAnimating = true
            }
        }
    }

    private func onAppear() {
        showDefaultButton = !AppUtils.isCurrentAppDefaultBrowser()
        withAnimation(.easeIn(duration: 0.1)) {
            opacity = 1
        }
    }

    private func triggerSetAsDefault() {
        Task {
            Log.shared.log("Trigger setDefaultApplication", level: .debug)
            do {
                try await NSWorkspace.shared
                    .setDefaultApplication(
                        at: Bundle.main.bundleURL,
                        toOpenURLsWithScheme: "http"
                    )
            } catch {
                Log.shared.log("Error with setDefaultApplication: \(error)", level: .error)
            }

            showDefaultButton = !AppUtils.isCurrentAppDefaultBrowser()
            let isDefault = AppUtils.isCurrentAppDefaultBrowser()
            Log.shared.log("Trigger setDefaultApplication - result \(isDefault)", level: .debug)
        }
    }

    private func openConsoleWithLogs() {
        Task {
            do {
                try await MacFileOpener(
                    applicationName: "Console",
                    bundleIdentifier: "com.apple.Console"
                )
                .openWithWorkspace(
                    filePath: Log.logPath.path(),
                    openWithApp: true
                )
            } catch {
                Log.shared.log(
                    "cannot open logs: \(error)",
                    level: .debug
                )
            }
        }
    }

    private func openConfig() {
        Task {
            do {
                try await MacFileOpener(
                    applicationName: "TextEdit",
                    bundleIdentifier: "com.apple.TextEdit"
                )
                .openWithWorkspace(
                    filePath: ConfigPath.defaultPath.path(),
                    openWithApp: false
                )
            } catch {
                Log.shared.log(
                    "cannot open config to edit: \(error)",
                    level: .debug
                )
            }
        }
    }

}
