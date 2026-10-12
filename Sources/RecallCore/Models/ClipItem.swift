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
    
    public init(content: ClipContent, isPinned: Bool = false) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.isPinned = isPinned
        
        switch content {
        case let .text(str):
            let data = Data(str.utf8)
            let digest = SHA256.hash(data: data)
            self.contentHash = "txt:" + digest.compactMap { String(format: "%02x", $0) }.joined()
        case let .image(data, _, _):
            let digest = SHA256.hash(data: data)
            self.contentHash = "img:" + digest.compactMap { String(format: "%02x", $0) }.joined()
        }
    }
    
    public static func == (lhs: ClipItem, rhs: ClipItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    public var displayTitle: String {
        switch content {
        case let .text(str):
            let sanitized = str
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let maxLength = 50
            if sanitized.count > maxLength {
                let index = sanitized.index(sanitized.startIndex, offsetBy: maxLength)
                return String(sanitized[..<index]) + "…"
            } else if sanitized.isEmpty {
                return "(Empty text)"
            }
            return sanitized
            
        case let .image(_, dimensions, _):
            let w = Int(dimensions.width)
            let h = Int(dimensions.height)
            return "📷 \(w)×\(h) • \(timeString)"
        }
    }
}
