import AppKit
import Foundation

public final class ClipboardMonitor {
    public static let shared = ClipboardMonitor()
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = -1
    private var timer: Timer?
    private var isInternalWrite = false
    
    public init() {}
    
    public func startMonitoring() {
        lastChangeCount = pasteboard.changeCount
        // Poll every 0.5s for pasteboard updates
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    public func checkForChanges() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        
        if isInternalWrite {
            return
        }
        
        processCurrentPasteboard()
    }
    
    private func processCurrentPasteboard() {
        // 1. Try reading Image first (e.g. screenshots, copied graphics)
        if let imageData = readImageDataFromPasteboard() {
            if let image = NSImage(data: imageData) {
                let dims = ImageUtils.pixelDimensions(for: image)
                let thumbnail = ImageUtils.createThumbnail(from: image)
                let clipContent = ClipContent.image(data: imageData, dimensions: dims, thumbnail: thumbnail)
                ClipStore.shared.add(content: clipContent)
                return
            }
        }
        
        // 2. Try reading String
        if let string = pasteboard.string(forType: .string) {
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                ClipStore.shared.add(content: .text(string))
                return
            }
        }
    }
    
    private func readImageDataFromPasteboard() -> Data? {
        // Prioritize PNG (common for screenshots), then TIFF
        if let pngData = pasteboard.data(forType: .png), !pngData.isEmpty {
            return pngData
        }
        if let tiffData = pasteboard.data(forType: .tiff), !tiffData.isEmpty {
            return tiffData
        }
        
        // Fallback: check for NSImage class on pasteboard
        if let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage],
           let firstImage = images.first {
            if let tiff = firstImage.tiffRepresentation {
                return tiff
            }
        }
        
        return nil
    }
    
    /// Copies an item back to the system clipboard and avoids re-adding it to history
    public func copyToClipboard(item: ClipItem) {
        isInternalWrite = true
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isInternalWrite = false
            }
        }
        
        pasteboard.clearContents()
        
        switch item.content {
        case let .text(text):
            pasteboard.setString(text, forType: .string)
            
        case let .image(data, _, _):
            if let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
            pasteboard.setData(data, forType: .png)
            pasteboard.setData(data, forType: .tiff)
        }
        
        lastChangeCount = pasteboard.changeCount
    }
}
