# PenWindowService Design Document

## 1. Overview

PenWindowService is a dedicated service responsible for managing all behaviors and lifecycle events of the Pen application window. It provides a centralized interface for window creation, positioning, state management, and interaction handling. This service abstracts window-related functionality from the main application logic, promoting separation of concerns and improving maintainability.

## 2. Architecture

### 2.1 System Context

```mermaid
flowchart TD
    A[PenDelegate] -->|Creates| B[PenWindowService]
    B -->|Manages| C[BaseWindow]
    B -->|Coordinates with| D[PromptService]
    B -->|Coordinates with| E[AIConnectionService]
    B -->|Coordinates with| F[LocalizationService]
    B -->|Handles| G[User Interactions]
    B -->|Manages| H[Window State]
```

### 2.2 Component Structure

- **PenWindowService**: Core service managing window operations
- **BaseWindow**: Custom window class extending NSWindow
- **WindowState**: Struct holding window state information
- **PenDelegate**: Application delegate that initializes the service

## 3. Responsibilities

### 3.1 Core Responsibilities

1. **Window Lifecycle Management**
   - Create and destroy Pen application window
   - Handle window show/hide operations
   - Manage window state persistence

2. **Window Positioning**
   - Position window relative to menu bar icon
   - Position window relative to mouse cursor
   - Clamp window to screen bounds

3. **UI Component Management**
   - Initialize and configure all UI components
   - Manage component states
   - Handle component interactions

4. **Data Integration**
   - Load user prompts from PromptService
   - Load AI configurations from AIConnectionService
   - Handle clipboard operations

5. **Clipboard Operations**
   - Read most recent text from Mac clipboard
   - Detect if clipboard content is text type
   - Load text type content from clipboard
   - Copy content to Mac clipboard

6. **Event Handling**
   - Handle user interactions
   - Respond to system events

7. **Input Mode Switching**
   - Switch input source between Auto mode and Manual mode
   - In Auto mode, load clipboard text into `pen_original_text_text`
   - In Manual mode, use `pen_original_text_input` as editable source
   - In Manual mode, trigger enhancement by `Cmd+Enter` or send button click
   - In Manual mode, plain Enter inserts a newline without triggering enhancement
   - Preserve manual draft text across mode changes
   - Persist selected mode across app restart

8. **Localization**
   - Apply localized strings to UI components
   - Handle language changes

9. **Error Handling**
   - Handle window-related errors
   - Handle clipboard-related errors
   - Display appropriate error messages

## 4. Key Components

### 4.1 PenWindowService

```swift
class PenWindowService {
    static let shared = PenWindowService()
    
    private var window: BaseWindow?
    private var windowState: WindowState
    
    // Initialization
    private init() {}
    
    // Window lifecycle methods
    func createWindow() -> BaseWindow
    func showWindow()
    func hideWindow()
    func toggleWindow()
    
    // Positioning methods
    func positionWindowRelativeToMenuBarIcon()
    func positionWindowRelativeToMouseCursor()
    func clampWindowToScreen()
    
    // UI management methods
    func initializeUIComponents()
    func updateUIComponents()
    func switchInputMode(_ mode: InputMode)
    func restoreSavedInputMode()
    
    // Data loading methods
    func loadPrompts()
    func loadAIConfigurations()
    func loadClipboardContent()
    
    // Clipboard methods
    func readClipboardText() -> String?
    func isClipboardTextType() -> Bool
    func copyToClipboard(_ text: String)
    
    // Event handling methods
    func handlePasteButtonClick()
    func handleCopyButtonClick()
    func handleInputModeSwitch()
    func handleManualInputSend()
    func handleManualInputKeyDown()
    func handlePromptSelection()
    func handleProviderSelection()
    
    // Initialization method
    func initiatePen() async
}
```

### 4.2 WindowState

```swift
struct WindowState {
    var isVisible: Bool
    var lastPosition: NSPoint
    var selectedPromptId: String?
    var selectedProviderId: String?
    var originalText: String
    var manualInputText: String
    var enhancedText: String
    var inputMode: InputMode
    
    mutating func updateState()
    func saveState()
    static func loadState() -> WindowState
}
```

```swift
enum InputMode {
    case auto
    case manual
}
```

## 5. Data Flow

### 5.1 Window Creation Flow

```mermaid
sequenceDiagram
    participant PD as PenDelegate
    participant PWS as PenWindowService
    participant BW as BaseWindow
    participant PS as PromptService
    participant AM as AIConnectionService
    
    PD->>PWS: createWindow()
    PWS->>BW: initialize()
    PWS->>PS: loadPrompts()
    PS-->>PWS: return prompts
    PWS->>AM: loadAIConfigurations()
    AM-->>PWS: return configurations
    PWS->>PWS: initializeUIComponents()
    PWS->>PWS: loadClipboardContent()
    PWS-->>PD: return window
```

### 5.2 User Interaction Flow

```mermaid
sequenceDiagram
    participant U as User
    participant PWS as PenWindowService
    participant AM as AIConnectionService
    participant BW as BaseWindow
    
    U->>PWS: click paste button
    PWS->>PWS: handlePasteButtonClick()
    PWS->>PWS: loadClipboardContent()
    PWS->>BW: updateOriginalText()
    U->>PWS: toggle input mode switch
    PWS->>PWS: handleInputModeSwitch()
    alt switched to Auto mode
        PWS->>PWS: loadClipboardContent()
        PWS->>BW: update pen_original_text_text
        PWS->>PWS: keep manualInputText unchanged
    else switched to Manual mode
        PWS->>BW: show pen_original_text_input
        PWS->>BW: reset pen_enhanced_text_text to default hint
        PWS->>PWS: restore manualInputText draft
    end
    U->>PWS: press Cmd+Enter in manual input
    PWS->>PWS: handleManualInputKeyDown()
    PWS->>PWS: handleManualInputSend()
    PWS->>AM: processText(manual input text)
    U->>PWS: click manual send button
    PWS->>PWS: handleManualInputSend()
    PWS->>AM: processText(manual input text)
    U->>PWS: press Enter without Command in manual input
    PWS->>PWS: handleManualInputKeyDown()
    PWS->>BW: insert newline in pen_original_text_input
    U->>PWS: select prompt and provider
    PWS->>PWS: handlePromptSelection()
    PWS->>PWS: handleProviderSelection()
    U->>PWS: trigger enhancement
    PWS->>AM: processText()
    AM-->>PWS: return enhanced text
    PWS->>PWS: trimTextToFitLines(enhancedText, in: pen_enhanced_text_text, maxLines: 5)
    PWS->>BW: updateEnhancedText(trimmedText)
```

### 5.3 InitiatePen Flow

```mermaid
sequenceDiagram
    participant PD as PenDelegate
    participant PWS as PenWindowService
    participant AM as AIConnectionService
    participant PS as PromptService
    participant BW as BaseWindow
    
    PD->>PWS: initiatePen()
    
    %% Load AI Configurations
    PWS->>AM: checkGlobalInstance()
    alt Global AIConnectionService exists
        PWS->>AM: loadConfigurations()
        PWS->>PWS: print "AIConnectionService found..."
    else Global AIConnectionService not found
        PWS->>AM: createNewInstance()
        PWS->>AM: loadConfigurations()
        PWS->>PWS: print "AIConnectionService NOT found..."
    end
    
    alt AI configurations loaded
        PWS->>PS: loadPrompts()
        PS-->>PWS: return prompts
        PWS->>BW: populateProvidersDropdown()
        PWS->>BW: populatePromptsDropdown()
        PWS->>BW: selectDefaultProviderAndPrompt()
    else AI configurations load failure
        PWS->>BW: displayNoProvidersMessage()
        PWS->>BW: displayNoPromptsMessage()
        PWS->>BW: addOpenSettingsButton()
        PWS->>PWS: log error
    else No AI providers configured
        PWS->>PWS: displayPopupMessage("You don't have any available AI connections...")
        PWS->>BW: displayMessageInEnhancedText()
        PWS->>BW: displayNoProvidersMessage()
        PWS->>BW: displayNoPromptsMessage()
        PWS->>BW: addOpenSettingsButton()
    end
    
    %% Process Clipboard Content
    PWS->>PWS: loadClipboardContent()
    
    alt Clipboard has valid text
        PWS->>BW: updateOriginalText()
    else Clipboard has non-text content
        PWS->>BW: displayPlaceholderText()
    else Clipboard is empty
        PWS->>BW: displayEmptyClipboardMessage()
        PWS->>BW: enablePasteButton()
    else Clipboard read failure
        PWS->>BW: displayClipboardErrorMessage()
        PWS->>BW: enablePasteButton()
        PWS->>PWS: log error
    end
    
    %% UI Initialization
    PWS->>BW: initializeUIComponents()
    PWS->>BW: applyLocalization()
    PWS->>PWS: setupEventHandlers()
    
    PWS-->>PD: initialization complete
```

## 6. Methods

### 6.1 Window Lifecycle Methods

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `createWindow()` | Creates a new Pen window | None | `BaseWindow` |
| `showWindow()` | Shows the Pen window | None | `Void` |
| `hideWindow()` | Hides the Pen window | None | `Void` |
| `toggleWindow()` | Toggles window visibility | None | `Void` |
| `closeWindow()` | Closes the Pen window | None | `Void` |

### 6.2 Positioning Methods

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `positionWindowRelativeToMenuBarIcon()` | Positions window near menu bar icon | None | `Void` |
| `positionWindowRelativeToMouseCursor()` | Positions window near mouse cursor | None | `Void` |
| `clampWindowToScreen()` | Ensures window stays within screen bounds | None | `Void` |

### 6.3 UI Management Methods

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `initializeUIComponents()` | Initializes all UI components | None | `Void` |
| `updateUIComponents()` | Updates UI components with current data | None | `Void` |
| `updateOriginalText(_:)` | Updates auto-mode original text field with trimmed display text and full-text tooltip storage | `String` | `Void` |
| `updateEnhancedText(_:)` | Updates enhanced text field with text, trims it to fit, and adds tooltip for hover-over functionality | `String` | `Void` |
| `switchInputMode(_:)` | Switches input source between Auto and Manual mode and updates related UI state | `InputMode` | `Void` |
| `restoreSavedInputMode()` | Restores previously saved input mode with Auto fallback | None | `Void` |
| `updatePromptDropdown(_:)` | Updates prompt dropdown with new data | `[Prompt]` | `Void` |
| `updateProviderDropdown(_:)` | Updates provider dropdown with new data | `[AIProvider]` | `Void` |
| `trimTextToFitLines(_:in:maxLines:)` | Trims text to fit within specified number of lines and adds "..." at the end | `String` (text to trim), `NSTextField` (text field), `Int` (max lines) | `String` (trimmed text) |

### 6.4 Data Loading Methods

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `loadPrompts()` | Loads prompts from local storage | None | `[Prompt]` |
| `loadAIConfigurations()` | Loads AI configurations from local storage | None | `[AIProvider]` |
| `loadClipboardContent()` | Loads content from system clipboard | None | `String?` |

### 6.5 Event Handling Methods

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `handlePasteButtonClick()` | Handles paste button click event | None | `Void` |
| `handleCopyButtonClick()` | Handles copy button click event | None | `Void` |
| `handleInputModeSwitch()` | Handles switch toggle and routes UI/data updates for Auto/Manual mode | None | `Void` |
| `handleManualInputSend()` | Handles manual input send action and triggers enhancement from `pen_original_text_input` | None | `Void` |
| `handleManualInputKeyDown()` | Routes manual input keyboard behavior (`Cmd+Enter` send, Enter newline) | None | `Void` |
| `handlePromptSelection(_:)` | Handles prompt selection change | `String` (prompt ID) | `Void` |
| `handleProviderSelection(_:)` | Handles provider selection change | `String` (provider ID) | `Void` |
| `handleEnhanceButtonClick()` | Handles enhance button click event, triggers AI processing, and trims the result | None | `Void` |
| `handleEnhancedTextClick()` | Handles click on enhanced text to copy to clipboard | None | `Void` |

### 6.6 Clipboard Methods

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `readClipboardText()` | Reads plain text from system clipboard | None | `String?` |
| `isClipboardTextType()` | Detects if clipboard content is text type | None | `Bool` |
| `copyToClipboard(_:)` | Copies text to system clipboard | `String` (text to copy) | `Void` |
| `loadClipboardContent()` | Loads clipboard content and updates UI | None | `String?` |

### 6.7 Initialization Method

| Method | Description | Parameters | Return Value |
|--------|-------------|------------|--------------|
| `initiatePen()` | Initializes Pen window according to user stories | None | `Void` |

## 7. Integration Points

### 7.1 External Services

- **PromptService**: Loads user prompts and manages prompt-related operations
- **AIConnectionService**: Handles AI-related operations and text enhancement
- **LocalizationService**: Provides localized strings for UI components
- **WindowManager**: Provides popup message functionality

### 7.2 Application Delegate

- **PenDelegate**: Initializes and coordinates with PenWindowService

### 7.3 UI Components

- **BaseWindow**: Custom window class managed by PenWindowService
- **NSTextField**: Text fields for original and enhanced text
  - **pen_original_text_text**: Auto-mode source text (clipboard-driven, trimmed display with full-text tooltip)
  - **pen_original_text_input**: Manual-mode source text (editable, scrollable text area with hint row and send button)
  - **pen_enhanced_text_text**: Displays enhanced text with hover-over tooltip for full text
- **NSPopUpButton**: Dropdowns for prompts and providers
- **NSButton**: Paste, enhance, and manual-send buttons
- **CustomSwitch**: `pen_footer_auto_switch_button` for mode switching

## 8. Error Handling

### 8.1 Error Types

| Error Type | Description | Handling Strategy |
|------------|-------------|-------------------|
| `WindowCreationError` | Failed to create window | Log error and show default window |
| `PositioningError` | Failed to position window | Use default position |
| `DataLoadingError` | Failed to load data | Show error message and use defaults |
| `ClipboardError` | Failed to access clipboard | Show error message |
| `AIProcessingError` | Failed to process text | Show error message and clear enhanced text |

## 9. Performance Considerations

### 9.1 Optimization Strategies

1. **Lazy Loading**
   - Load UI components only when needed
   - Defer heavy operations until window is actually shown

2. **Caching**
   - Cache loaded prompts and AI configurations
   - Cache clipboard content to avoid repeated access

3. **Asynchronous Operations**
   - Load data asynchronously to avoid UI blocking
   - Process text enhancement in background thread

4. **Window State Management**
   - Save window state to avoid reinitialization
   - Restore previous state on window show

## 10. Conclusion

PenWindowService provides a comprehensive solution for managing all aspects of the Pen application window. By centralizing window-related functionality, it improves code organization, maintainability, and performance. The service is designed to be extensible, allowing for future features and enhancements while maintaining a clean architecture.
