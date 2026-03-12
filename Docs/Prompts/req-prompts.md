# Feature: Prompt Management

## User Story 1: Default Prompt for All Users
As a Pen user
I want a default prompt to be available for all users
So that I have a starting point for AI interactions without needing to create my own prompt

### Acceptance Criteria

Scenario: Default Prompt is loaded from Resources/prompts folder
  Given the application is running
  And Resources/prompts folder exists with default prompt JSON files
  When the application initializes
  Then it should load all default prompts from Resources/prompts folder
  And each prompt should have a unique ID
  And one prompt should be marked as default

Scenario: Default Prompt is created when registering a new user
  Given the user is not logged in
  And the user is on the new User Registration screen
  When the user successfully completed the registration
  Then the system should automatically create the default prompts for the user
  And the prompts should be stored in ~/Library/Application Support/Pen.Lite/prompts/

## User Story 2: Last Prompt Protection
As a Pen user
I want to ensure at least one prompt always remains in the system
So that I always have a prompt available for AI interactions

### Acceptance Criteria

Scenario: Last prompt cannot be deleted
  Given the user is logged in
  And the user navigates to Preferences - Prompts tab
  And there is only one prompt in the list
  When the prompts list loads
  Then the delete button for the last prompt should be disabled
  And mouse hover over the delete button should show a tooltip indicating "Cannot delete the last prompt"

Scenario: Delete button is enabled when multiple prompts exist
  Given the user is logged in
  And the user navigates to Preferences - Prompts tab
  And there are multiple prompts in the list
  When the prompts list loads
  Then the delete button for each prompt should be enabled

Scenario: Delete button becomes disabled after deleting prompts until only one remains
  Given the user is logged in
  And the user navigates to Preferences - Prompts tab
  And there are two prompts in the list
  When the user deletes one prompt
  Then the remaining prompt's delete button should become disabled
  And a tooltip should appear on hover indicating "Cannot delete the last prompt"

Scenario: Attempting to delete last prompt from Edit window shows error
  Given the user is logged in
  And the user navigates to Preferences - Prompts tab
  And there is only one prompt in the list
  And the user opens the Edit Prompt window for that prompt
  When the user clicks the Delete button
  Then an error message should appear indicating "Cannot delete the last prompt"
  And the prompt should not be deleted
  And the Edit Prompt window should remain open

Scenario: Edit button is always enabled for any prompt
  Given the user is logged in
  And the user navigates to Preferences - Prompts tab
  And there is at least one prompt in the list
  When the prompts list loads
  Then the edit button for each prompt should be enabled

## Technical Requirements

1. **Prompt Storage**: Prompts are stored as JSON files in ~/Library/Application Support/Pen.Lite/prompts/
2. **Default Prompts**: Default prompts are loaded from Resources/prompts/ during initialization
3. **UI Behavior**: 
   - Delete button for the last prompt should be disabled
   - Tooltip should indicate "Cannot delete the last prompt" on hover
   - Edit button should always be enabled
4. **Error Handling**: Attempts to delete the last prompt should be rejected with an appropriate error message
5. **New User Onboarding**: Default prompts should be automatically created for new users
6. **Fallback Mechanism**: If no prompts exist, a fallback prompt should be created

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
