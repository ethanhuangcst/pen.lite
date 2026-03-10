import Cocoa

final class ManualInputTextView: NSTextView {
    var onSubmit: (() -> Void)?
    
    override func keyDown(with event: NSEvent) {
        let isReturnKey = event.keyCode == 36 || event.keyCode == 76
        let hasCommand = event.modifierFlags.contains(.command)
        
        if isReturnKey && hasCommand {
            onSubmit?()
            return
        }
        
        super.keyDown(with: event)
    }
}
