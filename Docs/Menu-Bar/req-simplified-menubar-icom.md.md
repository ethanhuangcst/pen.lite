# Menu Bar Icon Feature - Simplified

## User Story 1: Load Menu Bar Icon on Launch

As a mac user, I want the Pen app to load the menu bar icon with appropriate behaviors on launch, so that I can interact with the app based on connectivity status.

### Acceptance Criteria

```gherkin
Scenario: Load menu bar icon in online mode when internet connectivity is available
  Given the Pen app is launching
  When the initialization process completes with internet connectivity available
  Then the Pen app runs in online mode
  AND a menu bar icon (icon.png) appears
  AND the icon is clickable
  AND wait until the menubar icon is fully loaded
  AND display a tooltip message "Hello, I'm Pen, your AI writing assistant."
  AND the tooltip message fades out after 2 seconds
  AND left click the icon opens the Pen window
  AND right click the icon displays a dropdown menu with Settings and Exit

Scenario: Load menu bar icon in offline mode when internet connectivity is unavailable
  Given the Pen app is launching
  When the initialization process completes without internet connectivity
  Then the Pen app runs in offline mode
  AND a menu bar icon (icon_offline.png) appears
  AND the icon is clickable
  AND wait until the menubar icon is fully loaded
  AND display a tooltip message "No internet connection available"
  AND the tooltip message fades out after 2 seconds
  AND left click the icon displays Reload and Exit options
  AND right click the icon displays Reload and Exit options

Scenario: Reload initialization process from offline mode
  Given the Pen app is running in offline mode
  When the user clicks Reload
  Then the initialization process restarts
  AND the app mode updates based on new connectivity status
```

## User Story 2: Menu Bar Icon Interactions

As a mac user, I want to interact with the menu bar icon to access app features, so that I can use the app efficiently.

### Acceptance Criteria

```gherkin
Scenario: Open Pen window from menu bar icon in online mode
  Given the Pen app is running in online mode
  When the user left clicks the menu bar icon
  Then the Pen window opens

Scenario: Access settings from menu bar icon in online mode
  Given the Pen app is running in online mode
  When the user right clicks the menu bar icon
  AND selects Settings
  Then the Settings window opens

Scenario: Exit app from menu bar icon
  Given the Pen app is running
  When the user right clicks the menu bar icon
  AND selects Exit
  Then the app closes

Scenario: Access reload option from menu bar icon in offline mode
  Given the Pen app is running in offline mode
  When the user clicks the menu bar icon
  Then Reload and Exit options are displayed
```
