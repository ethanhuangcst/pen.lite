# Feature: Prompt Management

## User Story 1: Default Prompt for All Users
As a Pen user
I want a default prompt to be available when I first launch the app
So that I have a starting point for AI interactions without needing to create my own prompt

### Acceptance Criteria

Scenario: Default Prompts are loaded from Resources/prompts folder
  Given the application is running for the first time
  And Resources/prompts folder exists with default prompt JSON files
  When the application initializes
  Then it should load all default prompts from Resources/prompts folder
  And each prompt should have a unique ID
  And one prompt should be marked as default
  And the prompts should be stored in ~/Library/Application Support/Pen.Lite/prompts/

Scenario: Default Prompts are created on first launch
  Given the application is running for the first time
  And the prompts folder does not exist
  When the application initializes
  Then the system should automatically create the default prompts
  And the prompts should be stored in ~/Library/Application Support/Pen.Lite/prompts/

## User Story 2: Last Prompt Protection
As a Pen user
I want to ensure at least one prompt always remains in the system
So that I always have a prompt available for AI interactions

### Acceptance Criteria

Scenario: Last prompt cannot be deleted from edit window
  Given the user is using the app
  And the user navigates to Settings - Prompts tab
  And there is only one prompt in the list
  And the user opens the Edit Prompt window for that prompt
  When the user clicks the Delete button
  Then an error message should appear indicating "Cannot delete the last prompt"
  And the prompt should not be deleted
  And the Edit Prompt window should remain open

Scenario: Delete button in edit window is enabled when multiple prompts exist
  Given the user is using the app
  And the user navigates to Settings - Prompts tab
  And there are multiple prompts in the list
  And the user opens the Edit Prompt window
  When the edit window loads
  Then the Delete button should be enabled

Scenario: Delete button becomes disabled after deleting prompts until only one remains
  Given the user is using the app
  And the user navigates to Settings - Prompts tab
  And there are two prompts in the list
  When the user deletes one prompt from the edit window
  Then the remaining prompt's delete button in edit window should show error when clicked
  And an error message should appear indicating "Cannot delete the last prompt"

## User Story 3: Edit Prompt via Double-Click
As a Pen user
I want to edit a prompt by double-clicking it
So that I can modify the prompt details

### Acceptance Criteria

Scenario: Open edit window on double-click
  Given the user is using the app
  And the user navigates to Settings - Prompts tab
  And there is at least one prompt in the list
  When the user double-clicks on a row
  Then the Settings window is hidden
  And an edit window appears at the exact same position as the Settings window
  And the edit window contains the prompt data pre-filled with current values
  And only one edit window can be open at a time

Scenario: Cancel edit without saving
  Given the edit window is open
  And the user has modified some fields
  When the user clicks the Cancel button
  Then the edit window closes
  And the Settings window is restored at the same position
  And no changes are saved
  And no popup message is displayed

Scenario: Delete prompt from edit window
  Given the edit window is open for an existing prompt
  And there are multiple prompts in the list
  When the user clicks the Delete button
  Then a confirmation dialog appears
  And the dialog has Cancel and Delete buttons
  And the Delete button has a red border

Scenario: Confirm delete from edit window
  Given the delete confirmation dialog is open
  When the user clicks the Delete button
  Then the prompt is deleted
  And the edit window closes
  And the Settings window is restored
  And a success message is displayed

Scenario: Cancel delete from edit window
  Given the delete confirmation dialog is open
  When the user clicks the Cancel button
  Then the dialog closes
  And the edit window remains open

Scenario: Cannot delete last prompt from edit window
  Given the edit window is open for an existing prompt
  And there is only one prompt in the list
  When the user clicks the Delete button
  Then an error message should appear indicating "Cannot delete the last prompt"
  And the prompt should not be deleted
  And the edit window should remain open

## Technical Requirements

1. **Prompt Storage**: Prompts are stored as JSON files in ~/Library/Application Support/Pen.Lite/prompts/
2. **Default Prompts**: Default prompts are loaded from Resources/prompts/ during initialization
3. **UI Behavior**: 
   - Table has 2 columns: Name (120px) | Prompt (380px)
   - Double-click on row opens edit window
   - Delete button is in edit window (not in table)
   - Cancel button closes window without popup message
   - Delete confirmation dialog is centered in edit window
   - Button layout in edit window: Cancel, Delete (edit mode only), Save
4. **Error Handling**: Attempts to delete the last prompt should be rejected with an appropriate error message
5. **New User Onboarding**: Default prompts should be automatically created on first launch
6. **Window Management**: Only one edit window can be open at a time
7. **Consistency**: Prompts tab follows the same design patterns as AI Connections tab

## Prompt File Format (JSON)

```json
{
  "id": "unique-prompt-id",
  "promptName": "Prompt Name",
  "promptText": "The actual prompt content...",
  "createdDatetime": "2026-03-12T00:00:00Z",
  "updatedDatetime": null,
  "systemFlag": "PEN",
  "isDefault": true
}
```

## Out of Scope

- Bulk delete operations
- Prompt versioning
- Prompt sharing between users
