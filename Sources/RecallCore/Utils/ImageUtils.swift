import AppKit

public enum ImageUtils {
    /// Creates a crisp square thumbnail with rounded corners for display in NSMenuItem.
    public static func createThumbnail(from image: NSImage, targetSize: NSSize = NSSize(width: 36, height: 36)) -> NSImage {
        let resultImage = NSImage(size: targetSize)
        resultImage.lockFocus()
        
        let rect = NSRect(origin: .zero, size: targetSize)
        let clipPath = NSBezierPath(roundedRect: rect, xRadius: 5, yRadius: 5)
        clipPath.addClip()
        
        // Background fill to make transparent images (like PNG icons/diagrams) visible in dark & light menu bar
        NSColor.controlBackgroundColor.withAlphaComponent(0.2).setFill()
        clipPath.fill()
        
        // Calculate aspect-fill or aspect-fit rectangle
        let imageSize = image.size
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
        
        image.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        
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
