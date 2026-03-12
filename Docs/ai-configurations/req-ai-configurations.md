-----------------
AI Connection Management
-----------------

## Overview

AI configurations are stored locally in the user's Application Support directory:
- Location: `~/Library/Application Support/Pen.Lite/config/ai-connections.json`
- Format: JSON array of AIConnectionModel objects
- No database or authentication required

## Data Model

### AIConnectionModel

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique UUID identifier |
| `apiProvider` | `String` | Provider name (user-defined, e.g., "OpenAI", "DeepSeek", "Qwen") |
| `apiKey` | `String` | API key for authentication |
| `apiUrl` | `String` | Base URL for the API endpoint |
| `model` | `String` | Model name to use |
| `isDefault` | `Bool` | Whether this is the default configuration |

### Default Configurations

On first launch, if no configuration file exists, the app creates 3 default configurations:
1. Qwen (default)
2. OpenAI
3. DeepSeek

---

## User Story ID: US-001
As a Pen user, I want to view all my AI connections in a read-only table, so that I can see my configurations at a glance.

//DONE
### Acceptance Criteria ID: US-001-001
Scenario: Display AI connections in read-only table
```gherkin
Given the app is running
And the user has AI configurations stored locally
When the user navigates to Settings → AI Connections tab
Then all AI configurations are displayed in a table
And the table shows the following columns:
  | Column | Content |
  |--------|---------|
  | Provider | Provider name (read-only) |
  | API Key | Full API key displayed (read-only) |
  | Delete | Delete button |
And the table supports scrolling if there are more configurations than fit on screen
```

---

## User Story ID: US-002
As a Pen user, I want to edit an AI connection by double-clicking it, so that I can modify the configuration details.

//DONE
### Acceptance Criteria ID: US-002-001
Scenario: Open edit window on double-click
```gherkin
Given the app is running
And the user is on the AI Connections tab
And there is at least one AI configuration in the table
When the user double-clicks on a row
Then the Settings window is hidden
And an edit window appears at the exact same position as the Settings window
And the edit window has the same size as the Settings window (680x520)
And the edit window inherits from BaseWindow for standard behaviors
And the window contains the following fields pre-filled with current values:
  | Field | Type | Description |
  |-------|------|-------------|
  | Provider Name | Text Input | Current provider name |
  | API Key | Text Input | Current API key (visible) |
  | Base URL | Text Input | Current API URL |
  | Model | Text Input | Current model name |
And the window contains the following buttons:
  | Button | Action |
  |--------|--------|
  | Cancel | Close window without saving |
  | Test & Save | Test connection and save if successful |
  | Delete | Delete this configuration |
And only one edit window can be open at a time
```

### Acceptance Criteria ID: US-002-002
Scenario: Cancel edit without saving
```gherkin
Given the edit window is open
And the user has modified some fields
When the user clicks the Cancel button
Then the edit window closes
And the Settings window is restored at the same position
And no changes are saved
And the table displays the original values
```

---

## User Story ID: US-003
As a Pen user, I want to test and save AI connection changes, so that I can ensure my configuration works before saving.

//DONE
### Acceptance Criteria ID: US-003-001
Scenario: Test & Save - success
```gherkin
Given the edit window is open
And the user has entered valid configuration values
When the user clicks the Test & Save button
Then AIManager.testConnectionWithValues() is called with the configuration
And a popup message displays "Testing [Provider]..."
When the test returns success
Then the configuration is saved to the local file
And a success popup message displays "AI Connection test passed! Configuration saved."
And the edit window closes after 2 seconds
And the Settings window is restored at the same position
And the table refreshes to show the updated values
And the terminal prints "$$$$$$$$$$$$$$$$$$$$ AI Connection [Provider] saved! $$$$$$$$$$$$$$$$$$$$"
```

### Acceptance Criteria ID: US-003-002
Scenario: Test & Save - failure
```gherkin
Given the edit window is open
And the user has entered configuration values
When the user clicks the Test & Save button
Then AIManager.testConnectionWithValues() is called with the configuration
And a popup message displays "Testing [Provider]..."
When the test returns failure
Then an error popup message displays "AI Connection test failed! [error message]"
And the edit window remains open
And the configuration is NOT saved
And the terminal prints "$$$$$$$$$$$$$$$$$$$$ AI Connection test failed $$$$$$$$$$$$$$$$$$$$"
```

---

## User Story ID: US-004
As a Pen user, I want to add a new AI connection, so that I can use a new AI provider.

//DONE
### Acceptance Criteria ID: US-004-001
Scenario: Add new AI connection
```gherkin
Given the app is running
And the user is on the AI Connections tab
When the user clicks the New button
Then the Settings window is hidden
And the edit window opens at the same position with empty fields:
  | Field | Placeholder |
  |-------|-------------|
  | Provider Name | "Enter provider name" |
  | API Key | "Enter API key" |
  | Base URL | "https://api.example.com/v1" |
  | Model | "Enter model name" |
And the edit window has the same size as the Settings window (680x520)
```

---

## User Story ID: US-005
As a Pen user, I want to delete an AI connection, so that I can remove unused configurations.

//DONE
### Acceptance Criteria ID: US-005-001
Scenario: Delete AI connection - with confirmation
```gherkin
Given the app is running
And the user is on the AI Connections tab
And there are more than 1 AI configurations
When the user clicks the Delete button on a row
Then a confirmation popup appears centered in the edit window (if open) or Settings window
And the popup has Cancel and Delete buttons
When the user clicks Delete
Then the configuration is removed from the local file
And the edit window closes (if open)
And the Settings window is restored
And the table refreshes without the deleted row
And a popup message displays "AI Connection deleted successfully!"
And the terminal prints "$$$$$$$$$$$$$$$$$$$$ AI Configuration [Provider] deleted! $$$$$$$$$$$$$$$$$$$$"
```

### Acceptance Criteria ID: US-005-002
Scenario: Delete AI connection - cancel
```gherkin
Given the delete confirmation popup is open
When the user clicks the Cancel button
Then the popup closes
And the configuration is NOT deleted
And the table remains unchanged
And the edit window remains open (if it was open)
```

### Acceptance Criteria ID: US-005-003
Scenario: Cannot delete last AI configuration
```gherkin
Given the app is running
And the user is on the AI Connections tab
And there is exactly 1 AI configuration
When the user clicks the Delete button
Then a popup message displays "Cannot delete the last AI configuration. At least one configuration is required."
And the configuration is NOT deleted
```

---

## User Story ID: US-006
As a Pen user, I want default AI configurations created on first launch, so that I can start using the app immediately.

//DONE
### Acceptance Criteria ID: US-006-001
Scenario: Create default configurations on first launch
```gherkin
Given the app is launching for the first time
And the configuration file does not exist at ~/Library/Application Support/Pen.Lite/config/ai-connections.json
When the initialization process runs
Then a new configuration file is created
And the file contains 3 default configurations:
  | Provider | API URL | Model | Default |
  |----------|---------|-------|---------|
  | Qwen | https://dashscope.aliyuncs.com/compatible-mode/v1 | qwen-plus | Yes |
  | OpenAI | https://openaiss.com/v1 | gpt-5.2-all | No |
  | DeepSeek | https://api.deepseek.com/v1 | deepseek-chat | No |
And the terminal prints "InitializationService: Default AI configurations created successfully"
```

### Acceptance Criteria ID: US-006-002
Scenario: Skip default creation if file exists
```gherkin
Given the app is launching
And the configuration file already exists at ~/Library/Application Support/Pen.Lite/config/ai-connections.json
When the initialization process runs
Then no new default configurations are created
And the existing configurations are loaded
And the terminal prints "InitializationService: AI configurations file already exists, skipping default creation"
```

---

## Technical Notes

### File Storage
- Service: `FileStorageService`
- Location: `~/Library/Application Support/Pen.Lite/`
- Config file: `config/ai-connections.json`

### Services
- `AIConnectionService`: Manages CRUD operations for AI configurations
- `AIManager`: Handles AI API calls and connection testing
- `InitializationService`: Creates default configurations on first launch

### Window Management
- `EditAIConnectionWindow`: Inherits from BaseWindow
- Size: 680x520 (same as Settings window)
- Position: Same as Settings window position
- Behavior: Settings window hidden when edit window opens
- Single instance: Only one edit window can be open at a time

### Validation Rules
1. At least 1 AI configuration must exist at all times
2. Provider name is user-defined (not a fixed dropdown)
3. API key must be non-empty to enable Test & Save
4. Connection test must pass before saving
