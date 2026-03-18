import Cocoa
import AppKit

extension NSFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.bold)
    }
}

class PenDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    private var window: BaseWindow?
    private var settingsWindow: SettingsWindow?
    private var newOrEditPromptWindow: NewOrEditPrompt?
    private var penWindowService: PenWindowService?
    private var windowManager: WindowManager = WindowManager.shared
    private var forceReinitPrompts: Bool = false

    private let windowWidth: CGFloat = 378
    private let windowHeight: CGFloat = 388
    private let mouseOffset: CGFloat = 6
    private var isOnline: Bool = false
    
    init(forceReinitPrompts: Bool = false) {
        self.forceReinitPrompts = forceReinitPrompts
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("SimpleAppDelegate: Application launched")
        
        // Set activation policy to accessory to prevent Dock icon
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Force app to always use light mode (disable dark mode for now)
        NSApplication.shared.appearance = NSAppearance(named: .aqua)
        
        // Initialize system config service
        print("Initializing SystemConfigService...")
        _ = SystemConfigService.shared
        print("SystemConfigService initialized")
        
        // Setup menu bar icon first so it's available for login window positioning
        setupMenuBarIcon()
        
        // Install main menu for system shortcut support
        installMainMenu()
        
        // Create a simple window
        createMainWindow()
        
        // Setup notification observers for real-time updates
        setupNotificationObservers()
        
        // Perform 3-step initialization process
        performInitialization()
    }
    
    private func setupNotificationObservers() {
        // Observe AI connection changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(aiConnectionsDidChange(_:)),
            name: AIConnectionService.connectionsDidChangeNotification,
            object: nil
        )
        
        // Observe prompt changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(promptsDidChange(_:)),
            name: PromptService.promptsDidChangeNotification,
            object: nil
        )
        
        // Observe language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange(_:)),
            name: LocalizationService.languageDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func aiConnectionsDidChange(_ notification: Notification) {
        Task {
            await penWindowService?.reloadAIConnections()
        }
    }
    
    @objc private func promptsDidChange(_ notification: Notification) {
        Task {
            await penWindowService?.reloadPrompts()
        }
    }
    
    @objc private func languageDidChange(_ notification: Notification) {
        Task {
            await penWindowService?.reloadUI()
        }
    }
    
    @objc private func performInitialization() {
        let initializationService = InitializationService(delegate: self, forceReinitPrompts: forceReinitPrompts)
        initializationService.performInitialization()
    }
    
    func setOnlineMode(_ online: Bool, failureType: String? = nil, internetFailure: Bool = false) {
        isOnline = online
        
        if online {
            print("PenDelegate: Setting online mode")
        } else {
            print("PenDelegate: Setting offline mode")
        }
        
        // Only update status icon if statusItem is initialized
        updateStatusIcon(online: online)
        
        // Wait until menu bar icon is fully loaded before displaying popup messages
        if !online {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if let self = self {
                    // Display offline message
                    self.displayPopupMessage(LocalizationService.shared.localizedString(for: "pen_ai_offline"))
                }
            }
        }
    }
    

    
    func updateStatusIcon(online: Bool) {
        guard let button = statusItem?.button else { return }
        
        let iconName = online ? "icon" : "icon_offline"
        let iconPath = ResourceService.shared.getResourcePath(relativePath: "Assets/\(iconName).png")
        
        if let icon = NSImage(contentsOfFile: iconPath) {
            let desiredSize = NSSize(width: 22, height: 22)
            let resizedIcon = NSImage(size: desiredSize)
            
            resizedIcon.lockFocus()
            icon.draw(in: NSRect(origin: .zero, size: desiredSize), from: NSRect(origin: .zero, size: icon.size), operation: .sourceOver, fraction: 1.0)
            resizedIcon.unlockFocus()
            
            resizedIcon.isTemplate = true
            button.image = resizedIcon
            
            let tooltip: String
            if online {
                tooltip = LocalizationService.shared.localizedString(for: "hello_guest")
            } else {
                tooltip = LocalizationService.shared.localizedString(for: "pen_ai_offline")
            }
            
            button.toolTip = tooltip
        } else {
            button.title = online ? LocalizationService.shared.localizedString(for: "pen_menu_title") : LocalizationService.shared.localizedString(for: "pen_menu_title_offline")
            button.toolTip = online ? LocalizationService.shared.localizedString(for: "pen_ai") : LocalizationService.shared.localizedString(for: "pen_ai_offline")
        }
    }
    

    
    private func createMainWindow() {
        print("SimpleAppDelegate: Creating main window")
        
        penWindowService = PenWindowService()
        window = penWindowService?.createWindow()
    }
    
    /// Adds a footer container with text label and logo
    private func addFooterContainer(to contentView: NSView, size: NSSize) {
        let footerHeight: CGFloat = 30
        let footerContainer = NSView(frame: NSRect(x: 0, y: 0, width: 378, height: footerHeight))
        footerContainer.wantsLayer = true
        footerContainer.layer?.backgroundColor = NSColor.clear.cgColor
        footerContainer.identifier = NSUserInterfaceItemIdentifier("pen_footer")
        
        // Add instruction label
        let instructionLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: 180, height: footerHeight))
        instructionLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_appname")
        instructionLabel.isBezeled = false
        instructionLabel.drawsBackground = false
        instructionLabel.isEditable = false
        instructionLabel.isSelectable = false
        instructionLabel.font = NSFont.systemFont(ofSize: 12)
        instructionLabel.textColor = NSColor.secondaryLabelColor
        instructionLabel.alignment = .left
        instructionLabel.identifier = NSUserInterfaceItemIdentifier("pen_footer_instruction")
        
        // Add auto label
        let autoLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: 40, height: footerHeight))
        autoLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_auto")
        autoLabel.isBezeled = false
        autoLabel.drawsBackground = false
        autoLabel.isEditable = false
        autoLabel.isSelectable = false
        autoLabel.font = NSFont.systemFont(ofSize: 12)
        autoLabel.textColor = NSColor.secondaryLabelColor
        autoLabel.alignment = .left
        autoLabel.identifier = NSUserInterfaceItemIdentifier("pen_footer_auto_label")
        
        // Add auto switch button
        let autoSwitch = CustomSwitch(frame: NSRect(x: 0, y: 0, width: 32, height: 18))
        autoSwitch.identifier = NSUserInterfaceItemIdentifier("pen_footer_auto_switch_button")
        autoSwitch.isOn = true
        
        // Add text label
        let textLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: 250, height: footerHeight))
        textLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_label")
        textLabel.isBezeled = false
        textLabel.drawsBackground = false
        textLabel.isEditable = false
        textLabel.isSelectable = false
        textLabel.font = NSFont.systemFont(ofSize: 14)
        textLabel.textColor = NSColor.secondaryLabelColor
        textLabel.alignment = .right
        textLabel.identifier = NSUserInterfaceItemIdentifier("pen_footer_lable")
        
        // Add small logo
        if let logo = ColorService.shared.getLogo() {
            let logoSize: CGFloat = 26
            let logoView = NSImageView(frame: NSRect(x: 0, y: 0, width: logoSize, height: logoSize))
            logoView.image = logo
            
            // Set instruction label position to 44, -7 (absolute 44, 23)
            let instructionX: CGFloat = 44
            let instructionY: CGFloat = -7
            // Set auto label position to 288, -7 (absolute 288, 23)
            let autoLabelX: CGFloat = 288
            let autoLabelY: CGFloat = -7
            // Set auto switch position to 326, 6
            let autoSwitchX: CGFloat = 326
            let autoSwitchY: CGFloat = 6
            // Set text label position to 330, -6
            let textX: CGFloat = 330
            let textY: CGFloat = -6
            // Set logo position to 17, 2
            let logoX: CGFloat = 17
            let logoY: CGFloat = 2
            
            instructionLabel.frame.origin.x = instructionX
            instructionLabel.frame.origin.y = instructionY
            autoLabel.frame.origin.x = autoLabelX
            autoLabel.frame.origin.y = autoLabelY
            autoSwitch.frame.origin.x = autoSwitchX
            autoSwitch.frame.origin.y = autoSwitchY
            textLabel.frame.origin.x = textX
            textLabel.frame.origin.y = textY
            logoView.frame.origin.x = logoX
            logoView.frame.origin.y = logoY
            
            footerContainer.addSubview(instructionLabel)
            footerContainer.addSubview(autoLabel)
            footerContainer.addSubview(autoSwitch)
            footerContainer.addSubview(textLabel)
            footerContainer.addSubview(logoView)
        }
        
        footerContainer.frame.origin = NSPoint(x: 0, y: 0)
        contentView.addSubview(footerContainer)
    }
    
    private func setupMenuBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let button = statusItem?.button else {
            print("SimpleAppDelegate: Error: Could not create status item button")
            return
        }
        
        button.isBordered = false
        button.focusRingType = .none
        button.showsBorderOnlyWhileMouseInside = false
        
        updateStatusIcon(online: isOnline)
        
        button.action = #selector(handleMenuBarClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    @objc private func handleMenuBarClick(_ sender: Any) {
        if let event = NSApp.currentEvent {
            if event.type == .leftMouseUp {
                if !isOnline {
                    displayReloadOption()
                    performInitialization()
                } else {
                    openWindow()
                }
            } else if event.type == .rightMouseUp {
                let menu = NSMenu()
                
                if isOnline {
                    menu.addItem(NSMenuItem(title: LocalizationService.shared.localizedString(for: "preferences"), action: #selector(openSettings), keyEquivalent: "p"))
                    menu.addItem(NSMenuItem.separator())
                } else {
                    menu.addItem(NSMenuItem(title: LocalizationService.shared.localizedString(for: "reload"), action: #selector(performInitialization), keyEquivalent: "r"))
                    menu.addItem(NSMenuItem.separator())
                }
                
                // Always show exit option
                menu.addItem(NSMenuItem(title: LocalizationService.shared.localizedString(for: "exit"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
                
                // Show the menu at the current mouse position
                if let button = statusItem?.button {
                    NSMenu.popUpContextMenu(menu, with: event, for: button)
                }
            }
        }
    }
    
    
    /// Positions a window relative to the Pen menu bar icon
    private func positionWindowRelativeToMenuBarIcon(_ window: NSWindow) {
        guard let button = statusItem?.button, let buttonWindow = button.window else {
            print("PenDelegate: Error: Could not get status item button frame")
            // Fallback to default position if status item isn't available
            guard let screen = NSScreen.main else {
                print("PenDelegate: Error: Could not get main screen")
                return
            }
            let screenWidth = screen.frame.width
            let screenHeight = screen.frame.height
            let menuBarHeight = screen.frame.height - screen.visibleFrame.height
            
            let windowSize = window.frame.size
            let windowX = screenWidth - (screenWidth / 4) - windowSize.width
            let windowY = screenHeight - menuBarHeight - 6 - windowSize.height
            
            window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
            return
        }
        
        // Use the button's screen instead of NSScreen.main!
        guard let screen = buttonWindow.screen else {
            print("PenDelegate: Error: Could not get button screen")
            return
        }
        let screenWidth = screen.frame.width
        let screenHeight = screen.frame.height
        let menuBarHeight = screen.frame.height - screen.visibleFrame.height
        let spacing: CGFloat = 6
        let windowSize = window.frame.size
        
        // Get the button's frame in screen coordinates
        let buttonFrame = button.convert(button.bounds, to: nil)
        let buttonScreenFrame = buttonWindow.convertToScreen(buttonFrame)
        
        // Check if button screen frame is valid (not negative or zero-sized)
        if buttonScreenFrame.minY < 0 || buttonScreenFrame.width == 0 || buttonScreenFrame.height == 0 {
            print("PenDelegate: Button screen frame invalid: \(buttonScreenFrame), using fallback position")
            // Use fallback position if button frame is invalid
            let windowX = screenWidth - (screenWidth / 4) - windowSize.width
            let windowY = screenHeight - menuBarHeight - 6 - windowSize.height
            window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
            return
        }
        
        // Calculate position relative to menu bar icon
        // X position: Pen icon X + 6px
        let x = buttonScreenFrame.minX + spacing
        // Y position: top of screen - menu bar height - spacing - window height
        let y = screenHeight - menuBarHeight - spacing - windowSize.height
        
        print("PenDelegate: Menu bar icon screen frame: \(buttonScreenFrame)")
        window.setFrameOrigin(NSPoint(x: x, y: y))
        clampWindowToScreen(window, screen: screen)
        window.setFrame(window.frame, display: false, animate: false)
    }
    

    
    @objc private func openSettings() {
        // Don't close other windows - keep Pen window open for real-time updates
        
        if let window = settingsWindow {
            window.showAndFocus()
        } else {
            settingsWindow = SettingsWindow()
            
            if let window = settingsWindow {
                window.showAndFocus()
            }
        }
    }
    
    @objc private func openTestWindow() {
        let testWindow = BaseWindow.createTestWindow()
        positionWindowRelativeToMenuBarIcon(testWindow)
        testWindow.showAndFocus()
    }
    
    
    @objc private func openWindow() {
        if !isOnline {
            return
        }
        
        if window == nil {
            createMainWindow()
        }
        
        if let window = window {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                closeOtherWindows()
                
                if self.window == nil {
                    createMainWindow()
                }
                
                if let window = self.window {
                    window.positionRelativeToMenuBarIcon()
                    
                    Task {
                        await penWindowService?.initiatePen()
                    }
                    
                    window.showAndFocus()
                }
            }
        }
    }
    
    private func closeOtherWindows() {
        for window in NSApplication.shared.windows {
            // Skip Settings window - keep it open for real-time updates
            if window is SettingsWindow {
                continue
            }
            window.orderOut(nil)
        }
        
        window = nil
        // Don't nil settingsWindow - keep it open
        newOrEditPromptWindow = nil
    }
    

    
    private func positionWindowRelativeToMouseCursor(_ window: NSWindow) {
        let mouseLocation = NSEvent.mouseLocation
        
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) ?? NSScreen.main else {
            return
        }
        
        let windowX = mouseLocation.x + mouseOffset
        let windowY = mouseLocation.y - mouseOffset - window.frame.height
        
        window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        clampWindowToScreen(window, screen: screen)
    }
    
    private func clampWindowToScreen(_ window: NSWindow, screen: NSScreen) {
        let visibleFrame = screen.visibleFrame
        var frame = window.frame
        
        if frame.maxX > visibleFrame.maxX {
            frame.origin.x = visibleFrame.maxX - frame.width
        }
        if frame.minX < visibleFrame.minX {
            frame.origin.x = visibleFrame.minX
        }
        
        if frame.minY < visibleFrame.minY {
            frame.origin.y = visibleFrame.minY
        }
        if frame.maxY > visibleFrame.maxY {
            frame.origin.y = visibleFrame.maxY - frame.height
        }
        
        window.setFrame(frame, display: false)
    }
    
    @objc private func openPenAI() {
        if !isOnline {
            return
        }
        
        if let window = window {
            if window.isVisible {
                positionWindowRelativeToMouseCursor(window)
                
                Task {
                    await penWindowService?.initiatePen()
                }
                
                window.makeKeyAndOrderFront(nil)
            } else {
                closeOtherWindows()
                
                positionWindowRelativeToMouseCursor(window)
                
                Task {
                    await penWindowService?.initiatePen()
                }
                
                window.showAndFocus()
            }
        }
    }
    
    func toggleMainWindow() {
        if !isOnline {
            return
        }
        
        if window == nil {
            createMainWindow()
        }
        
        if let window = window {
            if window.isVisible {
                positionWindowRelativeToMouseCursor(window)
                
                Task {
                    await penWindowService?.initiatePen()
                }
                
                window.makeKeyAndOrderFront(nil)
            } else {
                closeOtherWindows()
                
                positionWindowRelativeToMouseCursor(window)
                
                Task {
                    await penWindowService?.initiatePen()
                }
                
                window.showAndFocus()
            }
        }
    }
    
    @objc private func closeWindow() {
        window?.orderOut(nil)
    }
    
    
    /// Sets the app mode and updates the UI accordingly
    func setAppMode(_ mode: AppMode, showPopup: Bool = true) {
        switch mode {
        case .online:
            isOnline = true
        case .offline:
            isOnline = false
        }
        
        // Update the menu bar icon
        updateStatusIcon(online: isOnline)
    }
    
    /// Updates the menu bar icon based on current state
    func updateMenuBarIcon() {
        updateStatusIcon(online: isOnline)
    }
    
    
    // App mode enumeration
    enum AppMode {
        case online
        case offline
    }
    
    /// Displays a global popup message following the specified design guidelines
    func displayPopupMessage(_ message: String) {
        windowManager.displayPopupMessage(message)
    }
    
    /// Displays a reload option when in offline mode
    private func displayReloadOption() {
        guard statusItem?.button != nil else { return }
        
        // Create a temporary label for the reload message
        let reloadLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 20))
        reloadLabel.stringValue = LocalizationService.shared.localizedString(for: "click_to_reload")
        reloadLabel.isBezeled = false
        reloadLabel.drawsBackground = false
        reloadLabel.isEditable = false
        reloadLabel.isSelectable = false
        reloadLabel.textColor = .systemGreen
        reloadLabel.font = NSFont.systemFont(ofSize: 12)
        
        // Create a window for the reload message
        let reloadWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 200, height: 20), 
                                  styleMask: [.borderless], 
                                  backing: .buffered, 
                                  defer: false)
        reloadWindow.isOpaque = false
        reloadWindow.backgroundColor = .clear
        reloadWindow.level = .floating
        reloadWindow.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .transient
        ]
        reloadWindow.contentView = reloadLabel
        
        // Position reload window relative to menu bar icon
        positionWindowRelativeToMenuBarIcon(reloadWindow)
        
        // Show the reload message without stealing focus
        reloadWindow.orderFrontRegardless()
        
        // Hide the reload message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            reloadWindow.orderOut(nil)
        }
        
        print("PenDelegate: Displayed reload option")
    }
    
    /// Handles paste button click
    @objc private func handlePasteButton() {
        print("PenDelegate: Paste button clicked")
        // Implement paste functionality here
        // For now, we'll just print a message
    }

}

// Main function is handled by @main attribute
