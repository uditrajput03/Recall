import AppKit

public enum ImageUtils {
    public static let fixedHeight: CGFloat = 36.0
    public static let minWidth: CGFloat = 24.0
    public static let maxWidth: CGFloat = 72.0
    
    /// Creates a crisp thumbnail with fixed height (36pt) and proportional aspect-ratio width for display in NSMenuItem.
    public static func createThumbnail(from image: NSImage, targetHeight: CGFloat = fixedHeight) -> NSImage {
        let imageSize = image.size
        let targetWidth: CGFloat
        if imageSize.width > 0 && imageSize.height > 0 {
            let aspect = imageSize.width / imageSize.height
            let calculated = targetHeight * aspect
            targetWidth = max(minWidth, min(calculated, maxWidth))
        } else {
            targetWidth = targetHeight
        }
        
        let targetSize = NSSize(width: targetWidth, height: targetHeight)
        let resultImage = NSImage(size: targetSize)
        resultImage.lockFocus()
        
        let rect = NSRect(origin: .zero, size: targetSize)
        let clipPath = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        clipPath.addClip()
        
        // Background fill to make transparent images (like PNG icons/diagrams) visible in dark & light menu bar
        NSColor.controlBackgroundColor.withAlphaComponent(0.2).setFill()
        clipPath.fill()
        
        // Calculate aspect-fill rectangle
        guard imageSize.width > 0 && imageSize.height > 0 else {
            resultImage.unlockFocus()
            return resultImage
        }
        
        let scale = max(targetSize.width / imageSize.width, targetSize.height / imageSize.height)
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let drawX = (targetSize.width - scaledWidth) / 2.0
        let drawY = (targetSize.height - scaledHeight) / 2.0
        let drawRect = NSRect(x: drawX, y: drawY, width: scaledWidth, height: scaledHeight)
        let sourceRect = NSRect(origin: .zero, size: imageSize)
        
        image.draw(in: drawRect, from: sourceRect, operation: .sourceOver, fraction: 1.0)
        
        // Subtle border
        NSColor.separatorColor.setStroke()
        clipPath.lineWidth = 1.0
        clipPath.stroke()
        
        resultImage.unlockFocus()
        return resultImage
    }
    
    /// Extracts true pixel dimensions of an NSImage
    public static func pixelDimensions(for image: NSImage) -> CGSize {
        for rep in image.representations {
            if rep.pixelsWide > 0 && rep.pixelsHigh > 0 {
                return CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            }
        }
        return CGSize(width: Int(image.size.width), height: Int(image.size.height))
    }
}
