import AppKit
import RecallCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuController: StatusMenuController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prevent app from showing in the Dock or Cmd+Tab switcher (menu bar only)
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize menu bar controller & start clipboard monitor
        menuController = StatusMenuController()
        ClipboardMonitor.shared.startMonitoring()
        
        print("Recall clipboard manager is running.")
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
