import Foundation

public final class PreferencesManager {
    public static let shared = PreferencesManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let rememberLimit = "rememberLimit"
        static let displayLimit = "displayLimit"
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
    
    private init() {
        // Sync initial value to ClipStore
        ClipStore.shared.maxCapacity = rememberLimit
    }
}
