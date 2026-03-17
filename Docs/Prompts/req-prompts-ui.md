# Prompts UI Design Specification

## Overview
This document outlines the UI design specifications for the Prompts tab and related components in the Pen AI application. The design follows the same style and patterns as the AI Configuration tab to ensure consistency across the application.

## 1. PromptsTabView

### 1.1 Layout
- **Container**: NSView with white background
- **Size**: 680x520 (matches Preferences window size)
- **Padding**: 20px margins on all sides

### 1.2 UI Elements

#### User Label
- **Position**: (20, windowHeight - 92)
- **Size**: (windowWidth - 40, 24)
- **Text**: "Predefined Prompts"
- **Font**: Bold system font, 16pt
- **Alignment**: Left

#### Default Label
- **Position**: (20, windowHeight - 108)
- **Size**: (windowWidth - 40, 16)
- **Text**: "First prompt will be the default prompt"
- **Font**: System font, 12pt
- **Color**: Secondary label color
- **Alignment**: Left

#### Table Container
- **Position**: (20, 50)
- **Size**: (windowWidth - 40, windowHeight - 166)
- **Border**: 1px light gray (0.5 alpha)
- **Corner Radius**: 8px
- **Background**: White

#### Table View
- **Size**: Fills table container
- **Border**: 1px light gray (0.3 alpha)
- **Rows**: 70px height each
- **Columns**:
  | Column | Width | Description |
  |--------|-------|-------------|
  | Prompt Name | Full width | Read-only, trimmed to 1 line |

#### Double-Click Behavior
- **Action**: Double-click on row opens NewOrEditPrompt window with existing prompt data
- **Requirement**: Only one NewOrEditPrompt window can be open at a time

#### New Button
- **Position**: (20, 10)
- **Size**: (88, 32)
- **Text**: "New"
- **Font**: System font, 14pt
- **Background**: White
- **Border**: 1px green, rounded corners (6px)
- **Action**: Opens NewOrEditPrompt window for creating a new prompt

## 2. NewOrEditPrompt Window

### 2.1 Layout
- **Window Size**: 600 x 518
- **Style**: Borderless window with custom title bar
- **Background**: White (#FFFFFF)
- **Positioning**: Opens at the same position as the originating window

### 2.2 UI Elements

#### Title
- **Position**: (70, windowHeight - 55)
- **Size**: (windowWidth - 90, 30)
- **Text**: "New Prompt" or "Edit Prompt"
- **Font**: Bold system font, 18pt
- **Alignment**: Left

#### Prompt Name Input
- **Position**: (40, windowHeight - 102)
- **Size**: (windowWidth - 80, 24)
- **Background**: Light gray (0.1 alpha)
- **Border**: 1px light gray (0.5 alpha), rounded corners (4px)
- **Placeholder**: "Enter prompt name"

#### Prompt Text Area
- **Position**: (40, 64)
- **Size**: (520, 338)
- **Background**: Light gray (0.1 alpha)
- **Border**: 1px light gray (0.5 alpha), rounded corners (4px)
- **Placeholder**: "Markdown format recommended"
- **Font**: System font, 14pt
- **Scrollable**: Vertical scroller auto-shown for overflow text

#### Default Prompt Checkbox
- **Position**: (40, 26)
- **Size**: (200, 32)
- **Text**: "Set as default prompt"
- **Style**: Checkbox (switch button)
- **Default State**: Off

#### Buttons
- **Position**: Bottom right corner
- **Size**: 68 x 32 each
- **Spacing**: 20px between buttons
- **Background**: White
- **Borders**:
  - Delete: Red border (only visible in edit mode)
  - Cancel: Gray border
  - Save: Green border
- **Buttons**:
  - **Delete**: (x, 26) - Red border, red text - only visible when editing existing prompt
  - **Cancel**: (x, 26) - Gray border
  - **Save**: (x, 26) - Green border

### 2.3 Typography
- **Headings**: Bold system font, 16-18pt
- **Labels**: System font, 14pt
- **Small Text**: System font, 12pt
- **Input Fields**: System font, 14pt

### 2.4 Behavior
- **Modal Window**: NewOrEditPrompt opens as a modal window, blocking interaction with other windows
- **Window Positioning**: NewOrEditPrompt positions itself relative to the originating window
- **Text Truncation**: Prompt text is trimmed to 3 lines with "..." for readability
- **Tooltips**: Full text is shown on hover for truncated fields
- **Popup Messages**: Used for user feedback on actions
- **Delete Confirmation**: Required for deleting prompts to prevent accidental actions

## 3. Delete Confirmation Dialog

### 3.1 Layout
- **Window Size**: 238 x 100
- **Style**: Borderless window
- **Background**: White (#FFFFFF)
- **Positioning**: Opens near mouse cursor

### 3.2 UI Elements

#### Title
- **Position**: (20, 60)
- **Size**: (198, 20)
- **Text**: "Are you sure?"
- **Font**: Bold system font, 16pt
- **Alignment**: Center

#### Buttons
- **Cancel Button**:
  - **Position**: (41, 20)
  - **Size**: (68, 32)
  - **Text**: "Cancel"
  - **Border**: Gray border, rounded corners (6px)
- **Delete Button**:
  - **Position**: (129, 20)
  - **Size**: (68, 32)
  - **Text**: "Delete"
  - **Border**: Red border, rounded corners (6px)
  - **Text Color**: Red

### 3.3 Behavior
- **Triggered**: When Delete button is clicked in NewOrEditPrompt window
- **Positioning**: Opens at mouse cursor position + 6px offset
- **Cancel**: Closes dialog, keeps edit window open
- **Delete**: Closes dialog, closes edit window, deletes prompt, shows success message

## 4. Internationalization
- All text elements use LocalizationService for i18n support
- English and Chinese (Simplified) localizations provided
- Key localization strings include:
  - "first_prompt_default"
  - "prompt_name_column"
  - "new_prompt_title"
  - "edit_prompt_title"
  - "prompt_name_label"
  - "enter_prompt_name_placeholder"
  - "prompt_label"
  - "save_button"
  - "cancel_button"
  - "delete_button"
  - "create_new_prompt_canceled"
  - "edit_prompt_canceled"
  - "prompt_created_successfully"
  - "prompt_updated_successfully"
  - "prompt_deleted_successfully"
  - "are_you_sure"
  - "cannot_delete_last_prompt"

## 5. Behavior
- **Modal Window**: NewOrEditPrompt opens as a modal window, blocking interaction with other windows
- **Window Positioning**: NewOrEditPrompt positions itself relative to the originating window
- **Text Truncation**: Prompt text is trimmed to 3 lines with "..." for readability
- **Tooltips**: Full text is shown on hover for truncated fields
- **Popup Messages**: Used for user feedback on actions
- **Delete Confirmation**: Required for deleting prompts to prevent accidental actions
- **Cancel Button**: Closes window without popup message (consistent with AI Configuration tab)

## 6. Consistency
- Follows the same design patterns as AIConfigurationTabView
- Uses the same button styles, sizes, and positioning
- Maintains consistent spacing and alignment across components
- Shares the same modal window behavior and popup message system
- Double-click to edit (consistent with AI Configuration tab)
- Delete button in edit window (consistent with AI Configuration tab)
- Cancel button closes without popup (consistent with AI Configuration tab)
