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
- **Rows**: 32px height each
- **Columns**:
  | Column | Width | Description |
  |--------|-------|-------------|
  | Name | 120px | Read-only, prompt name |
  | Prompt | 380px | Read-only, prompt text (truncated with "...") |

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

#### Buttons
- **Position**: Bottom right corner
- **Size**: 100 x 32 each
- **Spacing**: 20px between buttons
- **Background**: White
- **Borders**:
  - Cancel: Gray border
  - Delete: Red border, red text (only visible in edit mode)
  - Save: Green border
- **Button Layout**:
  - **New Prompt Mode**: Cancel, Save (no gap, right-aligned)
  - **Edit Prompt Mode**: Cancel, Delete, Save (evenly spaced, right-aligned)
- **Positions**:
  - **New Prompt Mode**:
    - Cancel: (windowWidth - 220, 20)
    - Save: (windowWidth - 100, 20)
  - **Edit Prompt Mode**:
    - Cancel: (windowWidth - 340, 20)
    - Delete: (windowWidth - 220, 20)
    - Save: (windowWidth - 100, 20)

### 2.3 Typography
- **Headings**: Bold system font, 16-18pt
- **Labels**: System font, 14pt
- **Small Text**: System font, 12pt
- **Input Fields**: System font, 14pt

### 2.4 Behavior
- **Modal Window**: NewOrEditPrompt opens as a modal window, blocking interaction with other windows
- **Window Positioning**: NewOrEditPrompt positions itself at the same position as the Settings window
- **Text Truncation**: Prompt text is truncated with "..." for readability in table
- **Tooltips**: Full text is shown on hover for truncated fields
- **Popup Messages**: Used for user feedback on actions
- **Delete Confirmation**: Required for deleting prompts to prevent accidental actions
- **Cancel Button**: Closes window without popup message (consistent with AI Configuration tab)
- **Delete Button**: Only visible in edit mode, shows confirmation dialog before deleting

## 3. Delete Confirmation Dialog

### 3.1 Layout
- **Window Size**: 238 x 100
- **Style**: Borderless window
- **Background**: White (#FFFFFF)
- **Positioning**: Centered in NewOrEditPrompt window (edit window)

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
- **Positioning**: Centered in NewOrEditPrompt window
- **Cancel**: Closes dialog, keeps edit window open
- **Delete**: Closes dialog, closes edit window, deletes prompt, shows success message

## 4. Internationalization
- All text elements use LocalizationService for i18n support
- English and Chinese (Simplified) localizations provided
- Key localization strings include:
  - "first_prompt_default"
  - "prompt_name_column"
  - "prompt_text_column"
  - "new_prompt_title"
  - "edit_prompt_title"
  - "prompt_name_label"
  - "enter_prompt_name_placeholder"
  - "prompt_label"
  - "save_button"
  - "cancel_button"
  - "delete_button"
  - "prompt_created_successfully"
  - "prompt_updated_successfully"
  - "prompt_deleted_successfully"
  - "are_you_sure"
  - "cannot_delete_last_prompt"

## 5. Behavior
- **Modal Window**: NewOrEditPrompt opens as a modal window, blocking interaction with other windows
- **Window Positioning**: NewOrEditPrompt positions itself at the same position as the Settings window
- **Text Truncation**: Prompt text is truncated with "..." for readability in table
- **Tooltips**: Full text is shown on hover for truncated fields
- **Popup Messages**: Used for user feedback on actions
- **Delete Confirmation**: Required for deleting prompts to prevent accidental actions
- **Cancel Button**: Closes window without popup message (consistent with AI Configuration tab)
- **Delete Button**: Only visible in edit mode, shows confirmation dialog before deleting

## 6. Consistency with AI Connections Tab
Both Prompts tab and AI Connections tab follow the same design patterns:
- **Table Structure**: 2 columns (Name 120px, Content 380px)
- **Double-click to Edit**: Double-click on row opens edit window
- **Delete in Edit Window**: Delete button is in edit window, not in table
- **Cancel Behavior**: Cancel button closes window without popup message
- **Delete Confirmation**: Centered in edit window when deleting
- **Button Layout**: Cancel, Delete (edit mode only), Save
- **Window Management**: Only one edit window can be open at a time
- **Window Positioning**: Edit window opens at same position as Settings window
