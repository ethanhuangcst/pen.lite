# Language Switch Feature Requirements

## User Story

**US-001: Language Switch in Settings Window**

**As a** user of Pen application  
**I want to** switch the application language from the Settings window  
**So that** I can use the application in my preferred language without changing system settings

---

## Acceptance Criteria

### AC-001: Display Language Switch UI

**Given** the Settings window is open  
**When** the user views the header area  
**Then** a "Language:" label is displayed  
**And** a dropdown list with supported languages is displayed next to the label

**UI Specifications:**
- Label: width = 100px, height = 20px, system font, system font-size, left-aligned, position = (380, 473)
- Dropdown: width = 100px, height = 20px, system font, system font-size, position = (460, 473)

---

### AC-002: Display Supported Languages

**Given** the Settings window is open  
**When** the user clicks the language dropdown  
**Then** the following language options are displayed:
- English
- 简体中文

---

### AC-003: Show Current Language as Selected

**Given** the Settings window is open  
**And** the current application language is English  
**When** the user views the language dropdown  
**Then** "English" is displayed as the selected option

---

### AC-004: Switch Language Successfully

**Given** the Settings window is open  
**And** the current language is English  
**When** the user selects "简体中文" from the dropdown  
**Then** the application language changes to Chinese Simplified  
**And** all UI text in the Settings window updates to Chinese  
**And** the language preference is saved  
**And** the dropdown shows "简体中文" as selected

---

### AC-005: Persist Language Preference

**Given** the user has switched the language to Chinese Simplified  
**When** the user restarts the application  
**Then** the application opens with Chinese Simplified as the language

---

### AC-006: i18n Support for Language Switch UI

**Given** the application language is English  
**When** the user views the language switch UI  
**Then** the label displays "Language:"

**Given** the application language is Chinese Simplified  
**When** the user views the language switch UI  
**Then** the label displays "语言:"

---

### AC-007: Update All Windows on Language Change

**Given** the Pen window is open  
**And** the Settings window is open  
**When** the user switches the language in the Settings window  
**Then** both windows update their text to the new language

---

## Supported Languages

| Language Code | Display Name | lproj Name |
|---------------|--------------|------------|
| en | English | en.lproj |
| zh-Hans | 简体中文 | zh-Hans.lproj |

---

## Technical Notes

1. The `LocalizationService` already supports:
   - `AppLanguage` enum with English and Chinese Simplified
   - `setLanguage(_ language: AppLanguage)` method
   - `languageDidChangeNotification` for notifying windows of language changes
   - Persistence via UserDefaults with key "pen.userLanguage"

2. Windows already implement `languageDidChange()` override for updating UI text

---

## Out of Scope

- Adding new languages (only existing supported languages)
- System language detection (already implemented)
- Language-specific formatting (dates, numbers, etc.)
