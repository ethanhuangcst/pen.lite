import Cocoa
import Foundation

private final class ClickThroughLabel: NSTextField {
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}

class NewOrEditPrompt: BaseWindow, NSTextViewDelegate {
    
    // MARK: - Singleton
    static var sharedWindow: NewOrEditPrompt?
    
    // MARK: - Properties
    private let promptNameLabel = NSTextField()
    private let promptNameField = NSTextField()
    private let promptLabel = NSTextField()
    private let promptTextField = NSTextView()
    private let promptPlaceholderLabel = ClickThroughLabel()
    private let saveButton = FocusableButton()
    private let cancelButton = FocusableButton()
    private let deleteButton = FocusableButton()
    private let defaultPromptCheckbox = NSButton()
    
    private var prompt: Prompt?
    private var isNewPrompt: Bool
    private weak var originatingWindow: NSWindow?
    
    // Callbacks
    var onSave: ((Prompt) -> Void)?
    var onDelete: ((Prompt) -> Void)?
    
    // MARK: - Initialization
    private init(prompt: Prompt? = nil, originatingWindow: NSWindow? = nil) {
        self.prompt = prompt
        self.isNewPrompt = prompt == nil
        self.originatingWindow = originatingWindow
        
        let windowSize = NSSize(width: 600, height: 518)
        super.init(size: windowSize)
        
        let contentView = createStandardContentView(size: windowSize)
        
        setupUI(contentView: contentView, windowSize: windowSize)
        
        self.contentView = contentView
        
        recalculateKeyViewLoop()
        
        if let originatingWindow = originatingWindow {
            self.setFrameOrigin(originatingWindow.frame.origin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Static Methods
    static func showWindow(prompt: Prompt? = nil, originatingWindow: NSWindow?) -> NewOrEditPrompt {
        if let existing = sharedWindow {
            existing.prompt = prompt
            existing.isNewPrompt = prompt == nil
            existing.updateFields()
            existing.originatingWindow = originatingWindow
            originatingWindow?.orderOut(nil)
            existing.showAndFocus()
            return existing
        }
        
        let window = NewOrEditPrompt(prompt: prompt, originatingWindow: originatingWindow)
        sharedWindow = window
        originatingWindow?.orderOut(nil)
        window.showAndFocus()
        return window
    }
    
    static func closeWindow() {
        sharedWindow?.closeAndUnhideOriginatingWindow()
        sharedWindow = nil
    }
    
    private func updateFields() {
        if let prompt = prompt {
            promptNameField.stringValue = prompt.promptName
            promptTextField.string = prompt.promptText
            defaultPromptCheckbox.state = prompt.isDefault ? .on : .off
            defaultPromptCheckbox.isHidden = prompt.isDefault
            promptPlaceholderLabel.isHidden = true
        } else {
            promptNameField.stringValue = ""
            promptNameField.placeholderString = LocalizationService.shared.localizedString(for: "enter_prompt_name_placeholder")
            promptTextField.string = ""
            defaultPromptCheckbox.state = .off
            defaultPromptCheckbox.isHidden = false
            promptPlaceholderLabel.isHidden = false
        }
        
        deleteButton.isHidden = isNewPrompt
    }
    
    // MARK: - UI Setup
    private func setupUI(contentView: NSView, windowSize: NSSize) {
        addPenAILogo(to: contentView, windowHeight: windowSize.height)
        
        addStandardCloseButton(to: contentView, windowWidth: windowSize.width, windowHeight: windowSize.height)
        
        let titleLabel = NSTextField(frame: NSRect(x: 70, y: windowSize.height - 55, width: windowSize.width - 90, height: 30))
        let title = isNewPrompt ? LocalizationService.shared.localizedString(for: "new_prompt_title") : LocalizationService.shared.localizedString(for: "edit_prompt_title")
        titleLabel.stringValue = title
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(titleLabel)
        
        promptNameField.frame = NSRect(x: 40, y: windowSize.height - 102, width: windowSize.width - 80, height: 24)
        promptNameField.wantsLayer = true
        promptNameField.layer?.backgroundColor = NSColor.lightGray.withAlphaComponent(0.0).cgColor
        promptNameField.layer?.borderWidth = 1.0
        promptNameField.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.5).cgColor
        promptNameField.layer?.cornerRadius = 4.0
        contentView.addSubview(promptNameField)
        
        let promptScrollView = NSScrollView(frame: NSRect(x: 40, y: 44 + 20, width: 520, height: 338))
        promptScrollView.hasVerticalScroller = true
        promptScrollView.autohidesScrollers = false
        
        promptPlaceholderLabel.frame = NSRect(x: 8, y: 8, width: promptScrollView.frame.width - 32, height: 336 - 16)
        promptPlaceholderLabel.stringValue = LocalizationService.shared.localizedString(for: "markdown_format_recommended_tooltip")
        promptPlaceholderLabel.textColor = NSColor.lightGray
        promptPlaceholderLabel.isBezeled = false
        promptPlaceholderLabel.drawsBackground = false
        promptPlaceholderLabel.isEditable = false
        promptPlaceholderLabel.isSelectable = false
        promptPlaceholderLabel.font = NSFont.systemFont(ofSize: 14)
        promptPlaceholderLabel.autoresizingMask = [.width]
        
        promptTextField.frame = NSRect(x: 0, y: 0, width: promptScrollView.frame.width, height: 336)
        promptTextField.font = NSFont.systemFont(ofSize: 14)
        promptTextField.drawsBackground = false
        promptTextField.wantsLayer = true
        promptTextField.layer?.backgroundColor = NSColor.clear.cgColor
        promptTextField.layer?.borderWidth = 1.0
        promptTextField.layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.5).cgColor
        promptTextField.layer?.cornerRadius = 4.0
        promptTextField.autoresizingMask = [.width]
        promptTextField.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        promptTextField.minSize = NSSize(width: 0, height: 336)
        promptTextField.isVerticallyResizable = true
        promptTextField.isHorizontallyResizable = false
        promptTextField.textContainerInset = NSSize(width: 8, height: 8)
        promptTextField.textContainer?.containerSize = NSSize(width: promptScrollView.contentSize.width - 16, height: CGFloat.greatestFiniteMagnitude)
        promptTextField.textContainer?.heightTracksTextView = false
        promptTextField.textContainer?.widthTracksTextView = true
        
        promptScrollView.documentView = promptTextField
        promptScrollView.contentView.addSubview(promptPlaceholderLabel)
        
        promptTextField.delegate = self
        contentView.addSubview(promptScrollView)
        
        let buttonY: CGFloat = 26
        let buttonWidth: CGFloat = 68
        let buttonHeight: CGFloat = 32
        let buttonSpacing: CGFloat = 20
        
        // Button order: Cancel, Delete, Save
        // Cancel button (leftmost)
        cancelButton.frame = NSRect(x: windowSize.width - buttonWidth - 20 - buttonWidth - buttonSpacing - buttonWidth - buttonSpacing, y: buttonY, width: buttonWidth, height: buttonHeight)
        cancelButton.title = LocalizationService.shared.localizedString(for: "cancel_button")
        cancelButton.bezelStyle = .rounded
        cancelButton.target = self
        cancelButton.action = #selector(cancelButtonClicked)
        contentView.addSubview(cancelButton)
        
        // Delete button (middle) - only for edit mode
        deleteButton.frame = NSRect(x: windowSize.width - buttonWidth - 20 - buttonWidth - buttonSpacing, y: buttonY, width: buttonWidth, height: buttonHeight)
        deleteButton.title = LocalizationService.shared.localizedString(for: "delete_button")
        deleteButton.bezelStyle = .rounded
        deleteButton.target = self
        deleteButton.action = #selector(deleteButtonClicked)
        deleteButton.wantsLayer = true
        deleteButton.layer?.borderWidth = 1.0
        deleteButton.layer?.borderColor = NSColor.systemRed.cgColor
        deleteButton.layer?.cornerRadius = 6.0
        deleteButton.contentTintColor = NSColor.systemRed
        deleteButton.isHidden = isNewPrompt
        contentView.addSubview(deleteButton)
        
        // Save button (rightmost)
        saveButton.frame = NSRect(x: windowSize.width - buttonWidth - 20, y: buttonY, width: buttonWidth, height: buttonHeight)
        saveButton.title = LocalizationService.shared.localizedString(for: "save_button")
        saveButton.bezelStyle = .rounded
        saveButton.target = self
        saveButton.action = #selector(saveButtonClicked)
        saveButton.wantsLayer = true
        saveButton.layer?.borderWidth = 1.0
        saveButton.layer?.borderColor = NSColor.systemGreen.cgColor
        saveButton.layer?.cornerRadius = 6.0
        contentView.addSubview(saveButton)
        
        // Default prompt checkbox - only show for new prompts
        if isNewPrompt {
            defaultPromptCheckbox.frame = NSRect(x: 40, y: 26, width: 200, height: 32)
            defaultPromptCheckbox.title = LocalizationService.shared.localizedString(for: "set_as_default_prompt")
            defaultPromptCheckbox.bezelStyle = .regularSquare
            defaultPromptCheckbox.setButtonType(.switch)
            defaultPromptCheckbox.state = .off
            contentView.addSubview(defaultPromptCheckbox)
        }
        
        if let prompt = prompt {
            promptNameField.stringValue = prompt.promptName
            promptTextField.string = prompt.promptText
            defaultPromptCheckbox.state = prompt.isDefault ? .on : .off
            defaultPromptCheckbox.isHidden = prompt.isDefault
            promptPlaceholderLabel.isHidden = true
        } else {
            promptNameField.placeholderString = LocalizationService.shared.localizedString(for: "enter_prompt_name_placeholder")
            promptTextField.string = ""
            defaultPromptCheckbox.state = .off
            defaultPromptCheckbox.isHidden = false
            promptPlaceholderLabel.isHidden = false
        }
        
        promptNameField.nextKeyView = promptTextField
        promptTextField.nextKeyView = cancelButton
        cancelButton.nextKeyView = deleteButton
        deleteButton.nextKeyView = saveButton
        saveButton.nextKeyView = promptNameField
        
        initialFirstResponder = promptNameField
    }
    
    // MARK: - Button Actions
    @objc private func saveButtonClicked() {
        let promptName = promptNameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let promptText = promptTextField.string
        
        guard !promptName.isEmpty,
              !promptText.isEmpty else {
            displayPopupMessage(LocalizationService.shared.localizedString(for: "all_fields_required"))
            return
        }
        
        let isDefault = defaultPromptCheckbox.state == .on
        
        if let existingPrompt = prompt {
            let updatedPrompt = Prompt(
                id: existingPrompt.id,
                promptName: promptName,
                promptText: promptText,
                createdDatetime: existingPrompt.createdDatetime,
                updatedDatetime: Date(),
                systemFlag: existingPrompt.systemFlag,
                isDefault: isDefault
            )
            onSave?(updatedPrompt)
        } else {
            let newPrompt = Prompt(
                id: "prompt-\(UUID().uuidString)",
                promptName: promptName,
                promptText: promptText,
                createdDatetime: Date(),
                updatedDatetime: nil,
                systemFlag: "PEN",
                isDefault: isDefault
            )
            onSave?(newPrompt)
        }
        
        closeAndUnhideOriginatingWindow()
    }
    
    @objc private func cancelButtonClicked() {
        closeAndUnhideOriginatingWindow()
    }
    
    @objc private func deleteButtonClicked() {
        guard let prompt = prompt else { return }
        onDelete?(prompt)
    }
    
    override func closeWindow() {
        closeAndUnhideOriginatingWindow()
    }
    
    private func closeAndUnhideOriginatingWindow() {
        orderOut(nil)
        originatingWindow?.makeKeyAndOrderFront(nil)
        NewOrEditPrompt.sharedWindow = nil
    }
    
    // MARK: - NSTextDelegate Methods
    
    func textDidChange(_ notification: Notification) {
        promptPlaceholderLabel.isHidden = !promptTextField.string.isEmpty
    }
    
    func textDidBeginEditing(_ notification: Notification) {
        if promptTextField.string.isEmpty {
            promptPlaceholderLabel.isHidden = true
        }
    }
    
    func textDidEndEditing(_ notification: Notification) {
        if promptTextField.string.isEmpty {
            promptPlaceholderLabel.isHidden = false
        }
    }
}
