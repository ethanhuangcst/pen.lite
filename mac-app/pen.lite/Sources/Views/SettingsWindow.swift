import Cocoa

class SettingsWindow: BaseWindow {
    // MARK: - Properties
    private let windowWidth = UILayoutConstants.settingsWindowWidth
    private let windowHeight = UILayoutConstants.settingsWindowHeight
    
    private var titleLabel: NSTextField!
    private var languageLabel: NSTextField!
    private var languageDropdown: NSPopUpButton!
    private var tabView: NSTabView!
    
    // MARK: - Initialization
    init() {
        let windowSize = NSSize(width: windowWidth, height: windowHeight)
        
        // Create window with borderless style (default from BaseWindow)
        super.init(size: windowSize)
        
        // Set up content view
        setupContentView()
        
        // Position the window relative to the menu bar icon
        positionRelativeToMenuBarIcon()
        
        // Set window level to floating (below modalPanel)
        self.level = .floating
    }
    
    // MARK: - Language Change
    override func languageDidChange() {
        super.languageDidChange()
        
        // Update title
        titleLabel?.stringValue = LocalizationService.shared.localizedString(for: "pen_ai_preferences")
        
        // Update language label
        languageLabel?.stringValue = LocalizationService.shared.localizedString(for: "language_label")
        
        // Update tab labels
        updateTabLabels()
        
        // Refresh all tab views
        refreshTabViews()
        
        print("SettingsWindow: Language changed, UI updated")
    }
    
    private func updateTabLabels() {
        guard let tabView = tabView else { return }
        
        let tabKeys = ["ai_connections", "prompts"]
        for (index, key) in tabKeys.enumerated() {
            if index < tabView.numberOfTabViewItems {
                let tabItem = tabView.tabViewItem(at: index)
                tabItem.label = LocalizationService.shared.localizedString(for: key)
            }
        }
    }
    
    private func refreshTabViews() {
        guard let tabView = tabView else { return }
        
        for i in 0..<tabView.numberOfTabViewItems {
            if let tabItem = tabView.tabViewItem(at: i) as? NSTabViewItem,
               let tabContentView = tabItem.view {
                for subview in tabContentView.subviews {
                    if let aiConfigTab = subview as? AIConfigurationTabView {
                        aiConfigTab.languageDidChange()
                    } else if let promptsTab = subview as? PromptsTabView {
                        promptsTab.languageDidChange()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up the content view with logo and tabs
    private func setupContentView() {
        // Create standard content view with consistent styling
        let contentView = createStandardContentView(size: NSSize(width: windowWidth, height: windowHeight))
        
        // Debug: Print current directory
        let currentDirectory = FileManager.default.currentDirectoryPath
        print("PreferencesWindow: Current directory: \(currentDirectory)")
        
        // Add standard close button
        addStandardCloseButton(to: contentView, windowWidth: windowWidth, windowHeight: windowHeight)
        
        // Add PenAI logo
        addPenAILogo(to: contentView, windowHeight: windowHeight)
        
        // Add title
        titleLabel = NSTextField.createBoldLabel(
            frame: NSRect(
                x: UILayoutConstants.SettingsWindow.titleXOffset,
                y: windowHeight - UILayoutConstants.headerHeight,
                width: UILayoutConstants.SettingsWindow.titleWidth,
                height: UILayoutConstants.SettingsWindow.titleHeight
            ),
            value: LocalizationService.shared.localizedString(for: "pen_ai_preferences")
        )
        contentView.addSubview(titleLabel)
        
        // Add language switch
        addLanguageSwitch(to: contentView, windowHeight: windowHeight)
        
        // Add user_settings frame
        let userSettingsFrame = NSView(frame: NSRect(
            x: UILayoutConstants.SettingsWindow.tabViewXOffset,
            y: UILayoutConstants.SettingsWindow.tabViewYOffset,
            width: windowWidth - UILayoutConstants.SettingsWindow.tabViewWidthOffset,
            height: windowHeight - UILayoutConstants.SettingsWindow.tabViewHeightOffset
        ))
        userSettingsFrame.wantsLayer = true
        userSettingsFrame.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        
        // Add tab view to user_settings frame
        tabView = NSTabView(frame: NSRect(x: 0, y: 0, width: userSettingsFrame.frame.width, height: userSettingsFrame.frame.height))
        
        // Create tabs
        addTab(to: tabView, title: LocalizationService.shared.localizedString(for: "ai_connections"), iconPath: ResourceService.shared.getResourcePath(relativePath: "Assets/AI.png"))
        addTab(to: tabView, title: LocalizationService.shared.localizedString(for: "prompts"), iconPath: ResourceService.shared.getResourcePath(relativePath: "Assets/prompts.png"))
        
        userSettingsFrame.addSubview(tabView)
        contentView.addSubview(userSettingsFrame)
        
        // Set content view
        self.contentView = contentView
    }
    
    /// Adds a tab to the tab view
    private func addTab(to tabView: NSTabView, title: String, iconPath: String) {
        let tabItem = NSTabViewItem(identifier: title)
        tabItem.label = title
        
        // Create tab content view
        let tabContentView = NSView(frame: NSRect(origin: .zero, size: tabView.frame.size))
        tabContentView.wantsLayer = true
        tabContentView.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        
        // Add content based on tab title
        if title == LocalizationService.shared.localizedString(for: "ai_connections") {
            // Use the new AIConfigurationTabView
            let aiConfigurationTabView = AIConfigurationTabView(frame: tabContentView.bounds, parentWindow: self)
            tabContentView.addSubview(aiConfigurationTabView)
        } else if title == LocalizationService.shared.localizedString(for: "prompts") {
            // Use the new PromptsTabView
            let promptsTabView = PromptsTabView(frame: tabContentView.bounds, parentWindow: self)
            tabContentView.addSubview(promptsTabView)
        }
        
        tabItem.view = tabContentView
        tabView.addTabViewItem(tabItem)
    }
    
    private func addLanguageSwitch(to contentView: NSView, windowHeight: CGFloat) {
        languageLabel = NSTextField(frame: NSRect(
            x: UILayoutConstants.SettingsWindow.languageLabelX,
            y: UILayoutConstants.SettingsWindow.languageLabelY,
            width: UILayoutConstants.SettingsWindow.languageLabelWidth,
            height: UILayoutConstants.SettingsWindow.languageLabelHeight
        ))
        languageLabel.stringValue = LocalizationService.shared.localizedString(for: "language_label")
        languageLabel.isBezeled = false
        languageLabel.drawsBackground = false
        languageLabel.isEditable = false
        languageLabel.isSelectable = false
        languageLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        languageLabel.alignment = .left
        contentView.addSubview(languageLabel)
        
        languageDropdown = NSPopUpButton(frame: NSRect(
            x: UILayoutConstants.SettingsWindow.languageDropdownX,
            y: UILayoutConstants.SettingsWindow.languageDropdownY,
            width: UILayoutConstants.SettingsWindow.languageDropdownWidth,
            height: UILayoutConstants.SettingsWindow.languageDropdownHeight
        ))
        languageDropdown.bezelStyle = .rounded
        languageDropdown.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        
        for language in AppLanguage.allCases {
            languageDropdown.addItem(withTitle: language.displayName)
        }
        
        let currentLanguage = LocalizationService.shared.language
        if let index = AppLanguage.allCases.firstIndex(of: currentLanguage) {
            languageDropdown.selectItem(at: index)
        }
        
        languageDropdown.target = self
        languageDropdown.action = #selector(languageDropdownChanged(_:))
        
        contentView.addSubview(languageDropdown)
    }
    
    @objc private func languageDropdownChanged(_ sender: NSPopUpButton) {
        guard let selectedTitle = sender.titleOfSelectedItem,
              let selectedLanguage = AppLanguage.allCases.first(where: { $0.displayName == selectedTitle }) else {
            return
        }
        
        LocalizationService.shared.setLanguage(selectedLanguage)
    }
}
