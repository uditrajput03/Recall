import Foundation

public final class ClipStore {
    public static let shared = ClipStore()
    
    public private(set) var items: [ClipItem] = []
    public var maxCapacity: Int = 50 {
        didSet {
            pruneExceedingCapacity()
            onItemsChanged?()
        }
    }
    
    public var onItemsChanged: (() -> Void)?
    
    public init() {}
    
    public var pinnedItems: [ClipItem] {
        return items.filter { $0.isPinned }
    }
    
    public var recentItems: [ClipItem] {
        return items.filter { !$0.isPinned }
    }
    
    public func add(content: ClipContent) {
        // Create candidate item
        let candidate = ClipItem(content: content)
        
        // 1. Check if the most recent item is identical
        if let first = items.first, first.contentHash == candidate.contentHash {
            return
        }
        
        // 2. If it already exists in the list, remove the existing duplicate so it gets bumped to top
        if let existingIndex = items.firstIndex(where: { $0.contentHash == candidate.contentHash }) {
            let wasPinned = items[existingIndex].isPinned
            items.remove(at: existingIndex)
            candidate.isPinned = wasPinned
        }
        
        // 3. Insert at top
        items.insert(candidate, at: 0)
        
        // 4. Prune unpinned items exceeding capacity
        pruneExceedingCapacity()
        
        onItemsChanged?()
    }
    
    /// Bumps an existing item to the top of its section when selected
    public func promoteToTop(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let item = items.remove(at: index)
        items.insert(item, at: 0)
        onItemsChanged?()
    }
    
    public func togglePin(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isPinned.toggle()
        onItemsChanged?()
    }
    
    public func removeItem(id: UUID) {
        items.removeAll(where: { $0.id == id })
        onItemsChanged?()
    }
    
    public func clearUnpinned() {
        items.removeAll(where: { !$0.isPinned })
        onItemsChanged?()
    }
    
    public func clearAll() {
        items.removeAll()
        onItemsChanged?()
    }
    
    private func pruneExceedingCapacity() {
        var unpinnedCount = 0
        var indicesToRemove: [Int] = []
        
        for (index, item) in items.enumerated() {
            if !item.isPinned {
                unpinnedCount += 1
                if unpinnedCount > maxCapacity {
                    indicesToRemove.append(index)
                }
            }
        }
        
        for index in indicesToRemove.reversed() {
            items.remove(at: index)
        }
    }
}
