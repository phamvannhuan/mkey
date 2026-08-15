import AppKit

enum StatusIcon {
    private static var cache: [Key: NSImage] = [:]

    static func image(vietnamese: Bool, gray: Bool, excluded: Bool = false) -> NSImage {
        let key = Key(vietnamese: vietnamese, gray: gray, excluded: excluded)
        if let image = cache[key] {
            return image
        }

        // In an excluded app MKey is fully bypassed — render the glyph faded so
        // the menu bar visibly signals "inactive here".
        let alpha: CGFloat = excluded ? 0.35 : 1.0
        
        // Kích thước custom của mày: dài 22, cao 18
        let size = NSSize(width: 22, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let color: NSColor = (gray ? NSColor.black : NSColor(srgbRed: 0x00 / 255.0, green: 0x66 / 255.0, blue: 0xAB / 255.0, alpha: 1)).withAlphaComponent(alpha)

            let frameRect = rect.insetBy(dx: 1, dy: 1)
            // Bo góc custom: 4.5 cho mượt
            let frame = NSBezierPath(roundedRect: frameRect, xRadius: 4.5, yRadius: 4.5)
            color.setFill()
            frame.fill()

            let text = (vietnamese ? "V" : "E") as NSString
            // Font custom: SF Pro size 13, bán đậm (semibold)
            let font = NSFont.systemFont(ofSize: 13, weight: .semibold)
            let textSize = text.size(withAttributes: [.font: font])
            
            // Canh giữa chữ
            let x = frameRect.midX - textSize.width / 2
            let y = frameRect.midY - textSize.height / 2

            if gray {
                // In template mode
                NSGraphicsContext.saveGraphicsState()
                NSGraphicsContext.current?.compositingOperation = .destinationOut
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
                text.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
                NSGraphicsContext.restoreGraphicsState()
            } else {
                // In color mode
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white.withAlphaComponent(alpha)]
                text.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
            }
            return true
        }
        image.isTemplate = gray
        cache[key] = image
        return image
    }

    private struct Key: Hashable {
        let vietnamese: Bool
        let gray: Bool
        let excluded: Bool
    }
}
