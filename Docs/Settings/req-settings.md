# Pen Settings Feature

# User Story 0: Keep Pen Window Open When Settings Window Opens
As a Pen user, I want the Pen window to remain open when I open the Settings window, so that I can see the changes reflected in the Pen window immediately

Scenario: Keep Pen window open when Settings window opens
    Given Pen app is running
    AND Pen window is open
    When I open Settings window
    Then the Pen window should remain open
    And the Settings window should appear at the same position as the Pen window

## User Story 1

As a Pen user, I want to enter the Settings window by right-clicking the menubar icon, so that I can configure my app settings

### Acceptance Criteria

```gherkin
Scenario: User accesses Settings window via menubar icon
  Given the Pen app is running
  And the menubar icon is visible
  When the user right-clicks on the menubar icon
  Then a menu appears with a "Settings" option
  And when the user clicks the "Settings" option
  Then the Settings window opens

Scenario: Settings option is accessible in menubar menu
  Given the Pen app is running
  When the user right-clicks on the menubar icon
  Then the menu contains a "Settings" option
  And the "Settings" option has a keyboard shortcut "p"
```

## User Story 2: Real-time Settings Update

As a Pen user, I want the Pen window to update immediately when I change settings, so that I can see the effect of my changes without reopening the window

### Acceptance Criteria

```gherkin
Scenario: Language change updates Pen window
  Given the Settings window is open
  And the Pen window is open
  When the user changes the language in Settings
  Then the Pen window UI text updates immediately

Scenario: AI connection change updates Pen window dropdown
  Given the Settings window is open
  And the Pen window is open
  When the user adds/edits/deletes an AI connection
  Then the Pen window provider dropdown updates immediately

Scenario: Prompt change updates Pen window dropdown
  Given the Settings window is open
  And the Pen window is open
  When the user adds/edits/deletes a prompt
  Then the Pen window prompts dropdown updates immediately
```
