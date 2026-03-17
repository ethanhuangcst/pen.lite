import Cocoa

struct UILayoutConstants {
    // MARK: - Window Dimensions
    static let settingsWindowWidth: CGFloat = 600
    static let settingsWindowHeight: CGFloat = 518
    static let penWindowWidth: CGFloat = 378
    static let penWindowHeight: CGFloat = 388
    
    // MARK: - Common Spacing
    static let standardPadding: CGFloat = 20
    static let headerHeight: CGFloat = 55
    static let footerHeight: CGFloat = 30
    
    // MARK: - Close Button
    static let closeButtonSize: CGFloat = 20
    static let closeButtonOffset: CGFloat = 30
    
    // MARK: - Logo
    static let logoSize: CGFloat = 38
    static let smallLogoSize: CGFloat = 26
    static let logoXOffset: CGFloat = 20
    
    // MARK: - Corner Radius
    static let standardCornerRadius: CGFloat = 12
    static let textFieldCornerRadius: CGFloat = 4
    
    // MARK: - Fonts
    static let titleFontSize: CGFloat = 18
    static let standardFontSize: CGFloat = 12
    
    // MARK: - Settings Window Specific
    struct SettingsWindow {
        static let titleWidth: CGFloat = 200
        static let titleHeight: CGFloat = 30
        static let titleXOffset: CGFloat = 70
        
        static let languageLabelWidth: CGFloat = 100
        static let languageLabelHeight: CGFloat = 20
        static let languageLabelX: CGFloat = 380
        static let languageLabelY: CGFloat = 473
        
        static let languageDropdownWidth: CGFloat = 100
        static let languageDropdownHeight: CGFloat = 20
        static let languageDropdownX: CGFloat = 460
        static let languageDropdownY: CGFloat = 473
        
        static let tabViewXOffset: CGFloat = 20
        static let tabViewYOffset: CGFloat = 20
        static let tabViewWidthOffset: CGFloat = 80
        static let tabViewHeightOffset: CGFloat = 100
    }
    
    // MARK: - Pen Window Specific
    struct PenWindow {
        static let footerY: CGFloat = 0
        static let footerHeight: CGFloat = 30
        
        static let enhancedTextContainerX: CGFloat = 20
        static let enhancedTextContainerY: CGFloat = 120
        static let enhancedTextContainerWidth: CGFloat = 338
        static let enhancedTextContainerHeight: CGFloat = 198
        
        static let originalTextContainerX: CGFloat = 20
        static let originalTextContainerY: CGFloat = 258
        static let originalTextContainerWidth: CGFloat = 338
        static let originalTextContainerHeight: CGFloat = 88
        
        static let controllerContainerX: CGFloat = 20
        static let controllerContainerY: CGFloat = 228
        static let controllerContainerWidth: CGFloat = 338
        static let controllerContainerHeight: CGFloat = 30
        
        static let promptsDropdownWidth: CGFloat = 222
        static let promptsDropdownHeight: CGFloat = 20
        static let providerDropdownWidth: CGFloat = 110
        static let providerDropdownHeight: CGFloat = 20
        
        static let inputComposerContainerWidth: CGFloat = 338
        static let inputComposerContainerHeight: CGFloat = 88
    }
    
    // MARK: - Popup Specific
    struct Popup {
        static let minWidth: CGFloat = 240
        static let minHeight: CGFloat = 40
        static let spacing: CGFloat = 6
        static let menuBarHeight: CGFloat = 25
    }
}
