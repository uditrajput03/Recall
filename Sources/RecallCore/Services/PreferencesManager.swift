import Foundation
import ServiceManagement

public final class PreferencesManager {
    public static let shared = PreferencesManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let rememberLimit = "rememberLimit"
        static let displayLimit = "displayLimit"
        static let launchAtLogin = "launchAtLogin"
    }
    
    public var onPreferencesChanged: (() -> Void)?
    
    public var rememberLimit: Int {
        get {
            let val = userDefaults.integer(forKey: Keys.rememberLimit)
            return val > 0 ? val : 100
        }
        set {
            let clamped = max(5, min(newValue, 1000))
            userDefaults.set(clamped, forKey: Keys.rememberLimit)
            ClipStore.shared.maxCapacity = clamped
            onPreferencesChanged?()
        }
    }
    
    public var displayLimit: Int {
        get {
            let val = userDefaults.integer(forKey: Keys.displayLimit)
            return val > 0 ? val : 30
        }
        set {
            let clamped = max(1, min(newValue, 100))
            userDefaults.set(clamped, forKey: Keys.displayLimit)
            onPreferencesChanged?()
        }
    }
    
    public var launchAtLogin: Bool {
        get {
            if #available(macOS 13.0, *) {
                let status = SMAppService.mainApp.status
                if status == .enabled {
                    return true
                } else if status == .notFound {
                    return userDefaults.bool(forKey: Keys.launchAtLogin)
                }
                return false
            } else {
                return userDefaults.bool(forKey: Keys.launchAtLogin)
            }
        }
        set {
            userDefaults.set(newValue, forKey: Keys.launchAtLogin)
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        if SMAppService.mainApp.status != .enabled {
                            try SMAppService.mainApp.register()
                        }
                    } else {
                        if SMAppService.mainApp.status == .enabled {
                            try SMAppService.mainApp.unregister()
                        }
                    }
                } catch {
                    print("Notice: SMAppService configuration: \(error.localizedDescription)")
                }
            }
            onPreferencesChanged?()
        }
    }
    
    private init() {
        // Sync initial value to ClipStore
        ClipStore.shared.maxCapacity = rememberLimit
    }
}
