import Cocoa
import Foundation

class TmpWindow: BaseWindow {
    private let testText = """
Though many books, including The Clean Coder by Uncle Bob and The Cucumber Book, advocate for developers to write Acceptance Criteria, few Agile teams seem to follow this practice. When the topic comes up, I share my 8 reasons why developers should take on this responsibility.

Deeper Understanding: When developers write Acceptance Criteria, they gain a better understanding of the requirements. Writing, rather than just reading, leads to a more profound grasp of the details.
Breaking Down Stories: While writing Acceptance Criteria, developers and the Product Owner collaboratively break down User Stories into smaller, manageable sub-features. For example, a simple user story like “As a registered user, I want to log in to the system, so that I can access my personalized account and features security”, it might reveal over 30 Acceptance Criteria, e.g., “Remember me”, “Security Questions”, “OTP”, “Third Party Log-in”, “QR Code Log-in”, etc. When thoroughly examined, it turns a seemingly small feature into an Epic that may take several sprints to complete.
Informed Commitments: Developers should brainstorm key Acceptance Criteria with the Product Owner before committing to a User Story. This collaboration helps avoid over-commitment by prioritizing and negotiating the workload.

Early Design Thinking: Writing Acceptance Criteria initiates the design process, prompting developers to consider how they will implement the User Story.
Identifying Dependencies: In BDD, using Given/When/Then statements helps identify technical dependencies. For example, specifying a requirement like “Given the GPS location information is provided” uncovers the need for accurate GPS data to implement a feature.
Improved Estimation: Detailed Acceptance Criteria with clear boundaries make it easier for developers to estimate the effort required to complete a User Story. If the Acceptance Criteria are detailed enough, usually the easiest way to estimate the user story is by counting the number of Acceptance Criteria.
Shared Ownership: When developers write Acceptance Criteria, they share ownership of the requirements with the Product Owner. This collaboration fosters a stronger partnership, breaking down the “us vs. them” mentality.

Product Owner Efficiency: With developers handling the documentation, the Product Owner can focus on more strategic tasks, especially as the team begins using ATDD tools like Cucumber.
"""
    
    private let readOnlyTextContainer = NSView(frame: NSRect(x: 20, y: 258, width: 338, height: 88))
    private let inputComposerContainer = NSView(frame: NSRect(x: 20, y: 258, width: 338, height: 88))
    private let modeSwitch = CustomSwitch(frame: NSRect(x: 326, y: 6, width: 32, height: 18))
    
    init() {
        let windowSize = NSSize(width: 378, height: 388)
        super.init(size: windowSize)
        
        let contentView = createStandardContentView(size: windowSize)
        addManualPasteContainer(to: contentView)
        addUserLabelContainer(to: contentView)
        addReadOnlyTextContainer(to: contentView)
        addManualInputComposer(to: contentView)
        addControllerContainer(to: contentView)
        addEnhancedTextContainer(to: contentView)
        addFooterContainer(to: contentView)
        addStandardCloseButton(to: contentView, windowWidth: windowSize.width, windowHeight: windowSize.height)
        
        self.contentView = contentView
        self.customInitialFirstResponder = modeSwitch
        recalculateKeyViewLoop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addFooterContainer(to contentView: NSView) {
        let footerHeight: CGFloat = 30
        let footerContainer = NSView(frame: NSRect(x: 0, y: 0, width: 378, height: footerHeight))
        footerContainer.wantsLayer = true
        footerContainer.layer?.backgroundColor = NSColor.clear.cgColor
        footerContainer.identifier = NSUserInterfaceItemIdentifier("pen_footer")
        
        let instructionLabel = NSTextField(frame: NSRect(x: 44, y: -7, width: 180, height: footerHeight))
        let defaults = UserDefaults.standard
        let shortcutKeyDefaultsKey = "pen.shortcutKey"
        let defaultShortcut = "Command+Option+P"
        let savedShortcut = defaults.string(forKey: shortcutKeyDefaultsKey) ?? defaultShortcut
        let displayShortcut = LocalizationService.shared.formatShortcutForDisplay(savedShortcut)
        instructionLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_instruction", withFormat: displayShortcut)
        instructionLabel.isBezeled = false
        instructionLabel.drawsBackground = false
        instructionLabel.isEditable = false
        instructionLabel.isSelectable = false
        instructionLabel.font = NSFont.systemFont(ofSize: 12)
        instructionLabel.textColor = NSColor.secondaryLabelColor
        instructionLabel.alignment = .left
        instructionLabel.identifier = NSUserInterfaceItemIdentifier("pen_footer_instruction")
        
        let autoLabel = NSTextField(frame: NSRect(x: 176, y: -6, width: 150, height: 30))
        autoLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_auto")
        autoLabel.isBezeled = false
        autoLabel.drawsBackground = false
        autoLabel.isEditable = false
        autoLabel.isSelectable = false
        autoLabel.font = NSFont.systemFont(ofSize: 12)
        autoLabel.textColor = NSColor.secondaryLabelColor
        autoLabel.alignment = .right
        autoLabel.identifier = NSUserInterfaceItemIdentifier("pen_footer_auto_label")
        
        modeSwitch.identifier = NSUserInterfaceItemIdentifier("pen_footer_auto_switch_button")
        modeSwitch.isOn = true
        modeSwitch.target = self
        modeSwitch.action = #selector(handleModeSwitchChanged(_:))
        
        let textLabel = NSTextField(frame: NSRect(x: 362, y: -6, width: 16, height: footerHeight))
        textLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_label")
        textLabel.isBezeled = false
        textLabel.drawsBackground = false
        textLabel.isEditable = false
        textLabel.isSelectable = false
        textLabel.font = NSFont.systemFont(ofSize: 14)
        textLabel.textColor = NSColor.secondaryLabelColor
        textLabel.alignment = .right
        textLabel.identifier = NSUserInterfaceItemIdentifier("pen_footer_lable")
        
        footerContainer.addSubview(instructionLabel)
        footerContainer.addSubview(autoLabel)
        footerContainer.addSubview(textLabel)
        
        if let logo = ColorService.shared.getLogo() {
            let logoSize: CGFloat = 26
            let logoView = NSImageView(frame: NSRect(x: 17, y: 2, width: logoSize, height: logoSize))
            logoView.image = logo
            footerContainer.addSubview(logoView)
        }
        
        footerContainer.addSubview(modeSwitch, positioned: .above, relativeTo: nil)
        
        contentView.addSubview(footerContainer)
    }
    
    private func addEnhancedTextContainer(to contentView: NSView) {
        let enhancedTextContainer = NSView(frame: NSRect(x: 20, y: 30, width: 338, height: 198))
        enhancedTextContainer.wantsLayer = true
        enhancedTextContainer.layer?.backgroundColor = NSColor.clear.cgColor
        enhancedTextContainer.identifier = NSUserInterfaceItemIdentifier("pen_enhanced_text")
        
        let enhancedTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 338, height: 198))
        enhancedTextField.stringValue = LocalizationService.shared.localizedString(for: "pen_enhanced_text_placeholder")
        enhancedTextField.isBezeled = false
        enhancedTextField.drawsBackground = false
        enhancedTextField.isEditable = false
        enhancedTextField.isSelectable = true
        enhancedTextField.font = NSFont.systemFont(ofSize: 12)
        enhancedTextField.textColor = NSColor(red: 104.0/255.0, green: 153.0/255.0, blue: 210.0/255.0, alpha: 1.0)
        enhancedTextField.alignment = .left
        enhancedTextField.identifier = NSUserInterfaceItemIdentifier("pen_enhanced_text_text")
        enhancedTextField.wantsLayer = true
        enhancedTextField.layer?.backgroundColor = NSColor.clear.cgColor
        enhancedTextField.layer?.borderWidth = 1.0
        let borderColor = NSColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        enhancedTextField.layer?.borderColor = borderColor.cgColor
        enhancedTextField.layer?.cornerRadius = 4.0
        
        enhancedTextContainer.addSubview(enhancedTextField)
        contentView.addSubview(enhancedTextContainer)
    }
    
    private func addControllerContainer(to contentView: NSView) {
        let controllerContainer = NSView(frame: NSRect(x: 20, y: 228, width: 338, height: 30))
        controllerContainer.wantsLayer = true
        controllerContainer.layer?.backgroundColor = NSColor.clear.cgColor
        controllerContainer.identifier = NSUserInterfaceItemIdentifier("pen_controller")
        
        let promptsDropdown = NSPopUpButton(frame: NSRect(x: 0, y: 5, width: 222, height: 20))
        promptsDropdown.identifier = NSUserInterfaceItemIdentifier("pen_controller_prompts")
        promptsDropdown.addItem(withTitle: LocalizationService.shared.localizedString(for: "pen_select_prompt"))
        promptsDropdown.font = NSFont.systemFont(ofSize: 12)
        promptsDropdown.wantsLayer = true
        promptsDropdown.layer?.backgroundColor = NSColor.clear.cgColor
        promptsDropdown.layer?.borderWidth = 1.0
        let borderColor = NSColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        promptsDropdown.layer?.borderColor = borderColor.cgColor
        promptsDropdown.layer?.cornerRadius = 4.0
        
        let providerDropdown = NSPopUpButton(frame: NSRect(x: 228, y: 5, width: 110, height: 20))
        providerDropdown.identifier = NSUserInterfaceItemIdentifier("pen_controller_provider")
        providerDropdown.addItem(withTitle: LocalizationService.shared.localizedString(for: "pen_select_provider"))
        providerDropdown.font = NSFont.systemFont(ofSize: 12)
        providerDropdown.wantsLayer = true
        providerDropdown.layer?.backgroundColor = NSColor.clear.cgColor
        providerDropdown.layer?.borderWidth = 1.0
        providerDropdown.layer?.borderColor = borderColor.cgColor
        providerDropdown.layer?.cornerRadius = 4.0
        
        controllerContainer.addSubview(promptsDropdown)
        controllerContainer.addSubview(providerDropdown)
        contentView.addSubview(controllerContainer)
    }
    
    private func addReadOnlyTextContainer(to contentView: NSView) {
        readOnlyTextContainer.wantsLayer = true
        readOnlyTextContainer.layer?.backgroundColor = NSColor.clear.cgColor
        readOnlyTextContainer.identifier = NSUserInterfaceItemIdentifier("pen_original_text")
        
        let readOnlyTextField = ClickableTextField(frame: NSRect(x: 0, y: 0, width: 338, height: 88))
        readOnlyTextField.stringValue = testText
        readOnlyTextField.isBezeled = false
        readOnlyTextField.drawsBackground = false
        readOnlyTextField.isEditable = false
        readOnlyTextField.isSelectable = true
        readOnlyTextField.font = NSFont.systemFont(ofSize: 12)
        readOnlyTextField.textColor = NSColor.labelColor
        readOnlyTextField.alignment = .left
        readOnlyTextField.identifier = NSUserInterfaceItemIdentifier("pen_original_text_text")
        readOnlyTextField.wantsLayer = true
        readOnlyTextField.layer?.backgroundColor = NSColor.clear.cgColor
        readOnlyTextField.layer?.borderWidth = 1.0
        let borderColor = NSColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        readOnlyTextField.layer?.borderColor = borderColor.cgColor
        readOnlyTextField.layer?.cornerRadius = 4.0
        readOnlyTextField.toolTip = testText
        
        readOnlyTextContainer.addSubview(readOnlyTextField)
        contentView.addSubview(readOnlyTextContainer)
    }
    
    private func addManualInputComposer(to contentView: NSView) {
        inputComposerContainer.wantsLayer = true
        inputComposerContainer.layer?.backgroundColor = NSColor.clear.cgColor
        inputComposerContainer.identifier = NSUserInterfaceItemIdentifier("pen_original_text_input")
        inputComposerContainer.isHidden = true
        
        let borderColor = NSColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        
        let composerBox = NSView(frame: NSRect(x: 0, y: 0, width: 338, height: 88))
        composerBox.wantsLayer = true
        composerBox.layer?.backgroundColor = NSColor.clear.cgColor
        composerBox.layer?.borderWidth = 1.0
        composerBox.layer?.borderColor = borderColor.cgColor
        composerBox.layer?.cornerRadius = 4.0
        composerBox.layer?.masksToBounds = true
        
        let textScrollView = NSScrollView(frame: NSRect(x: 6, y: 24, width: 326, height: 58))
        textScrollView.drawsBackground = false
        textScrollView.hasVerticalScroller = true
        textScrollView.autohidesScrollers = true
        textScrollView.borderType = .noBorder
        
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: 326, height: 58))
        textView.font = NSFont.systemFont(ofSize: 12)
        textView.textColor = NSColor.labelColor
        textView.drawsBackground = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.minSize = NSSize(width: 326, height: 58)
        textView.maxSize = NSSize(width: 326, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainerInset = NSSize(width: 0, height: 2)
        textView.textContainer?.containerSize = NSSize(width: 326, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        
        textScrollView.documentView = textView
        
        let footerLine = NSView(frame: NSRect(x: 0, y: 0, width: 338, height: 24))
        footerLine.wantsLayer = true
        footerLine.layer?.backgroundColor = NSColor.clear.cgColor
        
        let hintLabel = NSTextField(frame: NSRect(x: 8, y: -1, width: 210, height: 18))
        hintLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_manual_input_hint")
        hintLabel.isBezeled = false
        hintLabel.drawsBackground = false
        hintLabel.isEditable = false
        hintLabel.isSelectable = false
        hintLabel.font = NSFont.systemFont(ofSize: 10)
        hintLabel.textColor = NSColor.secondaryLabelColor
        hintLabel.alignment = .left
        
        let sendButton = NSButton(frame: NSRect(x: 312, y: 2, width: 18, height: 18))
        sendButton.title = ""
        sendButton.isBordered = false
        sendButton.image = NSImage(contentsOfFile: ResourceService.shared.getResourcePath(relativePath: "Assets/send.svg"))
        sendButton.imagePosition = .imageOnly
        sendButton.imageScaling = .scaleProportionallyUpOrDown
        
        composerBox.addSubview(textScrollView)
        footerLine.addSubview(hintLabel)
        footerLine.addSubview(sendButton)
        composerBox.addSubview(footerLine)
        inputComposerContainer.addSubview(composerBox)
        contentView.addSubview(inputComposerContainer)
    }
    
    private func addUserLabelContainer(to contentView: NSView) {
        let userLabelContainer = NSView(frame: NSRect(x: 232, y: 359, width: 120, height: 30))
        userLabelContainer.wantsLayer = true
        userLabelContainer.layer?.backgroundColor = NSColor.clear.cgColor
        userLabelContainer.identifier = NSUserInterfaceItemIdentifier("pen_userlabel")
        
        let profileImage = NSImageView(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
        profileImage.identifier = NSUserInterfaceItemIdentifier("pen_userlabel_img")
        if let logo = ColorService.shared.getLogo() {
            profileImage.image = logo
        }
        
        let userNameLabel = NSTextField(frame: NSRect(x: 26, y: -13, width: 90, height: 30))
        userNameLabel.identifier = NSUserInterfaceItemIdentifier("pen_userlable_text")
        userNameLabel.stringValue = "Tmp User"
        userNameLabel.isBezeled = false
        userNameLabel.drawsBackground = false
        userNameLabel.isEditable = false
        userNameLabel.isSelectable = false
        userNameLabel.font = NSFont.boldSystemFont(ofSize: 12)
        userNameLabel.textColor = NSColor.labelColor
        userNameLabel.alignment = .left
        
        userLabelContainer.addSubview(profileImage)
        userLabelContainer.addSubview(userNameLabel)
        contentView.addSubview(userLabelContainer)
    }
    
    private func addManualPasteContainer(to contentView: NSView) {
        let manualPasteContainer = NSView(frame: NSRect(x: 20, y: 353, width: 300, height: 30))
        manualPasteContainer.wantsLayer = true
        manualPasteContainer.layer?.backgroundColor = NSColor.clear.cgColor
        manualPasteContainer.identifier = NSUserInterfaceItemIdentifier("pen_manual_paste")
        
        let pasteButton = NSButton(frame: NSRect(x: -1, y: 5, width: 20, height: 20))
        pasteButton.title = ""
        pasteButton.bezelStyle = .smallSquare
        pasteButton.isBordered = false
        pasteButton.image = NSImage(contentsOfFile: ResourceService.shared.getResourcePath(relativePath: "Assets/paste.svg"))
        pasteButton.identifier = NSUserInterfaceItemIdentifier("pen_manual_paste_button")
        pasteButton.state = .off
        pasteButton.focusRingType = .none
        
        let pasteLabel = NSTextField(frame: NSRect(x: 24, y: -8, width: 270, height: 30))
        pasteLabel.stringValue = LocalizationService.shared.localizedString(for: "paste_from_clipboard_simple")
        pasteLabel.isBezeled = false
        pasteLabel.drawsBackground = false
        pasteLabel.isEditable = false
        pasteLabel.isSelectable = false
        pasteLabel.font = NSFont.systemFont(ofSize: 12)
        pasteLabel.textColor = NSColor.labelColor
        pasteLabel.alignment = .left
        pasteLabel.identifier = NSUserInterfaceItemIdentifier("pen_manual_paste_text")
        
        manualPasteContainer.addSubview(pasteButton)
        manualPasteContainer.addSubview(pasteLabel)
        contentView.addSubview(manualPasteContainer)
    }
    
    @objc private func handleModeSwitchChanged(_ sender: CustomSwitch) {
        let showReadOnly = sender.isOn
        readOnlyTextContainer.isHidden = !showReadOnly
        inputComposerContainer.isHidden = showReadOnly
    }
}
