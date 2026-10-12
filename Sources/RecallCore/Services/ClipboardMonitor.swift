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
        // Run initial check to capture the current clipboard content on startup
        checkForChanges()
        
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
        // 1. Try reading Image first (screenshots, copied graphics)
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
        guard let types = pasteboard.types else { return nil }
        
        // Only treat as image if the pasteboard explicitly contains PNG or TIFF image types.
        // This avoids accidentally loading Finder file copies into memory.
        if types.contains(.png), let pngData = pasteboard.data(forType: .png), !pngData.isEmpty {
            return pngData
        }
        
        if types.contains(.tiff), let tiffData = pasteboard.data(forType: .tiff), !tiffData.isEmpty {
            // Compress raw TIFF into lightweight PNG to save 80-90% RAM
            if let rep = NSBitmapImageRep(data: tiffData),
               let pngData = rep.representation(using: .png, properties: [:]) {
                return pngData
            }
            return tiffData
        }
        
        return nil
    }
    
    /// Copies an item back to the system clipboard and bumps it to the top of history
    public func copyToClipboard(item: ClipItem) {
        isInternalWrite = true
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                if let tiff = image.tiffRepresentation {
                    pasteboard.setData(tiff, forType: .tiff)
                }
            }
            pasteboard.setData(data, forType: .png)
        }
        
        lastChangeCount = pasteboard.changeCount
        
        // Promote this clip to top of list as the most recently copied item
        ClipStore.shared.promoteToTop(id: item.id)
    }
}
