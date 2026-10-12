import XCTest
import AppKit
@testable import RecallCore

final class RecallTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ClipStore.shared.clearAll()
    }
    
    // MARK: - ClipStore Tests
    
    func testAddTextClip() {
        let store = ClipStore.shared
        store.add(content: .text("Hello Recall!"))
        
        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.recentItems.count, 1)
        XCTAssertEqual(store.pinnedItems.count, 0)
        
        if case let .text(val) = store.items.first?.content {
            XCTAssertEqual(val, "Hello Recall!")
        } else {
            XCTFail("Expected text content")
        }
    }
    
    func testConsecutiveDeduplication() {
        let store = ClipStore.shared
        store.add(content: .text("Duplicate Me"))
        store.add(content: .text("Duplicate Me"))
        
        XCTAssertEqual(store.items.count, 1, "Consecutive identical items should not be duplicated")
    }
    
    func testReAddMovesToTop() {
        let store = ClipStore.shared
        store.add(content: .text("First"))
        store.add(content: .text("Second"))
        
        XCTAssertEqual(store.items.count, 2)
        XCTAssertEqual(store.items[0].displayTitle, "Second")
        
        // Re-copy "First"
        store.add(content: .text("First"))
        XCTAssertEqual(store.items.count, 2)
        XCTAssertEqual(store.items[0].displayTitle, "First")
        XCTAssertEqual(store.items[1].displayTitle, "Second")
    }
    
    func testPinAndUnpin() {
        let store = ClipStore.shared
        store.add(content: .text("Important Note"))
        guard let item = store.items.first else {
            XCTFail("Item not found")
            return
        }
        
        XCTAssertFalse(item.isPinned)
        XCTAssertEqual(store.pinnedItems.count, 0)
        
        store.togglePin(id: item.id)
        XCTAssertTrue(item.isPinned)
        XCTAssertEqual(store.pinnedItems.count, 1)
        XCTAssertEqual(store.recentItems.count, 0)
        
        store.togglePin(id: item.id)
        XCTAssertFalse(item.isPinned)
        XCTAssertEqual(store.pinnedItems.count, 0)
        XCTAssertEqual(store.recentItems.count, 1)
    }
    
    func testCapacityPruningPreservesPinned() {
        let store = ClipStore.shared
        store.maxCapacity = 3
        
        store.add(content: .text("Clip 1"))
        store.togglePin(id: store.items[0].id) // Pin Clip 1
        
        store.add(content: .text("Clip 2"))
        store.add(content: .text("Clip 3"))
        store.add(content: .text("Clip 4"))
        store.add(content: .text("Clip 5")) // Should prune oldest unpinned ("Clip 2")
        
        // Total items: 1 pinned + 3 unpinned = 4 items
        XCTAssertEqual(store.items.count, 4)
        XCTAssertEqual(store.pinnedItems.count, 1)
        XCTAssertEqual(store.pinnedItems.first?.displayTitle, "Clip 1")
        XCTAssertEqual(store.recentItems.count, 3)
    }
    
    func testClearUnpinned() {
        let store = ClipStore.shared
        store.add(content: .text("Keep Me"))
        store.togglePin(id: store.items[0].id)
        
        store.add(content: .text("Delete Me 1"))
        store.add(content: .text("Delete Me 2"))
        
        XCTAssertEqual(store.items.count, 3)
        store.clearUnpinned()
        
        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.pinnedItems.count, 1)
        XCTAssertEqual(store.pinnedItems.first?.displayTitle, "Keep Me")
    }
    
    // MARK: - Image Handling & Utils Tests
    
    func testImageThumbnailGeneration() {
        // Create a 200x100 dummy bitmap image
        let size = NSSize(width: 200, height: 100)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.systemRed.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        
        let thumbnail = ImageUtils.createThumbnail(from: image, targetSize: NSSize(width: 36, height: 36))
        XCTAssertEqual(thumbnail.size.width, 36)
        XCTAssertEqual(thumbnail.size.height, 36)
    }
    
    func testImageClipItemFormatting() {
        let size = CGSize(width: 1920, height: 1080)
        let dummyData = "dummy_png_bytes".data(using: .utf8)!
        let dummyImage = NSImage(size: NSSize(width: 36, height: 36))
        
        let clipItem = ClipItem(content: .image(data: dummyData, dimensions: size, thumbnail: dummyImage))
        XCTAssertTrue(clipItem.displayTitle.contains("📷 1920×1080"))
    }
    
    // MARK: - Clipboard Monitor Writing
    
    func testClipboardCopyText() {
        let monitor = ClipboardMonitor.shared
        let item = ClipItem(content: .text("Recall Pasteboard Test"))
        monitor.copyToClipboard(item: item)
        
        let pasteboardString = NSPasteboard.general.string(forType: .string)
        XCTAssertEqual(pasteboardString, "Recall Pasteboard Test")
    }
    
    // MARK: - PreferencesManager Tests
    
    func testPreferencesLimits() {
        let prefs = PreferencesManager.shared
        prefs.rememberLimit = 150
        XCTAssertEqual(prefs.rememberLimit, 150)
        XCTAssertEqual(ClipStore.shared.maxCapacity, 150)
        
        prefs.displayLimit = 25
        XCTAssertEqual(prefs.displayLimit, 25)
    }
}
