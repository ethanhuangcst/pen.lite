import Cocoa

extension NSView {
    func findTextField(inContainer containerIdentifier: ViewIdentifier, textFieldIdentifier: ViewIdentifier) -> NSTextField? {
        for subview in self.subviews {
            if let container = subview as? NSView, container.identifier?.rawValue == containerIdentifier.rawValue {
                for subview in container.subviews {
                    if let textField = subview as? NSTextField, textField.identifier?.rawValue == textFieldIdentifier.rawValue {
                        return textField
                    }
                }
            }
        }
        return nil
    }
    
    func findContainer(_ containerIdentifier: ViewIdentifier) -> NSView? {
        for subview in self.subviews {
            if let container = subview as? NSView, container.identifier?.rawValue == containerIdentifier.rawValue {
                return container
            }
        }
        return nil
    }
    
    func findPopUpButton(inContainer containerIdentifier: ViewIdentifier, buttonIdentifier: ViewIdentifier) -> NSPopUpButton? {
        for subview in self.subviews {
            if let container = subview as? NSView, container.identifier?.rawValue == containerIdentifier.rawValue {
                for subview in container.subviews {
                    if let button = subview as? NSPopUpButton, button.identifier?.rawValue == buttonIdentifier.rawValue {
                        return button
                    }
                }
            }
        }
        return nil
    }
    
    func findButton(_ buttonIdentifier: ViewIdentifier) -> NSButton? {
        for subview in self.subviews {
            if let button = subview as? NSButton, button.identifier?.rawValue == buttonIdentifier.rawValue {
                return button
            }
        }
        return nil
    }
}
