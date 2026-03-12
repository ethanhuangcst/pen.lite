import Cocoa

class ColorService {
    static let shared = ColorService()
    
    private init() {}
    
    var backgroundColor: NSColor {
        return NSColor.windowBackgroundColor
    }
    
    var surfaceColor: NSColor {
        return NSColor.underPageBackgroundColor
    }
    
    var textColor: NSColor {
        return NSColor.labelColor
    }
    
    var secondaryTextColor: NSColor {
        return NSColor.secondaryLabelColor
    }
    
    var borderColor: NSColor {
        return NSColor.separatorColor
    }
    
    var textBackgroundColor: NSColor {
        return NSColor.textBackgroundColor
    }
    
    var shadowColor: NSColor {
        return NSColor.shadowColor
    }
    
    var enhancedTextColor: NSColor {
        return NSColor(red: 104.0/255.0, green: 153.0/255.0, blue: 210.0/255.0, alpha: 1.0)
    }
    
    var standardBorderColor: NSColor {
        return NSColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    }
    
    var popupBackgroundColor: NSColor {
        return NSColor.systemBlue.withAlphaComponent(0.75)
    }
    
    var popupBackgroundColorCGColor: CGColor {
        return popupBackgroundColor.cgColor
    }
    
    var standardBorderColorCGColor: CGColor {
        return standardBorderColor.cgColor
    }
    
    var enhancedTextColorCGColor: CGColor {
        return enhancedTextColor.cgColor
    }
    
    var backgroundColorCGColor: CGColor {
        return NSColor.windowBackgroundColor.cgColor
    }
    
    var textBackgroundColorCGColor: CGColor {
        return NSColor.textBackgroundColor.cgColor
    }
    
    func getLogo() -> NSImage? {
        let isDarkMode = NSApplication.shared.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let logoName = isDarkMode ? "logo_dark" : "logo"
        
        let logoPath = ResourceService.shared.getResourcePath(relativePath: "Assets/\(logoName).png")
        return NSImage(contentsOfFile: logoPath)
    }
    
    func isDarkMode() -> Bool {
        return NSApplication.shared.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
