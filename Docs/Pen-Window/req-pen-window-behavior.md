# Pen Window Behavior

## Feature: Pen Window Access and Positioning

The Pen window opens when the app is in online mode, and it opens in different positions based on how it's accessed (menubar click).

## Window Size

- **Width**: 378px
- **Height**: 388px
- **Resizable**: No (fixed size)

## User Stories and Acceptance Criteria

### User Story 1: Window Opening via Menubar

**As a user**, I want to open the Pen window by left-clicking on the menubar icon,
**So that** I can quickly access the app.

#### Acceptance Criteria

**Scenario: Toggling window visibility via menubar click**
  Given the app is in online mode
  And the Pen window is closed
  When I left-click the menubar icon
  Then the Pen window opens

**Scenario: Closing window via menubar click**
  Given the app is in online mode
  And the Pen window is open
  When I left-click the menubar icon
  Then the Pen window closes

**Scenario: Preventing window access when app is in offline mode**
  Given the app is in offline mode
  When I left-click the menubar icon
  Then the Pen window does not open
  And a reload option is displayed

### User Story 2: Window Positioning for Menubar Access

**As a user**, I want the Pen window to open at a standard position relative to the menubar icon when accessed via left-click,
**So that** I always know where to find the window.

#### Acceptance Criteria

**Scenario: Window positioning relative to menubar icon**
  Given the app is in online mode
  And the Pen window is closed
  When I left-click the menubar icon
  Then the Pen window opens 6px to the right and 6px below the menubar icon
  And the window position is consistent regardless of where the menubar icon is located
  And the window position is not affected by the current mouse cursor position

### User Story 3: Popup Message Positioning

**As a user**, I want popup messages to appear near my current mouse cursor position,
**So that** I can see them easily while working.

#### Acceptance Criteria

**Scenario: Default popup message displayed position**
  Given the Pen app is running
  When a popup message is displayed
  Then it should be positioned at:
  - X position = X position of the mouse cursor + 6px
  - Y position = Y position of the mouse cursor + 6px

### User Story 4: Paste Button Behavior

**As a user**, I want the paste button to work correctly in both auto and manual modes,
**So that** I can easily paste content from clipboard regardless of my preferred input mode.

#### Acceptance Criteria

**Scenario: Paste in auto mode**
  Given the app is in auto mode (auto copy clipboard = ON)
  When I click the "paste from clipboard" button
  Then the content is pasted from clipboard
  And the enhancement is automatically triggered

**Scenario: Paste in manual mode**
  Given the app is in manual mode (auto copy clipboard = OFF)
  When I click the "paste from clipboard" button
  Then the content is pasted from clipboard to the manual input field
  And the enhancement is NOT automatically triggered
  And I can edit the text before manually triggering enhancement

**Scenario: Copy refined content**
  Given refined content is displayed in the enhanced text field
  When I click on the refined content
  Then the full refined content is copied to clipboard
  And a confirmation message is displayed
