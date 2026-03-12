import Cocoa
import Foundation
import Pen

class EditAIConnectionWindow: BaseWindow, NSTextFieldDelegate {
    
    // MARK: - Singleton
    static var sharedWindow: EditAIConnectionWindow?
    private weak var settingsWindow: NSWindow?
    
    // MARK: - Properties
    private var configuration: AIConnectionModel?
    private var row: Int = -1
    private var isNew: Bool = false
    
    private let ai_input_provider = NSTextField()
    private let ai_input_key = NSTextField()
    private let ai_input_url = NSTextField()
    private let ai_input_model = NSTextField()
    
    // Callbacks
    var onSave: ((AIConnectionModel, Int) -> Void)?
    var onDelete: ((AIConnectionModel, Int) -> Void)?
    
    // MARK: - Initialization
    private init(configuration: AIConnectionModel? = nil, row: Int = -1, settingsWindow: NSWindow?) {
        self.configuration = configuration
        self.row = row
        self.isNew = configuration == nil
        self.settingsWindow = settingsWindow
        
        let windowSize = NSSize(width: 680, height: 518)
        super.init(size: windowSize)
        
        let contentView = createStandardContentView(size: windowSize)
        
        // Add PenAI logo
        addPenAILogo(to: contentView, windowHeight: windowSize.height)
        
        // Add standard close button
        addStandardCloseButton(to: contentView, windowWidth: windowSize.width, windowHeight: windowSize.height)
        
        // Add title label
        let titleLabel = NSTextField(frame: NSRect(x: 70, y: windowSize.height - 55, width: windowSize.width - 90, height: 30))
        titleLabel.stringValue = LocalizationService.shared.localizedString(for: "edit_ai_connection")
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.font = NSFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(titleLabel)
        
        setupUI(contentView: contentView, windowSize: windowSize)
        self.contentView = contentView
        
        recalculateKeyViewLoop()
        customInitialFirstResponder = ai_input_provider
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Static Methods
    static func showWindow(configuration: AIConnectionModel? = nil, row: Int = -1, settingsWindow: NSWindow?) -> EditAIConnectionWindow {
        if let existing = sharedWindow {
            existing.configuration = configuration
            existing.row = row
            existing.isNew = configuration == nil
            existing.updateFields()
            existing.settingsWindow = settingsWindow
            existing.positionWindowAtSettingsWindow(settingsWindow)
            settingsWindow?.orderOut(nil)
            existing.showAndFocus()
            return existing
        }
        
        let window = EditAIConnectionWindow(configuration: configuration, row: row, settingsWindow: settingsWindow)
        sharedWindow = window
        window.positionWindowAtSettingsWindow(settingsWindow)
        settingsWindow?.orderOut(nil)
        window.showAndFocus()
        return window
    }
    
    private func positionWindowAtSettingsWindow(_ settingsWindow: NSWindow?) {
        guard let settingsWindow = settingsWindow else { return }
        let settingsFrame = settingsWindow.frame
        self.setFrame(settingsFrame, display: true)
    }
    
    static func closeWindow() {
        sharedWindow?.closeWindowAndRestoreSettings()
        sharedWindow = nil
    }
    
    // MARK: - UI Setup
    private func setupUI(contentView: NSView, windowSize: NSSize) {
        let labelWidth: CGFloat = 100
        let fieldWidth: CGFloat = 400
        let fieldHeight: CGFloat = 24
        let largeFieldHeight: CGFloat = 44
        
        // ai_lbl_provider: 40, 380
        let ai_lbl_provider = NSTextField(frame: NSRect(x: 40, y: 380, width: labelWidth, height: fieldHeight))
        ai_lbl_provider.stringValue = LocalizationService.shared.localizedString(for: "provider_name")
        ai_lbl_provider.isBezeled = false
        ai_lbl_provider.drawsBackground = false
        ai_lbl_provider.isEditable = false
        ai_lbl_provider.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(ai_lbl_provider)
        
        // ai_input_provider: 150, 380
        ai_input_provider.frame = NSRect(x: 150, y: 380, width: fieldWidth, height: fieldHeight)
        ai_input_provider.font = NSFont.systemFont(ofSize: 13)
        ai_input_provider.delegate = self
        contentView.addSubview(ai_input_provider)
        
        // ai_lbl_key: 40, 340
        let ai_lbl_key = NSTextField(frame: NSRect(x: 40, y: 340, width: labelWidth, height: fieldHeight))
        ai_lbl_key.stringValue = LocalizationService.shared.localizedString(for: "api_key")
        ai_lbl_key.isBezeled = false
        ai_lbl_key.drawsBackground = false
        ai_lbl_key.isEditable = false
        ai_lbl_key.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(ai_lbl_key)
        
        // ai_input_key: 150, 320
        ai_input_key.frame = NSRect(x: 150, y: 320, width: fieldWidth, height: largeFieldHeight)
        ai_input_key.font = NSFont.systemFont(ofSize: 12)
        ai_input_key.lineBreakMode = .byTruncatingMiddle
        ai_input_key.delegate = self
        contentView.addSubview(ai_input_key)
        
        // ai_lbl_url: 40, 280
        let ai_lbl_url = NSTextField(frame: NSRect(x: 40, y: 280, width: labelWidth, height: fieldHeight))
        ai_lbl_url.stringValue = LocalizationService.shared.localizedString(for: "base_url")
        ai_lbl_url.isBezeled = false
        ai_lbl_url.drawsBackground = false
        ai_lbl_url.isEditable = false
        ai_lbl_url.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(ai_lbl_url)
        
        // ai_input_url: 150, 260
        ai_input_url.frame = NSRect(x: 150, y: 260, width: fieldWidth, height: largeFieldHeight)
        ai_input_url.font = NSFont.systemFont(ofSize: 12)
        ai_input_url.lineBreakMode = .byTruncatingMiddle
        ai_input_url.delegate = self
        contentView.addSubview(ai_input_url)
        
        // ai_lbl_model: 40, 220
        let ai_lbl_model = NSTextField(frame: NSRect(x: 40, y: 220, width: labelWidth, height: fieldHeight))
        ai_lbl_model.stringValue = LocalizationService.shared.localizedString(for: "model")
        ai_lbl_model.isBezeled = false
        ai_lbl_model.drawsBackground = false
        ai_lbl_model.isEditable = false
        ai_lbl_model.font = NSFont.systemFont(ofSize: 13)
        contentView.addSubview(ai_lbl_model)
        
        // ai_input_model: 150, 220
        ai_input_model.frame = NSRect(x: 150, y: 220, width: fieldWidth, height: fieldHeight)
        ai_input_model.font = NSFont.systemFont(ofSize: 13)
        ai_input_model.delegate = self
        contentView.addSubview(ai_input_model)
        
        // Buttons
        let buttonY: CGFloat = 40
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 32
        
        // ai_btn_cancel: (width of edit window) - 500, 40
        let ai_btn_cancel = FocusableButton(frame: NSRect(x: windowSize.width - 500, y: buttonY, width: buttonWidth, height: buttonHeight))
        ai_btn_cancel.title = LocalizationService.shared.localizedString(for: "cancel_button")
        ai_btn_cancel.bezelStyle = .rounded
        ai_btn_cancel.target = self
        ai_btn_cancel.action = #selector(cancelButtonClicked)
        contentView.addSubview(ai_btn_cancel)
        
        // ai_btn_delete: (width of edit window) - 370, 40
        let ai_btn_delete = FocusableButton(frame: NSRect(x: windowSize.width - 370, y: buttonY, width: buttonWidth, height: buttonHeight))
        ai_btn_delete.title = LocalizationService.shared.localizedString(for: "delete_button")
        ai_btn_delete.bezelStyle = .rounded
        ai_btn_delete.target = self
        ai_btn_delete.action = #selector(deleteButtonClicked)
        ai_btn_delete.wantsLayer = true
        ai_btn_delete.layer?.borderWidth = 1.0
        ai_btn_delete.layer?.borderColor = NSColor.systemRed.cgColor
        ai_btn_delete.layer?.cornerRadius = 6.0
        ai_btn_delete.contentTintColor = NSColor.systemRed
        contentView.addSubview(ai_btn_delete)
        
        // ai_btn_test_save: (width of edit window) - 240, 40
        let ai_btn_test_save = FocusableButton(frame: NSRect(x: windowSize.width - 240, y: buttonY, width: buttonWidth, height: buttonHeight))
        ai_btn_test_save.title = LocalizationService.shared.localizedString(for: "test_and_save_button")
        ai_btn_test_save.bezelStyle = .rounded
        ai_btn_test_save.target = self
        ai_btn_test_save.action = #selector(testAndSaveButtonClicked)
        ai_btn_test_save.wantsLayer = true
        ai_btn_test_save.layer?.borderWidth = 1.0
        ai_btn_test_save.layer?.borderColor = NSColor.systemGreen.cgColor
        ai_btn_test_save.layer?.cornerRadius = 6.0
        contentView.addSubview(ai_btn_test_save)
        
        updateFields()
    }
    
    private func updateFields() {
        if let config = configuration {
            ai_input_provider.stringValue = config.apiProvider
            ai_input_key.stringValue = config.apiKey
            ai_input_url.stringValue = config.apiUrl
            ai_input_model.stringValue = config.model
        } else {
            ai_input_provider.stringValue = ""
            ai_input_key.stringValue = ""
            ai_input_url.stringValue = "https://api.example.com/v1"
            ai_input_model.stringValue = ""
        }
    }
    
    // MARK: - Actions
    @objc private func cancelButtonClicked() {
        closeWindowAndRestoreSettings()
    }
    
    @objc private func testAndSaveButtonClicked() {
        let provider = ai_input_provider.stringValue
        let apiKey = ai_input_key.stringValue
        let baseUrl = ai_input_url.stringValue
        let model = ai_input_model.stringValue
        
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
        
        let updatedConfiguration: AIConnectionModel
        if let existing = configuration {
            updatedConfiguration = AIConnectionModel(
                id: existing.id,
                apiProvider: provider,
                apiKey: apiKey,
                apiUrl: baseUrl,
                model: model,
                isDefault: existing.isDefault
            )
        } else {
            updatedConfiguration = AIConnectionModel(
                apiProvider: provider,
                apiKey: apiKey,
                apiUrl: baseUrl,
                model: model,
                isDefault: false
            )
        }
        
        WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "testing_provider", withFormat: provider))
        
        Task {
            do {
                let aiManager = AIManager()
                let success = try await aiManager.testConnectionWithValues(
                    apiKey: apiKey,
                    baseURL: baseUrl,
                    model: model,
                    providerName: provider
                )
                
                if success {
                    DispatchQueue.main.async {
                        self.onSave?(updatedConfiguration, self.row)
                        WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "ai_connection_test_passed"))
                        print(" $$$$$$$$$$$$$$$$$$$$ AI Connection \(provider) saved! $$$$$$$$$$$$$$$$$$$$")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.closeWindowAndRestoreSettings()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "ai_connection_test_failed"))
                        print(" $$$$$$$$$$$$$$$$$$$$ AI Connection test failed $$$$$$$$$$$$$$$$$$$$")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = error.localizedDescription
                    WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "ai_connection_test_failed") + ": \(errorMessage)")
                    print(" $$$$$$$$$$$$$$$$$$$$ AI Connection test failed: \(errorMessage) $$$$$$$$$$$$$$$$$$$$")
                }
            }
        }
    }
    
    @objc private func deleteButtonClicked() {
        guard let config = configuration else { return }
        onDelete?(config, row)
    }
    
    private func closeWindowAndRestoreSettings() {
        orderOut(nil)
        settingsWindow?.makeKeyAndOrderFront(nil)
        EditAIConnectionWindow.sharedWindow = nil
    }
    
    // MARK: - Language Change
    override func languageDidChange() {
        super.languageDidChange()
    }
}
