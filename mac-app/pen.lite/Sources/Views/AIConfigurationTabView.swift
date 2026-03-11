import Cocoa

// Import LocalizationService for i18n support
import Foundation

// Import models and services
import Pen

class AIConfigurationTabView: NSView, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - Properties
    private let userLabel = NSTextField()
    private let defaultLabel = NSTextField()
    private let configurationsTable = NSTableView()
    private let addButton = FocusableButton()
    private let tableContainer = NSView()
    
    // Data properties
    private var configurations: [AIConnectionModel] = []
    private weak var parentWindow: NSWindow?
    
    // MARK: - Initialization
    init(frame: CGRect, parentWindow: NSWindow? = nil) {
        self.parentWindow = parentWindow
        
        super.init(frame: frame)
        
        wantsLayer = true
        layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        
        setupUI()
        setupTableView()
        loadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Language Change
    @objc func languageDidChange() {
        // Update all labels with localized strings
        userLabel.stringValue = LocalizationService.shared.localizedString(for: "ai_connections_for", withFormat: "Pen")
        defaultLabel.stringValue = LocalizationService.shared.localizedString(for: "first_connection_default")
        addButton.title = LocalizationService.shared.localizedString(for: "new_button")
        
        // Update table column headers
        if let tableColumns = configurationsTable.tableColumns as? [NSTableColumn] {
            for column in tableColumns {
                switch column.identifier.rawValue {
                case "provider":
                    column.title = LocalizationService.shared.localizedString(for: "provider_column")
                case "apiKey":
                    column.title = LocalizationService.shared.localizedString(for: "api_key")
                case "delete":
                    column.title = LocalizationService.shared.localizedString(for: "delete_column")
                default:
                    break
                }
            }
        }
        
        configurationsTable.reloadData()
        needsDisplay = true
        print("AIConfigurationTabView: Language changed, UI updated")
    }
    
    static func createAIConfigurationTab(parentWindow: NSWindow? = nil) -> AIConfigurationTabView {
        let frame = CGRect(x: 0, y: 0, width: 680, height: 520)
        return AIConfigurationTabView(frame: frame, parentWindow: parentWindow)
    }
    
    private func setupTableView() {
        // Set data source and delegate
        configurationsTable.dataSource = self
        configurationsTable.delegate = self
        configurationsTable.target = self
        configurationsTable.doubleAction = #selector(handleDoubleClick(_:))
        
        // Add scroll view
        let scrollView = NSScrollView(frame: tableContainer.bounds)
        scrollView.documentView = configurationsTable
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        tableContainer.addSubview(scrollView)
    }
    
    @objc private func handleDoubleClick(_ sender: NSTableView) {
        let row = sender.clickedRow
        guard row >= 0, row < configurations.count else { return }
        
        let configuration = configurations[row]
        showEditWindow(configuration: configuration, row: row)
    }
    
    private func loadData() {
        // Load AI configurations from local files
        Task {
            await loadConfigurations()
        }
    }
    
    private func loadConfigurations() async {
        do {
            let fileConfigurations = try AIConnectionService.shared.getConnections()
            print("Loaded \(fileConfigurations.count) AI configurations from files")
            
            configurations = fileConfigurations
            print("Total configurations: \(configurations.count)")
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.configurationsTable.reloadData()
            }
        } catch {
            print("Error loading AI configurations: \(error)")
        }
    }
    
    private func setupUI() {
        let windowWidth = frame.width
        let windowHeight = frame.height
        
        // Setup UI components
        setupUserLabel(windowWidth: windowWidth, windowHeight: windowHeight)
        setupDefaultLabel(windowWidth: windowWidth, windowHeight: windowHeight)
        setupTableContainer(windowWidth: windowWidth, windowHeight: windowHeight)
        setupActionButtons(windowWidth: windowWidth)
    }
    
    // MARK: - UI Setup
    private func setupUserLabel(windowWidth: CGFloat, windowHeight: CGFloat) {
        userLabel.frame = NSRect(x: 20, y: windowHeight - 92, width: windowWidth - 40, height: 24)
        userLabel.stringValue = LocalizationService.shared.localizedString(for: "ai_connections_for", withFormat: "[User Name]")
        userLabel.isBezeled = false
        userLabel.drawsBackground = false
        userLabel.isEditable = false
        userLabel.isSelectable = false
        userLabel.font = NSFont.boldSystemFont(ofSize: 16)
        addSubview(userLabel)
    }
    
    private func setupDefaultLabel(windowWidth: CGFloat, windowHeight: CGFloat) {
        defaultLabel.frame = NSRect(x: 20, y: windowHeight - 108, width: windowWidth - 40, height: 16)
        defaultLabel.stringValue = LocalizationService.shared.localizedString(for: "first_connection_default")
        defaultLabel.isBezeled = false
        defaultLabel.drawsBackground = false
        defaultLabel.isEditable = false
        defaultLabel.isSelectable = false
        defaultLabel.font = NSFont.systemFont(ofSize: 12)
        defaultLabel.textColor = NSColor.secondaryLabelColor
        addSubview(defaultLabel)
    }
    
    private func setupTableContainer(windowWidth: CGFloat, windowHeight: CGFloat) {
        tableContainer.frame = NSRect(x: 20, y: 50, width: windowWidth - 40, height: windowHeight - 166)
        tableContainer.wantsLayer = true
        tableContainer.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        tableContainer.layer?.borderWidth = 1.0
        tableContainer.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.5).cgColor
        tableContainer.layer?.cornerRadius = 8.0
        addSubview(tableContainer)
        
        setupConfigurationsTable()
    }
    
    private func setupConfigurationsTable() {
        // Create table view
        configurationsTable.frame = NSRect(x: 0, y: 0, width: tableContainer.frame.width, height: tableContainer.frame.height)
        configurationsTable.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        // Set row height to accommodate full API key display
        configurationsTable.rowHeight = 32
        configurationsTable.usesAutomaticRowHeights = false
        
        // Create columns - read-only table
        let providerColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("provider"))
        providerColumn.title = LocalizationService.shared.localizedString(for: "provider_column")
        providerColumn.width = 120
        providerColumn.minWidth = 120
        configurationsTable.addTableColumn(providerColumn)
        
        let apiKeyColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("apiKey"))
        apiKeyColumn.title = LocalizationService.shared.localizedString(for: "api_key")
        apiKeyColumn.width = 380
        apiKeyColumn.minWidth = 380
        configurationsTable.addTableColumn(apiKeyColumn)
        
        let deleteColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("delete"))
        deleteColumn.title = LocalizationService.shared.localizedString(for: "delete_column")
        deleteColumn.width = 60
        deleteColumn.minWidth = 60
        configurationsTable.addTableColumn(deleteColumn)
        
        // Add header view
        let headerView = NSTableHeaderView()
        headerView.frame = NSRect(x: 0, y: configurationsTable.frame.height - 22, width: configurationsTable.frame.width, height: 22)
        configurationsTable.headerView = headerView
        
        tableContainer.addSubview(configurationsTable)
    }
    
    private func setupActionButtons(windowWidth: CGFloat) {
        // New button
        addButton.frame = NSRect(x: 20, y: 10, width: 88, height: 32)
        addButton.title = LocalizationService.shared.localizedString(for: "new_button")
        addButton.bezelStyle = .rounded
        addButton.layer?.borderWidth = 1.0
        addButton.layer?.borderColor = NSColor.systemGreen.cgColor
        addButton.layer?.cornerRadius = 6.0
        addButton.target = self
        addButton.action = #selector(addNewConfiguration)
        addSubview(addButton)
    }
    
    // MARK: - Public Methods
    func setUserName(_ name: String) {
        userLabel.stringValue = LocalizationService.shared.localizedString(for: "ai_connections_for", withFormat: name)
    }
    
    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return configurations.count
    }
    
    // MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn, row < configurations.count else { return nil }
        
        let configuration = configurations[row]
        
        switch tableColumn.identifier.rawValue {
        case "provider":
            return createReadOnlyTextField(value: configuration.apiProvider)
        case "apiKey":
            return createReadOnlyTextField(value: configuration.apiKey)
        case "delete":
            return createDeleteButton(row: row)
        default:
            return nil
        }
    }
    
    private func createReadOnlyTextField(value: String) -> NSTextField {
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 32))
        textField.stringValue = value
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = true
        textField.font = NSFont.systemFont(ofSize: 12)
        textField.lineBreakMode = .byTruncatingTail
        return textField
    }
    
    // Disable row reordering
    func tableView(_ tableView: NSTableView, canDragRowsWithIndexes rowIndexes: IndexSet, at point: NSPoint) -> Bool {
        return false
    }
    
    private func createDeleteButton(row: Int) -> NSButton {
        let button = NSButton(frame: NSRect(x: 20, y: 2, width: 20, height: 20))
        button.bezelStyle = .texturedRounded
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false
        let imagePath = ResourceService.shared.getResourcePath(relativePath: "Assets/delete.svg")
        let image = NSImage(contentsOfFile: imagePath)
        image?.size = NSSize(width: 18, height: 18)
        button.image = image
        button.target = self
        button.action = #selector(deleteConfiguration(_:))
        button.tag = row
        button.contentTintColor = NSColor.systemRed
        return button
    }
    
    // MARK: - Actions
    
    @objc private func deleteConfiguration(_ sender: NSButton) {
        let row = sender.tag
        if row < configurations.count {
            // Check if this is the last configuration
            if configurations.count <= 1 {
                WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "cannot_delete_last_configuration"))
                return
            }
            
            let configuration = configurations[row]
            
            // Show custom confirmation dialog
            showDeleteConfirmationDialog(configuration: configuration, row: row)
        }
    }
    
    private func deleteAIConfiguration(configuration: AIConnectionModel, row: Int) {
        Task {
            do {
                // Delete from files
                try AIConnectionService.shared.deleteConnection(id: configuration.id)
                
                // Remove from local array
                DispatchQueue.main.async {
                    self.configurations.remove(at: row)
                    self.configurationsTable.reloadData()
                    // Show popup message
                    WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "ai_connection_deleted_successfully"))
                }
                
                print(" $$$$$$$$$$$$$$$$$$$$ AI Configuration \(configuration.apiProvider) deleted! $$$$$$$$$$$$$$$$$$$$")
            } catch {
                print("Error deleting AI configuration: \(error)")
                DispatchQueue.main.async {
                    WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "failed_to_delete_ai_configuration"))
                }
            }
        }
    }
    
    @objc private func addNewConfiguration() {
        // Create a new configuration with default values
        let newConfiguration = AIConnectionModel(
            apiProvider: "OpenAI",
            apiKey: "",
            apiUrl: "https://api.openai.com/v1/chat/completions",
            model: "gpt-3.5-turbo",
            isDefault: false
        )
        
        configurations.append(newConfiguration)
        configurationsTable.reloadData()
    }
    
    // Store configurations temporarily for delete confirmation
    private var configurationsForDelete: [AIConnectionModel] = []
    
    private func showDeleteConfirmationDialog(configuration: AIConnectionModel, row: Int) {
        // Create custom dialog window
        let dialogWidth: CGFloat = 238
        let dialogHeight: CGFloat = 100
        
        // Calculate position - center in edit window if available, otherwise center in settings window
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        
        if let editWindow = editWindow {
            // Center in edit window
            let editFrame = editWindow.frame
            originX = editFrame.origin.x + (editFrame.width - dialogWidth) / 2
            originY = editFrame.origin.y + (editFrame.height - dialogHeight) / 2
        } else if let settingsWindow = self.window {
            // Center in settings window
            let settingsFrame = settingsWindow.frame
            originX = settingsFrame.origin.x + (settingsFrame.width - dialogWidth) / 2
            originY = settingsFrame.origin.y + (settingsFrame.height - dialogHeight) / 2
        } else {
            // Fallback to mouse location
            let mouseLocation = NSEvent.mouseLocation
            originX = mouseLocation.x - dialogWidth / 2
            originY = mouseLocation.y - dialogHeight / 2
        }
        
        let dialogWindow = NSWindow(
            contentRect: NSRect(x: originX, y: originY, width: dialogWidth, height: dialogHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Configure window
        dialogWindow.isMovable = true
        dialogWindow.isMovableByWindowBackground = true
        dialogWindow.isOpaque = false
        dialogWindow.backgroundColor = .clear
        dialogWindow.level = .floating
        dialogWindow.hasShadow = true
        
        // Create content view
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: dialogWidth, height: dialogHeight))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        contentView.layer?.cornerRadius = 12
        contentView.layer?.masksToBounds = true
        
        // Add shadow
        let shadow = NSShadow()
        shadow.shadowColor = ColorService.shared.shadowColor.withAlphaComponent(0.3)
        shadow.shadowOffset = NSSize(width: 0, height: -3)
        shadow.shadowBlurRadius = 8
        
        // Add title label
        let titleLabel = NSTextField(frame: NSRect(x: 20, y: dialogHeight - 40, width: dialogWidth - 40, height: 20))
        titleLabel.stringValue = LocalizationService.shared.localizedString(for: "are_you_sure")
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.alignment = .center
        contentView.addSubview(titleLabel)
        
        // Add cancel button
        let cancelButton = NSButton(frame: NSRect(x: 41, y: 20, width: 68, height: 32))
        cancelButton.title = LocalizationService.shared.localizedString(for: "cancel_button")
        cancelButton.bezelStyle = .rounded
        cancelButton.layer?.borderWidth = 1.0
        cancelButton.layer?.borderColor = NSColor.systemGray.cgColor
        cancelButton.layer?.cornerRadius = 6.0
        cancelButton.target = self
        cancelButton.action = #selector(cancelDeleteDialog(_:))
        contentView.addSubview(cancelButton)
        
        // Store the configuration for later use
        configurationsForDelete = [configuration]
        
        // Add delete button
        let deleteButton = NSButton(frame: NSRect(x: 129, y: 20, width: 68, height: 32))
        deleteButton.title = LocalizationService.shared.localizedString(for: "delete_button")
        deleteButton.bezelStyle = .rounded
        deleteButton.layer?.borderWidth = 1.0
        deleteButton.layer?.borderColor = NSColor.systemRed.cgColor
        deleteButton.layer?.cornerRadius = 6.0
        deleteButton.contentTintColor = NSColor.systemRed
        deleteButton.target = self
        deleteButton.action = #selector(confirmDeleteDialog(_:))
        deleteButton.tag = row
        contentView.addSubview(deleteButton)
        
        // Set content view
        dialogWindow.contentView = contentView
        
        // Clamp window to screen bounds
        if let screen = NSScreen.main {
            let visibleFrame = screen.visibleFrame
            var frame = dialogWindow.frame
            
            // Clamp horizontally
            if frame.maxX > visibleFrame.maxX {
                frame.origin.x = visibleFrame.maxX - frame.width
            }
            if frame.minX < visibleFrame.minX {
                frame.origin.x = visibleFrame.minX
            }
            
            // Clamp vertically
            if frame.minY < visibleFrame.minY {
                frame.origin.y = visibleFrame.minY
            }
            if frame.maxY > visibleFrame.maxY {
                frame.origin.y = visibleFrame.maxY - frame.height
            }
            
            // Apply the clamped position
            dialogWindow.setFrame(frame, display: false)
        }
        
        // Show the dialog
        dialogWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc private func cancelDeleteDialog(_ sender: Any) {
        if let window = sender as? NSButton, let dialogWindow = window.window {
            dialogWindow.orderOut(nil)
            configurationsForDelete = []
        }
    }
    
    @objc private func confirmDeleteDialog(_ sender: Any) {
        if let button = sender as? NSButton, let dialogWindow = button.window, !configurationsForDelete.isEmpty {
            let configuration = configurationsForDelete[0]
            let row = button.tag
            dialogWindow.orderOut(nil)
            configurationsForDelete = []
            deleteAIConfiguration(configuration: configuration, row: row)
        }
    }
    
    // MARK: - Edit Window
    
    private var editWindow: NSWindow?
    private var editingConfiguration: AIConnectionModel?
    private var editingRow: Int = -1
    private var providerField: NSTextField?
    private var apiKeyField: NSTextField?
    private var baseUrlField: NSTextField?
    private var modelField: NSTextField?
    
    private func showEditWindow(configuration: AIConnectionModel, row: Int) {
        // Store the configuration being edited
        editingConfiguration = configuration
        editingRow = row
        
        // Create edit window - borderless style to remove toolbar and system controls
        let windowWidth: CGFloat = 450
        let windowHeight: CGFloat = 380
        
        editWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        guard let editWindow = editWindow else { return }
        
        // Configure window - hide title bar while keeping keyboard input
        editWindow.titlebarAppearsTransparent = true
        editWindow.titleVisibility = .hidden
        editWindow.isMovableByWindowBackground = true
        editWindow.level = .floating
        editWindow.hasShadow = true
        
        // Create content view with rounded corners
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        contentView.layer?.cornerRadius = 12
        contentView.layer?.masksToBounds = true
        
        // Add title label (since we removed the title bar)
        let titleLabel = NSTextField(frame: NSRect(x: 20, y: windowHeight - 40, width: windowWidth - 40, height: 24))
        titleLabel.stringValue = LocalizationService.shared.localizedString(for: "edit_ai_connection")
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.alignment = .center
        contentView.addSubview(titleLabel)
        
        // Add close button (X) in top right corner
        let closeButton = NSButton(frame: NSRect(x: windowWidth - 35, y: windowHeight - 35, width: 20, height: 20))
        closeButton.title = "×"
        closeButton.font = NSFont.boldSystemFont(ofSize: 18)
        closeButton.bezelStyle = .circular
        closeButton.isBordered = false
        closeButton.target = self
        closeButton.action = #selector(cancelEditWindow)
        contentView.addSubview(closeButton)
        
        // Add fields
        let labelWidth: CGFloat = 100
        let fieldWidth: CGFloat = 300
        let fieldHeight: CGFloat = 24
        let largeFieldHeight: CGFloat = 44
        let startX: CGFloat = 20
        let startY: CGFloat = windowHeight - 80
        let rowSpacing: CGFloat = 60
        
        // Provider Name
        let providerLabel = NSTextField(frame: NSRect(x: startX, y: startY, width: labelWidth, height: fieldHeight))
        providerLabel.stringValue = LocalizationService.shared.localizedString(for: "provider_name")
        providerLabel.isBezeled = false
        providerLabel.drawsBackground = false
        providerLabel.isEditable = false
        providerLabel.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(providerLabel)
        
        providerField = NSTextField(frame: NSRect(x: startX + labelWidth, y: startY, width: fieldWidth, height: fieldHeight))
        providerField?.stringValue = configuration.apiProvider
        providerField?.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(providerField!)
        
        // API Key - larger field with more height
        let apiKeyLabel = NSTextField(frame: NSRect(x: startX, y: startY - rowSpacing + 20, width: labelWidth, height: fieldHeight))
        apiKeyLabel.stringValue = LocalizationService.shared.localizedString(for: "api_key")
        apiKeyLabel.isBezeled = false
        apiKeyLabel.drawsBackground = false
        apiKeyLabel.isEditable = false
        apiKeyLabel.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(apiKeyLabel)
        
        // API Key field - larger height for long keys
        apiKeyField = NSTextField(frame: NSRect(x: startX + labelWidth, y: startY - rowSpacing, width: fieldWidth, height: largeFieldHeight))
        apiKeyField?.stringValue = configuration.apiKey
        apiKeyField?.font = NSFont.systemFont(ofSize: 12)
        apiKeyField?.lineBreakMode = .byTruncatingMiddle
        contentView.addSubview(apiKeyField!)
        
        // Base URL - larger field with more height
        let baseUrlLabel = NSTextField(frame: NSRect(x: startX, y: startY - rowSpacing * 2 + 20, width: labelWidth, height: fieldHeight))
        baseUrlLabel.stringValue = LocalizationService.shared.localizedString(for: "base_url")
        baseUrlLabel.isBezeled = false
        baseUrlLabel.drawsBackground = false
        baseUrlLabel.isEditable = false
        baseUrlLabel.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(baseUrlLabel)
        
        // Base URL field - larger height for long URLs
        baseUrlField = NSTextField(frame: NSRect(x: startX + labelWidth, y: startY - rowSpacing * 2, width: fieldWidth, height: largeFieldHeight))
        baseUrlField?.stringValue = configuration.apiUrl
        baseUrlField?.font = NSFont.systemFont(ofSize: 12)
        baseUrlField?.lineBreakMode = .byTruncatingMiddle
        contentView.addSubview(baseUrlField!)
        
        // Model
        let modelLabel = NSTextField(frame: NSRect(x: startX, y: startY - rowSpacing * 3 + 20, width: labelWidth, height: fieldHeight))
        modelLabel.stringValue = LocalizationService.shared.localizedString(for: "model")
        modelLabel.isBezeled = false
        modelLabel.drawsBackground = false
        modelLabel.isEditable = false
        modelLabel.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(modelLabel)
        
        modelField = NSTextField(frame: NSRect(x: startX + labelWidth, y: startY - rowSpacing * 3 + 20, width: fieldWidth, height: fieldHeight))
        modelField?.stringValue = configuration.model
        modelField?.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(modelField!)
        
        // Buttons
        let buttonY: CGFloat = 20
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 32
        
        // Cancel button
        let cancelButton = NSButton(frame: NSRect(x: startX, y: buttonY, width: buttonWidth, height: buttonHeight))
        cancelButton.title = LocalizationService.shared.localizedString(for: "cancel_button")
        cancelButton.bezelStyle = .rounded
        cancelButton.target = self
        cancelButton.action = #selector(cancelEditWindow)
        contentView.addSubview(cancelButton)
        
        // Test & Save button
        let testSaveButton = NSButton(frame: NSRect(x: startX + buttonWidth + 20, y: buttonY, width: buttonWidth + 40, height: buttonHeight))
        testSaveButton.title = LocalizationService.shared.localizedString(for: "test_and_save_button")
        testSaveButton.bezelStyle = .rounded
        testSaveButton.target = self
        testSaveButton.action = #selector(saveConfiguration)
        testSaveButton.layer?.borderWidth = 1.0
        testSaveButton.layer?.borderColor = NSColor.systemGreen.cgColor
        testSaveButton.layer?.cornerRadius = 6.0
        contentView.addSubview(testSaveButton)
        
        // Delete button
        let deleteButton = NSButton(frame: NSRect(x: windowWidth - buttonWidth - 20, y: buttonY, width: buttonWidth, height: buttonHeight))
        deleteButton.title = LocalizationService.shared.localizedString(for: "delete_button")
        deleteButton.bezelStyle = .rounded
        deleteButton.target = self
        deleteButton.action = #selector(deleteFromEditWindow)
        deleteButton.layer?.borderWidth = 1.0
        deleteButton.layer?.borderColor = NSColor.systemRed.cgColor
        deleteButton.layer?.cornerRadius = 6.0
        deleteButton.contentTintColor = NSColor.systemRed
        contentView.addSubview(deleteButton)
        
        editWindow.contentView = contentView
        
        // Center the edit window in the Settings window
        if let settingsWindow = self.window {
            let settingsFrame = settingsWindow.frame
            let editFrame = editWindow.frame
            
            let centerX = settingsFrame.origin.x + (settingsFrame.width - editFrame.width) / 2
            let centerY = settingsFrame.origin.y + (settingsFrame.height - editFrame.height) / 2
            
            editWindow.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        }
        
        // Activate app and show window with focus
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        editWindow.makeKeyAndOrderFront(nil)
        
        // Set first responder to provider field after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let providerField = self?.providerField {
                self?.editWindow?.makeFirstResponder(providerField)
            }
        }
    }
    
    @objc private func cancelEditWindow() {
        editWindow?.orderOut(nil)
        editWindow = nil
        editingConfiguration = nil
        editingRow = -1
    }
    
    @objc private func saveConfiguration() {
        guard let provider = providerField?.stringValue,
              let apiKey = apiKeyField?.stringValue,
              let baseUrl = baseUrlField?.stringValue,
              let model = modelField?.stringValue,
              let configuration = editingConfiguration,
              editingRow >= 0 else {
            return
        }
        
        // Validate fields
        guard !provider.isEmpty else {
            WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "provider_name_required"))
            return
        }
        
        guard !apiKey.isEmpty else {
            WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "api_key_required"))
            return
        }
        
        guard !baseUrl.isEmpty else {
            WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "base_url_required"))
            return
        }
        
        guard !model.isEmpty else {
            WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "model_required"))
            return
        }
        
        // Create updated configuration
        let updatedConfiguration = AIConnectionModel(
            id: configuration.id,
            apiProvider: provider,
            apiKey: apiKey,
            apiUrl: baseUrl,
            model: model,
            isDefault: configuration.isDefault
        )
        
        // Save configuration
        self.configurations[self.editingRow] = updatedConfiguration
        try? AIConnectionService.shared.saveConnections(self.configurations)
        
        self.configurationsTable.reloadData()
        
        // Show success message and wait before closing
        WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "ai_connection_saved_successfully"))
        print(" $$$$$$$$$$$$$$$$$$$$ AI Connection \(provider) saved! $$$$$$$$$$$$$$$$$$$$")
        
        // Wait 2 seconds before closing the window
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.editWindow?.orderOut(nil)
            self.editWindow = nil
            self.editingConfiguration = nil
            self.editingRow = -1
        }
    }
    
    @objc private func deleteFromEditWindow() {
        guard let configuration = editingConfiguration, editingRow >= 0 else { return }
        
        // Check if this is the last configuration
        if configurations.count <= 1 {
            WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "cannot_delete_last_configuration"))
            return
        }
        
        // Show delete confirmation dialog without closing edit window
        showDeleteConfirmationDialog(configuration: configuration, row: editingRow)
    }
}
