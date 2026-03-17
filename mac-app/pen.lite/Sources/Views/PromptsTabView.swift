import Cocoa
import Foundation

class PromptsTabView: NSView, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - Properties
    private let tableView = NSTableView()
    private let scrollView = NSScrollView()
    private let defaultLabel = NSTextField()
    private let userLabel = NSTextField()
    private let addButton = FocusableButton()
    private let emptyStateView = NSView()
    private let emptyStateLabel = NSTextField()
    private var prompts: [Prompt] = []
    private weak var parentWindow: NSWindow?
    
    // MARK: - Initialization
    init(frame: CGRect, parentWindow: NSWindow? = nil) {
        self.parentWindow = parentWindow
        super.init(frame: frame)
        
        setupView()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Language Change
    @objc func languageDidChange() {
        userLabel.stringValue = LocalizationService.shared.localizedString(for: "predefined_prompts_for", withFormat: "Pen")
        defaultLabel.stringValue = LocalizationService.shared.localizedString(for: "first_prompt_default")
        addButton.title = LocalizationService.shared.localizedString(for: "new_button")
        emptyStateLabel.stringValue = LocalizationService.shared.localizedString(for: "no_prompts_saved_yet")
        
        if let tableColumns = tableView.tableColumns as? [NSTableColumn] {
            for column in tableColumns {
                if column.identifier.rawValue == "name" {
                    column.title = LocalizationService.shared.localizedString(for: "prompt_name_column")
                } else if column.identifier.rawValue == "prompt" {
                    column.title = LocalizationService.shared.localizedString(for: "prompt_column")
                }
            }
        }
        
        tableView.reloadData()
        needsDisplay = true
        print("PromptsTabView: Language changed, UI updated")
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        
        setupUserLabel()
        setupDefaultLabel()
        setupTableView()
        setupActionButtons()
        
        loadPromptsFromFiles()
    }
    
    private func loadPromptsFromFiles() {
        Task {
            do {
                let loadedPrompts = try PromptService.shared.getPrompts()
                DispatchQueue.main.async {
                    self.prompts = loadedPrompts.sorted { (p1, p2) in
                        if p1.isDefault { return true }
                        if p2.isDefault { return false }
                        return p1.promptName < p2.promptName
                    }
                    self.tableView.reloadData()
                    self.updateEmptyStateView()
                }
            } catch {
                print("[PromptsTabView] Failed to load prompts: \(error)")
                WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "failed_to_load_prompts"))
                DispatchQueue.main.async {
                    self.updateEmptyStateView()
                }
            }
        }
    }
    
    private func updateEmptyStateView() {
        if prompts.isEmpty {
            emptyStateView.isHidden = false
            scrollView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            scrollView.isHidden = false
        }
    }
    
    private func setupActionButtons() {
        addButton.frame = NSRect(x: 20, y: 10, width: 88, height: 32)
        addButton.title = LocalizationService.shared.localizedString(for: "new_button")
        addButton.bezelStyle = .rounded
        addButton.layer?.borderWidth = 1.0
        addButton.layer?.borderColor = NSColor.systemGreen.cgColor
        addButton.layer?.cornerRadius = 6.0
        addButton.target = self
        addButton.action = #selector(addNewPrompt)
        addSubview(addButton)
    }
    
    private func setupUserLabel() {
        let windowWidth = frame.width
        let windowHeight = frame.height
        
        userLabel.frame = NSRect(x: 20, y: windowHeight - 92, width: windowWidth - 40, height: 24)
        userLabel.stringValue = LocalizationService.shared.localizedString(for: "predefined_prompts_for", withFormat: "Pen")
        userLabel.isBezeled = false
        userLabel.drawsBackground = false
        userLabel.isEditable = false
        userLabel.isSelectable = false
        userLabel.font = NSFont.boldSystemFont(ofSize: 16)
        addSubview(userLabel)
    }
    
    // MARK: - Setup Methods
    private func setupDefaultLabel() {
        let windowWidth = frame.width
        let windowHeight = frame.height
        
        defaultLabel.frame = NSRect(x: 20, y: windowHeight - 108, width: windowWidth - 40, height: 16)
        defaultLabel.stringValue = LocalizationService.shared.localizedString(for: "first_prompt_default")
        defaultLabel.isBezeled = false
        defaultLabel.drawsBackground = false
        defaultLabel.isEditable = false
        defaultLabel.isSelectable = false
        defaultLabel.font = NSFont.systemFont(ofSize: 12)
        defaultLabel.textColor = NSColor.secondaryLabelColor
        addSubview(defaultLabel)
    }
    
    private func setupTableView() {
        let windowWidth = frame.width
        let windowHeight = frame.height
        
        let tableContainer = NSView(frame: NSRect(x: 20, y: 50, width: windowWidth - 40, height: windowHeight - 166))
        tableContainer.wantsLayer = true
        tableContainer.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        tableContainer.layer?.borderWidth = 1.0
        tableContainer.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.5).cgColor
        tableContainer.layer?.cornerRadius = 8.0
        addSubview(tableContainer)
        
        scrollView.frame = tableContainer.bounds
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        tableContainer.addSubview(scrollView)
        
        tableView.frame = scrollView.bounds
        tableView.dataSource = self
        tableView.delegate = self
        
        // Column widths match AI Connections table: Provider=120, API Key=380
        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
        nameColumn.title = LocalizationService.shared.localizedString(for: "prompt_name_column")
        nameColumn.width = 120
        tableView.addTableColumn(nameColumn)
        
        let promptColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("prompt"))
        promptColumn.title = LocalizationService.shared.localizedString(for: "prompt_column")
        promptColumn.width = 380
        tableView.addTableColumn(promptColumn)
        
        tableView.wantsLayer = true
        tableView.layer?.borderWidth = 1.0
        tableView.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.3).cgColor
        
        tableView.target = self
        tableView.doubleAction = #selector(handleDoubleClick(_:))
        
        scrollView.documentView = tableView
        
        setupEmptyStateView(tableContainer: tableContainer)
    }
    
    private func setupEmptyStateView(tableContainer: NSView) {
        emptyStateView.frame = tableContainer.bounds
        emptyStateView.wantsLayer = true
        emptyStateView.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        
        emptyStateLabel.frame = NSRect(x: 0, y: emptyStateView.frame.height / 2 - 15, width: emptyStateView.frame.width, height: 30)
        emptyStateLabel.stringValue = LocalizationService.shared.localizedString(for: "no_prompts_saved_yet")
        emptyStateLabel.isBezeled = false
        emptyStateLabel.drawsBackground = false
        emptyStateLabel.isEditable = false
        emptyStateLabel.isSelectable = false
        emptyStateLabel.font = NSFont.systemFont(ofSize: 16)
        emptyStateLabel.alignment = .center
        emptyStateView.addSubview(emptyStateLabel)
        
        tableContainer.addSubview(emptyStateView)
        
        emptyStateView.isHidden = true
    }
    
    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return prompts.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let prompt = prompts[row]
        
        guard let columnIdentifier = tableColumn?.identifier else { return nil }
        
        if columnIdentifier.rawValue == "name" {
            return prompt.promptName
        } else if columnIdentifier.rawValue == "prompt" {
            return prompt.promptText
        }
        return nil
    }
    
    // MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnIdentifier = tableColumn?.identifier else { return nil }
        let prompt = prompts[row]
        
        if columnIdentifier.rawValue == "name" {
            let textField = createReadonlyTextField(text: prompt.promptName, maxWidth: 120)
            if prompt.isDefault {
                textField.stringValue = "\(prompt.promptName) \(LocalizationService.shared.localizedString(for: "default_suffix"))"
            }
            return textField
        } else if columnIdentifier.rawValue == "prompt" {
            let textField = createReadonlyTextField(text: prompt.promptText, maxWidth: 380)
            return textField
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, canDragRowsWithIndexes rowIndexes: IndexSet, at point: NSPoint) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 70.0
    }
    
    // MARK: - Double-Click Handler
    @objc private func handleDoubleClick(_ sender: NSTableView) {
        let row = sender.clickedRow
        guard row >= 0, row < prompts.count, let parentWindow = parentWindow else { return }
        
        let prompt = prompts[row]
        let editWindow = NewOrEditPrompt.showWindow(prompt: prompt, originatingWindow: parentWindow)
        
        editWindow.onSave = { [weak self] updatedPrompt in
            guard let self = self else { return }
            Task {
                do {
                    try PromptService.shared.updatePrompt(updatedPrompt)
                    DispatchQueue.main.async {
                        self.loadPromptsFromFiles()
                        WindowManager.shared.displayPopupMessage(
                            LocalizationService.shared.localizedString(for: "prompt_updated_successfully")
                        )
                    }
                } catch {
                    print("[PromptsTabView] Failed to update prompt: \(error)")
                }
            }
        }
        
        editWindow.onDelete = { [weak self] promptToDelete in
            guard let self = self else { return }
            self.showDeleteConfirmationDialog(prompt: promptToDelete, row: row)
        }
    }
    
    // MARK: - UI Helper Methods
    private func createReadonlyTextField(text: String, maxWidth: CGFloat) -> NSTextField {
        let textField = NSTextField(frame: NSRect(x: 0, y: 5, width: maxWidth, height: 60))
        textField.stringValue = trimTextToFit(text, maxWidth: maxWidth)
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.font = NSFont.systemFont(ofSize: 14)
        textField.cell?.wraps = true
        textField.cell?.usesSingleLineMode = false
        
        textField.toolTip = text
        
        return textField
    }
    
    // MARK: - Helper Methods
    private func trimTextToFit(_ text: String, maxWidth: CGFloat) -> String {
        let font = NSFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let fullString = text as NSString
        let fullSize = fullString.size(withAttributes: attributes)
        
        if fullSize.width <= maxWidth {
            return text
        }
        
        var truncated = text
        while truncated.size(withAttributes: attributes).width > maxWidth && !truncated.isEmpty {
            truncated = String(truncated.dropLast())
        }
        
        return truncated + "..."
    }
    
    private func trimText(_ text: String, maxLines: Int) -> String {
        let lines = text.components(separatedBy: "\n")
        if lines.count <= maxLines {
            return text
        } else {
            return lines.prefix(maxLines).joined(separator: "\n") + "..."
        }
    }
    
    // MARK: - Delete Confirmation Dialog
    private var promptForDelete: Prompt?
    private var rowForDelete: Int = 0
    
    private func showDeleteConfirmationDialog(prompt: Prompt, row: Int) {
        if prompts.count <= 1 {
            WindowManager.shared.displayPopupMessage(
                LocalizationService.shared.localizedString(for: "cannot_delete_last_prompt")
            )
            return
        }
        
        promptForDelete = prompt
        rowForDelete = row
        
        let dialogWidth: CGFloat = 238
        let dialogHeight: CGFloat = 100
        
        // Center the dialog in the NewOrEditPrompt window
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        
        if let editWindow = NewOrEditPrompt.sharedWindow {
            let editFrame = editWindow.frame
            originX = editFrame.origin.x + (editFrame.width - dialogWidth) / 2
            originY = editFrame.origin.y + (editFrame.height - dialogHeight) / 2
        } else if let settingsWindow = self.window {
            let settingsFrame = settingsWindow.frame
            originX = settingsFrame.origin.x + (settingsFrame.width - dialogWidth) / 2
            originY = settingsFrame.origin.y + (settingsFrame.height - dialogHeight) / 2
        }
        
        let dialogWindow = NSWindow(
            contentRect: NSRect(x: originX, y: originY, width: dialogWidth, height: dialogHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        dialogWindow.isMovable = true
        dialogWindow.isMovableByWindowBackground = true
        dialogWindow.isOpaque = false
        dialogWindow.backgroundColor = .clear
        dialogWindow.level = .floating
        dialogWindow.hasShadow = true
        
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: dialogWidth, height: dialogHeight))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = ColorService.shared.backgroundColorCGColor
        contentView.layer?.cornerRadius = 12
        contentView.layer?.masksToBounds = true
        
        let titleLabel = NSTextField(frame: NSRect(x: 20, y: dialogHeight - 40, width: dialogWidth - 40, height: 20))
        titleLabel.stringValue = LocalizationService.shared.localizedString(for: "are_you_sure")
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.alignment = .center
        contentView.addSubview(titleLabel)
        
        let cancelButton = NSButton(frame: NSRect(x: 41, y: 20, width: 68, height: 32))
        cancelButton.title = LocalizationService.shared.localizedString(for: "cancel_button")
        cancelButton.bezelStyle = .rounded
        cancelButton.layer?.borderWidth = 1.0
        cancelButton.layer?.borderColor = NSColor.systemGray.cgColor
        cancelButton.layer?.cornerRadius = 6.0
        cancelButton.target = self
        cancelButton.action = #selector(cancelDeleteDialog(_:))
        contentView.addSubview(cancelButton)
        
        let deleteButton = NSButton(frame: NSRect(x: 129, y: 20, width: 68, height: 32))
        deleteButton.title = LocalizationService.shared.localizedString(for: "delete_button")
        deleteButton.bezelStyle = .rounded
        deleteButton.layer?.borderWidth = 1.0
        deleteButton.layer?.borderColor = NSColor.systemRed.cgColor
        deleteButton.layer?.cornerRadius = 6.0
        deleteButton.contentTintColor = NSColor.systemRed
        deleteButton.target = self
        deleteButton.action = #selector(confirmDeleteDialog(_:))
        contentView.addSubview(deleteButton)
        
        dialogWindow.contentView = contentView
        
        dialogWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc private func cancelDeleteDialog(_ sender: Any) {
        if let window = sender as? NSButton, let dialogWindow = window.window {
            dialogWindow.orderOut(nil)
            promptForDelete = nil
        }
    }
    
    @objc private func confirmDeleteDialog(_ sender: Any) {
        guard let prompt = promptForDelete else { return }
        let row = rowForDelete
        
        if let button = sender as? NSButton, let dialogWindow = button.window {
            dialogWindow.orderOut(nil)
            promptForDelete = nil
            
            Task {
                do {
                    try PromptService.shared.deletePrompt(id: prompt.id)
                    
                    DispatchQueue.main.async {
                        NewOrEditPrompt.closeWindow()
                        self.prompts.remove(at: row)
                        self.tableView.reloadData()
                        self.updateEmptyStateView()
                        WindowManager.shared.displayPopupMessage(
                            LocalizationService.shared.localizedString(for: "prompt_deleted_successfully")
                        )
                    }
                } catch {
                    print("[PromptsTabView] Failed to delete prompt: \(error)")
                    DispatchQueue.main.async {
                        WindowManager.shared.displayPopupMessage(
                            LocalizationService.shared.localizedString(for: "failed_to_delete_prompt")
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Button Actions
    @objc private func addNewPrompt() {
        if let parentWindow = parentWindow {
            let newPromptWindow = NewOrEditPrompt.showWindow(prompt: nil, originatingWindow: parentWindow)
            
            newPromptWindow.onSave = { [weak self] newPrompt in
                guard let self = self else { return }
                Task {
                    do {
                        try PromptService.shared.createPrompt(newPrompt)
                        
                        DispatchQueue.main.async {
                            self.loadPromptsFromFiles()
                            WindowManager.shared.displayPopupMessage(
                                LocalizationService.shared.localizedString(for: "prompt_created_successfully")
                            )
                        }
                    } catch {
                        print("[PromptsTabView] Failed to create prompt: \(error)")
                        DispatchQueue.main.async {
                            WindowManager.shared.displayPopupMessage(
                                LocalizationService.shared.localizedString(for: "failed_to_create_prompt")
                            )
                        }
                    }
                }
            }
        }
    }
}
