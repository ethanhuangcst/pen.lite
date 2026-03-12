import Cocoa

enum ViewIdentifier: String {
    case penOriginalText = "pen_original_text"
    case penOriginalTextText = "pen_original_text_text"
    case penOriginalTextInput = "pen_original_text_input"
    case penEnhancedText = "pen_enhanced_text"
    case penEnhancedTextText = "pen_enhanced_text_text"
    case penFooter = "pen_footer"
    case penFooterAutoSwitchButton = "pen_footer_auto_switch_button"
    case penController = "pen_controller"
    case penControllerProvider = "pen_controller_provider"
    case penControllerPrompts = "pen_controller_prompts"
    case penOpenSettingsButton = "pen_open_settings_button"
    
    var nsIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(self.rawValue)
    }
}
