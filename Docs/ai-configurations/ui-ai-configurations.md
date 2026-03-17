# AI Configurations UI Design Specification

## Overview
This document outlines the UI design specifications for the AI Configurations tab and related components in the Pen.Lite application. The design follows the same style and patterns as the Prompts tab to ensure consistency across the application.

## 1. AIConfigurationTabView

### 1.1 Layout
- **Container**: NSView with white background
- **Size**: 680x520 (matches Settings window size)
- **Padding**: 20px margins on all sides

### 1.2 UI Elements

#### User Label
- **Position**: (20, windowHeight - 92)
- **Size**: (windowWidth - 40, 24)
- **Text**: "AI Connections"
- **Font**: Bold system font, 16pt
- **Alignment**: Left

#### Default Label
- **Position**: (20, windowHeight - 108)
- **Size**: (windowWidth - 40, 16)
- **Text**: "The first connection will be used as default."
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
  | Column | Width | Min/Max Width | Description |
  |--------|-------|---------------|-------------|
  | Provider | 120px | 120px | Read-only, text selectable for copying |
  | API Key | 380px | 380px | Read-only, full API key displayed |
  | Delete | 60px | 60px | Delete button |

#### Delete Button
- **Size**: 20x20px
- **Position**: Centered in delete column
- **Icon**: delete.svg (18x18px)
- **Color**: System red
- **Behavior**: Shows delete confirmation dialog

#### New Button
- **Position**: (20, 10)
- **Size**: 88x32px
- **Text**: "New"
- **Style**: Rounded bezel, 1px green border, 6px corner radius
- **Behavior**: Opens EditAIConnectionWindow with empty fields

### 1.3 Delete Confirmation Dialog
- **Size**: 238x100px
- **Style**: Borderless window, white background, 12px corner radius
- **Shadow**: Black with 0.3 alpha, 3px offset, 8px blur
- **Position**: Centered in EditAIConnectionWindow (if open) or Settings window
- **Title**: "Are you sure?"
- **Buttons**:
  - **Cancel**: (41, 20), 68x32px, gray border
  - **Delete**: (129, 20), 68x32px, red border, red text
- **Behavior**: Closes dialog and deletes configuration when Delete is clicked

### 1.4 Double-Click Behavior
- **Action**: Opens EditAIConnectionWindow with existing configuration data
- **Requirement**: Only one EditAIConnectionWindow can be open at a time

## 2. EditAIConnectionWindow

### 2.1 Window Properties
- **Class**: BaseWindow subclass
- **Size**: 680x520 (exactly same as Settings window)
- **Style**: Titled with fullSizeContentView (title bar hidden but keyboard input enabled)
- **Title Bar**: Transparent and hidden
- **Level**: Modal panel (stays above all other windows)
- **Behavior**: Single instance only - if already open, bring to front instead of creating new

### 2.2 Window Positioning
- **Position**: Exactly same position as Settings window
- **Behavior**: Hides Settings window when opened
- **On Close**: Restores Settings window visibility

### 2.3 UI Elements

#### Title Label
- **Position**: (20, windowHeight - 40)
- **Size**: (windowWidth - 40, 24)
- **Text**: "Edit AI Connection"
- **Font**: Bold system font, 16pt
- **Alignment**: Center

#### Close Button (X)
- **Position**: (windowWidth - 35, windowHeight - 35)
- **Size**: 20x20px
- **Icon**: "×" character
- **Font**: Bold system font, 18pt
- **Behavior**: Closes window without saving

#### Form Fields
| Field | Label Position | Field Position | Field Size | Placeholder |
|-------|----------------|----------------|------------|-------------|
| Provider Name | (20, startY) | (120, startY) | (300, 24) | "Enter provider name" |
| API Key | (20, startY - 60) | (120, startY - 60) | (300, 44) | "Enter API key" |
| Base URL | (20, startY - 120) | (120, startY - 120) | (300, 44) | "https://api.example.com/v1" |
| Model | (20, startY - 180) | (120, startY - 180) | (300, 24) | "Enter model name" |

- **startY**: windowHeight - 80
- **Label Width**: 100px
- **Field Width**: 300px
- **Large Fields**: API Key and Base URL use 44px height

#### Field Styling
- **Background**: Light gray (0.1 alpha)
- **Border**: 1px separator color (0.5 alpha), 4px corner radius
- **Font**: System font, 12-13pt
- **Line Break**: Truncating middle for long values

#### Buttons
| Button | Position | Size | Style | Behavior |
|--------|----------|------|-------|----------|
| Cancel | (20, 20) | 100x32px | Rounded bezel, gray border | Closes window without saving |
| Test & Save | (140, 20) | 140x32px | Rounded bezel, green border | Tests connection, saves on success |
| Delete | (windowWidth - 120, 20) | 100x32px | Rounded bezel, red border, red text | Shows delete confirmation |

### 2.4 Validation Rules
- **Provider Name**: Required, cannot be empty
- **API Key**: Required, cannot be empty
- **Base URL**: Required, cannot be empty, must be valid URL
- **Model**: Required, cannot be empty

### 2.5 Test & Save Behavior
1. Validate all fields
2. Show "Testing [Provider]..." popup message
3. Call AIManager.testConnectionWithValues()
4. **On Success**:
   - Save configuration to local file
   - Show "AI Connection test passed! Configuration saved." popup
   - Wait 2 seconds
   - Close EditAIConnectionWindow
   - Restore Settings window
   - Refresh table
   - Print: "$$$$$$$$$$$$$$$$$$$$ AI Connection [Provider] saved! $$$$$$$$$$$$$$$$$$$$"
5. **On Failure**:
   - Show "AI Connection test failed! [error message]" popup
   - Keep window open
   - Do NOT save configuration
   - Print: "$$$$$$$$$$$$$$$$$$$$ AI Connection test failed $$$$$$$$$$$$$$$$$$$$"

### 2.6 Delete Behavior
1. Check if this is the last configuration
2. If last: Show "Cannot delete the last AI configuration" popup, do nothing
3. If not last: Show delete confirmation dialog centered in EditAIConnectionWindow
4. On confirm: Delete configuration, close EditAIConnectionWindow, restore Settings window

### 2.7 Cancel Behavior
- Closes EditAIConnectionWindow
- Restores Settings window visibility
- No changes saved

### 2.8 Popup Messages
| Key | English | Chinese |
|-----|---------|---------|
| testing_provider | "Testing %@..." | "正在测试 %@..." |
| ai_connection_test_passed | "AI Connection test passed! Configuration saved." | "AI 连接测试通过！配置已保存。" |
| ai_connection_test_failed | "AI Connection test failed!" | "AI 连接测试失败！" |
| cannot_delete_last_configuration | "Cannot delete the last AI configuration. At least one configuration is required." | "无法删除最后一个 AI 配置。至少需要一个配置。" |
| provider_name_required | "Provider name is required" | "提供商名称不能为空" |
| api_key_required | "API Key is required" | "API 密钥不能为空" |
| base_url_required | "Base URL is required" | "基础 URL 不能为空" |
| model_required | "Model is required" | "模型不能为空" |

## 3. Window Management

### 3.1 Single Window Instance
- **Rule**: Only one EditAIConnectionWindow can exist at a time
- **Implementation**: Use singleton pattern or window tracking
- **Behavior**: If user tries to edit another configuration while window is open, bring existing window to front and update its content

### 3.2 Window Visibility Flow
```
Settings Window (visible)
    ↓
User double-clicks row or clicks New
    ↓
Settings Window (hidden)
EditAIConnectionWindow (visible, same position)
    ↓
User clicks Cancel/Test & Save/Delete
    ↓
EditAIConnectionWindow (closed)
Settings Window (visible, same position)
```

### 3.3 BaseWindow Inheritance
- EditAIConnectionWindow inherits from BaseWindow
- Inherits standard behaviors:
  - Logo display
  - UI styling
  - Window positioning
  - Keyboard shortcuts
  - Focus management

## 4. Styling Guidelines

### 4.1 Colors
- **Background**: White (#FFFFFF)
- **Text**: System text color
- **Secondary Text**: Secondary label color
- **Borders**: Light gray (with alpha for subtlety)
- **Buttons**:
  - New: Green border
  - Test & Save: Green border
  - Delete: Red border and text
  - Cancel: Gray border

### 4.2 Typography
- **Headings**: Bold system font, 16pt
- **Labels**: System font, 13pt
- **Small Text**: System font, 12pt
- **Input Fields**: System font, 12-13pt

### 4.3 Icons
- **Delete**: delete.svg (18x18px)
- **Close (×)**: Text character, bold 18pt
- **No background** on buttons, just the icon

## 5. Internationalization
- All text elements use LocalizationService for i18n support
- English and Chinese (Simplified) localizations provided
- Key localization strings include:
  - "ai_connections_for"
  - "first_connection_default"
  - "provider_column"
  - "api_key"
  - "delete_column"
  - "new_button"
  - "edit_ai_connection"
  - "provider_name"
  - "base_url"
  - "model"
  - "test_and_save_button"
  - "cancel_button"
  - "delete_button"
  - "are_you_sure"
  - "cannot_delete_last_configuration"

## 6. Behavior Summary

| Action | Result |
|--------|--------|
| Double-click row | Open EditAIConnectionWindow (hide Settings) |
| Click New | Open EditAIConnectionWindow with empty fields (hide Settings) |
| Click Cancel | Close EditAIConnectionWindow, restore Settings |
| Click Test & Save (success) | Save, close window, restore Settings, refresh table |
| Click Test & Save (fail) | Show error, keep window open |
| Click Delete (not last) | Show confirmation centered in window |
| Click Delete (last) | Show error popup |
| Confirm delete | Delete, close window, restore Settings, refresh table |

## 7. Consistency with Prompts Tab
Both AI Connections tab and Prompts tab follow the same design patterns:
- **Table Structure**: 2 columns (Name/Provider 120px, Content/API Key 380px)
- **Double-click to Edit**: Double-click on row opens edit window
- **Delete in Edit Window**: Delete button is in edit window, not in table
- **Cancel Behavior**: Cancel button closes window without popup message
- **Delete Confirmation**: Centered in edit window when deleting
- **Button Layout**: Cancel, Delete (edit mode only), Test & Save/Save
- **Window Management**: Only one edit window can be open at a time
- **Window Positioning**: Edit window opens at same position as Settings window
- Inherits BaseWindow for standard window behaviors
