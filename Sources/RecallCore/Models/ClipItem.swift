import AppKit
import Foundation
import CryptoKit

public enum ClipContent: Equatable {
    case text(String)
    case image(data: Data, dimensions: CGSize, thumbnail: NSImage)
    
    public static func == (lhs: ClipContent, rhs: ClipContent) -> Bool {
        switch (lhs, rhs) {
        case let (.text(a), .text(b)):
            return a == b
        case let (.image(dataA, _, _), .image(dataB, _, _)):
            return dataA == dataB
        default:
            return false
        }
    }
}

public final class ClipItem: Identifiable, Equatable {
    public let id: UUID
    public let content: ClipContent
    public let createdAt: Date
    public var isPinned: Bool
    
    // Hash for fast deduplication check
    public let contentHash: String
    
    // Precomputed display title to avoid heavy re-computation during menu render
    public let displayTitle: String
    
    public init(content: ClipContent, isPinned: Bool = false) {
        self.id = UUID()
        self.content = content
        let now = Date()
        self.createdAt = now
        self.isPinned = isPinned
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeStr = formatter.string(from: now)
        
        switch content {
        case let .text(str):
            let data = Data(str.utf8)
            let digest = SHA256.hash(data: data)
            self.contentHash = "txt:" + digest.compactMap { String(format: "%02x", $0) }.joined()
            
            // Only inspect the first 200 characters to prevent freezing on large text clips
            let previewSlice = String(str.prefix(200))
            let sanitized = previewSlice
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let maxLength = 50
            if sanitized.count > maxLength {
                let index = sanitized.index(sanitized.startIndex, offsetBy: maxLength)
                self.displayTitle = String(sanitized[..<index]) + "…"
            } else if sanitized.isEmpty {
                self.displayTitle = "(Empty text)"
            } else {
                self.displayTitle = sanitized
            }
            
        case let .image(data, dimensions, _):
            let digest = SHA256.hash(data: data)
            self.contentHash = "img:" + digest.compactMap { String(format: "%02x", $0) }.joined()
            
            let w = Int(dimensions.width)
            let h = Int(dimensions.height)
            self.displayTitle = "📷 \(w)×\(h) • \(timeStr)"
        }
    }
    
    public static func == (lhs: ClipItem, rhs: ClipItem) -> Bool {
        return lhs.id == rhs.id
    }
}
