import Cocoa

class SettingsWindow: BaseWindow {
    // MARK: - Properties
    private let windowWidth: CGFloat = 600
    
    private var titleLabel: NSTextField!
    private var tabView: NSTabView!
    
    // MARK: - Initialization
    init() {
        // Calculate window size
        let windowHeight: CGFloat = 518 // Fixed height as specified in requirements
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
        // Use fixed height as specified in requirements (518px)
        let windowHeight: CGFloat = 518 // Fixed height as specified in requirements
        
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
        titleLabel = NSTextField(frame: NSRect(x: 70, y: windowHeight - 55, width: 200, height: 30))
        titleLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_ai_preferences")
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(titleLabel)
        
        // Add user_settings frame
        let userSettingsFrame = NSView(frame: NSRect(x: 20, y: 20, width: windowWidth - 40, height: windowHeight - 120)) // Space from header
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
    

    

}
