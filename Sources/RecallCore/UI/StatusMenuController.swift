import AppKit

public final class StatusMenuController: NSObject, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let menu = NSMenu()
    private let store = ClipStore.shared
    private let monitor = ClipboardMonitor.shared
    private let prefs = PreferencesManager.shared
    
    public override init() {
        super.init()
        setupStatusItem()
        setupMenu()
        
        store.onItemsChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.rebuildMenu()
            }
        }
        
        prefs.onPreferencesChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.rebuildMenu()
            }
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            if let baseSymbol = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "Recall Clipboard") {
                let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .light)
                let lightSymbol = baseSymbol.withSymbolConfiguration(config) ?? baseSymbol
                lightSymbol.isTemplate = true
                button.image = lightSymbol
                button.title = ""
            } else {
                button.title = "📎"
            }
            button.toolTip = "Recall - Clipboard Manager (Text & Screenshots)"
        }
        
        statusItem.menu = menu
        menu.delegate = self
    }
    
    private func setupMenu() {
        menu.autoenablesItems = false
        rebuildMenu()
    }
    
    public func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu()
    }
    
    private func rebuildMenu() {
        menu.removeAllItems()
        
        let pinned = store.pinnedItems
        let allRecents = store.recentItems
        // Limit recents according to displayLimit preference
        let recents = Array(allRecents.prefix(prefs.displayLimit))
        
        // 1. PINNED SECTION
        if !pinned.isEmpty {
            let header = NSMenuItem(title: "📌 PINNED ITEMS", action: nil, keyEquivalent: "")
            header.isEnabled = false
            menu.addItem(header)
            
            for item in pinned {
                addClipMenuItems(for: item)
            }
            
            menu.addItem(NSMenuItem.separator())
        }
        
        // 2. RECENTS SECTION
        if recents.isEmpty && pinned.isEmpty {
            let emptyItem = NSMenuItem(title: "Clipboard is empty", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        } else if !recents.isEmpty {
            if !pinned.isEmpty {
                let recentsHeader = NSMenuItem(title: "🕒 RECENT CLIPS", action: nil, keyEquivalent: "")
                recentsHeader.isEnabled = false
                menu.addItem(recentsHeader)
            }
            
            for item in recents {
                addClipMenuItems(for: item)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Helper hint
        let tipItem = NSMenuItem(title: "Tip: Hold ⌥ Option to Pin/Unpin items", action: nil, keyEquivalent: "")
        tipItem.isEnabled = false
        menu.addItem(tipItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 3. ACTIONS & CONTROLS
        if !allRecents.isEmpty {
            let clearItem = NSMenuItem(title: "Clear Unpinned History", action: #selector(handleClearHistory), keyEquivalent: "")
            clearItem.target = self
            menu.addItem(clearItem)
        }
        
        if !store.items.isEmpty {
            let clearAllItem = NSMenuItem(title: "Clear All History", action: #selector(handleClearAll), keyEquivalent: "")
            clearAllItem.target = self
            menu.addItem(clearAllItem)
        }
        
        // Preferences popup item (Cmd + ,)
        let prefItem = NSMenuItem(title: "Preferences…", action: #selector(handleOpenPreferences), keyEquivalent: ",")
        prefItem.target = self
        menu.addItem(prefItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    private func addClipMenuItems(for item: ClipItem) {
        // Primary item: Click to Copy
        let fullTitle = item.displayTitle
        let primaryItem = NSMenuItem(title: fullTitle, action: #selector(handleClipSelected(_:)), keyEquivalent: "")
        primaryItem.target = self
        primaryItem.representedObject = item
        
        switch item.content {
        case .text:
            // Text clips have no icon — clean and plain like CopyClip
            primaryItem.image = nil
        case let .image(_, _, thumbnail):
            // Image clips show the thumbnail
            primaryItem.image = thumbnail
        }
        
        menu.addItem(primaryItem)
        
        // Alternate item: Option-Click to Pin/Unpin
        let actionLabel = item.isPinned ? "Unpin: " : "📌 Pin: "
        let alternateTitle = "\(actionLabel)\(item.displayTitle)"
        let altItem = NSMenuItem(title: alternateTitle, action: #selector(handleTogglePin(_:)), keyEquivalent: "")
        altItem.target = self
        altItem.representedObject = item
        altItem.isAlternate = true
        altItem.keyEquivalentModifierMask = [.option]
        
        if let pinSymbol = NSImage(systemSymbolName: item.isPinned ? "pin.slash.fill" : "pin.fill", accessibilityDescription: nil) {
            pinSymbol.isTemplate = true
            altItem.image = pinSymbol
        }
        
        menu.addItem(altItem)
    }
    
    @objc private func handleClipSelected(_ sender: NSMenuItem) {
        guard let item = sender.representedObject as? ClipItem else { return }
        monitor.copyToClipboard(item: item)
    }
    
    @objc private func handleTogglePin(_ sender: NSMenuItem) {
        guard let item = sender.representedObject as? ClipItem else { return }
        store.togglePin(id: item.id)
    }
    
    @objc private func handleClearHistory() {
        store.clearUnpinned()
    }
    
    @objc private func handleClearAll() {
        store.clearAll()
    }
    
    @objc private func handleOpenPreferences() {
        PreferencesWindowController.shared.showPreferences()
    }
    
    @objc private func handleQuit() {
        NSApplication.shared.terminate(nil)
    }
}
