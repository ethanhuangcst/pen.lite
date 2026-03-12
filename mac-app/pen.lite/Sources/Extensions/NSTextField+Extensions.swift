import Cocoa

extension NSTextField {
    static func createLabel(
        frame: NSRect,
        value: String = "",
        font: NSFont? = nil,
        textColor: NSColor? = nil,
        alignment: NSTextAlignment = .left
    ) -> NSTextField {
        let label = NSTextField(frame: frame)
        label.stringValue = value
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        if let font = font {
            label.font = font
        }
        if let textColor = textColor {
            label.textColor = textColor
        }
        label.alignment = alignment
        return label
    }
    
    static func createLabel(
        frame: NSRect,
        value: String = "",
        font: NSFont? = nil
    ) -> NSTextField {
        return createLabel(frame: frame, value: value, font: font, textColor: nil, alignment: .left)
    }
    
    static func createBoldLabel(
        frame: NSRect,
        value: String = "",
        fontSize: CGFloat = 18
    ) -> NSTextField {
        return createLabel(
            frame: frame,
            value: value,
            font: NSFont.boldSystemFont(ofSize: fontSize),
            textColor: nil,
            alignment: .left
        )
    }
    
    static func createCenteredLabel(
        frame: NSRect,
        value: String = "",
        font: NSFont? = nil
    ) -> NSTextField {
        return createLabel(frame: frame, value: value, font: font, textColor: nil, alignment: .center)
    }
    
    static func createRightAlignedLabel(
        frame: NSRect,
        value: String = "",
        font: NSFont? = nil
    ) -> NSTextField {
        return createLabel(frame: frame, value: value, font: font, textColor: nil, alignment: .right)
    }
}
