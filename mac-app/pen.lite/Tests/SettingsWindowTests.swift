import XCTest
@testable import Pen

class SettingsWindowTests: XCTestCase {
    private var settingsWindow: SettingsWindow?
    
    override func setUp() {
        super.setUp()
        settingsWindow = SettingsWindow()
    }
    
    override func tearDown() {
        settingsWindow = nil
        super.tearDown()
    }
    
    /// Test that settings window is initialized correctly
    func testSettingsWindowInitialization() {
        // Arrange & Act: Create settings window
        let window = SettingsWindow()
        
        // Assert: Window should be initialized
        XCTAssertNotNil(window)
    }
    
    /// Test that settings window has correct size
    func testSettingsWindowSize() {
        // Arrange: Create settings window
        let window = SettingsWindow()
        
        // Assert: Window should have correct size
        XCTAssertEqual(window.frame.width, 680)
        XCTAssertEqual(window.frame.height, 520)
    }
    
    /// Test that language dropdown exists
    func testLanguageDropdownExists() {
        // Arrange: Create settings window
        let window = SettingsWindow()
        
        // Act: Access the language dropdown using reflection
        let mirror = Mirror(reflecting: window)
        let languageDropdown = mirror.children.first { $0.label == "languageDropdown" }?.value as? NSPopUpButton
        
        // Assert: languageDropdown should be initialized
        XCTAssertNotNil(languageDropdown)
    }
    
    /// Test that tab view exists
    func testTabViewExists() {
        // Arrange: Create settings window
        let window = SettingsWindow()
        
        // Act: Access the tab view using reflection
        let mirror = Mirror(reflecting: window)
        let tabView = mirror.children.first { $0.label == "tabView" }?.value as? NSTabView
        
        // Assert: tabView should be initialized
        XCTAssertNotNil(tabView)
    }
    
    /// Test that tab view has correct number of tabs
    func testTabViewHasCorrectNumberOfTabs() {
        // Arrange: Create settings window
        let window = SettingsWindow()
        
        // Act: Access the tab view using reflection
        let mirror = Mirror(reflecting: window)
        let tabView = mirror.children.first { $0.label == "tabView" }?.value as? NSTabView
        
        // Assert: tabView should have 2 tabs (AI Connections, Prompts)
        XCTAssertEqual(tabView?.numberOfTabViewItems, 2)
    }
}
