import SwiftUI
import AppKit

public struct PreferencesView: View {
    @State private var rememberCount: Int
    @State private var displayCount: Int
    @State private var launchAtLogin: Bool
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    public init() {
        _rememberCount = State(initialValue: PreferencesManager.shared.rememberLimit)
        _displayCount = State(initialValue: PreferencesManager.shared.displayLimit)
        _launchAtLogin = State(initialValue: PreferencesManager.shared.launchAtLogin)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with App Title and Version Badge
            HStack(alignment: .center) {
                Text("General Settings")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("v\(appVersion)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(4)
            }
            .padding(.bottom, 2)
            
            VStack(spacing: 12) {
                // Remember row
                HStack(spacing: 10) {
                    Text("Remember:")
                        .frame(width: 85, alignment: .trailing)
                        .font(.system(size: 13, weight: .regular))
                    
                    TextField("", value: $rememberCount, formatter: NumberFormatter())
                        .frame(width: 55)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .onChange(of: rememberCount) { newValue in
                            let clamped = max(5, min(newValue, 1000))
                            PreferencesManager.shared.rememberLimit = clamped
                        }
                    
                    Stepper("", value: $rememberCount, in: 5...500, step: 5)
                        .labelsHidden()
                        .onChange(of: rememberCount) { newValue in
                            let clamped = max(5, min(newValue, 1000))
                            PreferencesManager.shared.rememberLimit = clamped
                        }
                    
                    Text("clippings")
                        .font(.system(size: 13))
                    
                    Spacer()
                }
                
                // Display row
                HStack(spacing: 10) {
                    Text("Display:")
                        .frame(width: 85, alignment: .trailing)
                        .font(.system(size: 13, weight: .regular))
                    
                    TextField("", value: $displayCount, formatter: NumberFormatter())
                        .frame(width: 55)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .onChange(of: displayCount) { newValue in
                            let clamped = max(1, min(newValue, 100))
                            PreferencesManager.shared.displayLimit = clamped
                        }
                    
                    Stepper("", value: $displayCount, in: 1...100, step: 5)
                        .labelsHidden()
                        .onChange(of: displayCount) { newValue in
                            let clamped = max(1, min(newValue, 100))
                            PreferencesManager.shared.displayLimit = clamped
                        }
                    
                    Text("clippings")
                        .font(.system(size: 13))
                    
                    Spacer()
                }
                
                // Launch at Login row
                HStack(spacing: 10) {
                    Text("")
                        .frame(width: 85)
                    
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .font(.system(size: 13, weight: .regular))
                        .onChange(of: launchAtLogin) { newValue in
                            PreferencesManager.shared.launchAtLogin = newValue
                        }
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            
            Divider()
                .padding(.vertical, 4)
            
            HStack {
                Link(destination: URL(string: "https://github.com/uditrajput03/Recall")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.forward.app")
                        Text("GitHub Repository")
                    }
                    .font(.system(size: 12))
                }
                
                Spacer()
                
                // Hidden button to handle Escape key
                Button("") {
                    PreferencesWindowController.shared.close()
                }
                .keyboardShortcut(.cancelAction)
                .hidden()
                
                Button("Done") {
                    PreferencesWindowController.shared.close()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}

public final class PreferencesWindowController: NSWindowController {
    public static let shared = PreferencesWindowController()
    
    private init() {
        let hostingController = NSHostingController(rootView: PreferencesView())
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Preferences"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func showPreferences() {
        NSApp.activate(ignoringOtherApps: true)
        window?.contentViewController = NSHostingController(rootView: PreferencesView())
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
}
