# Language Switch Feature Design

## Overview

This document describes the technical design for implementing the language switch feature in the Settings window.

---

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     SettingsWindow                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Header Area                       │   │
│  │  ┌────────┐  ┌────────────────┐  ┌───────────────┐  │   │
│  │  │  Logo  │  │ Title Label    │  │ Language      │  │   │
│  │  │        │  │ "Pen Settings" │  │ Switch UI     │  │   │
│  │  └────────┘  └────────────────┘  └───────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Tab View                           │   │
│  │  ┌─────────────────┐  ┌─────────────────┐          │   │
│  │  │ AI Connections  │  │    Prompts      │          │   │
│  │  └─────────────────┘  └─────────────────┘          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Details

### 1. SettingsWindow.swift Changes

#### 1.1 Add UI Components

Add the following properties to `SettingsWindow` class:

```swift
private var languageLabel: NSTextField!
private var languageDropdown: NSPopUpButton!
```

#### 1.2 Add Language Switch UI Method

Create a new method `addLanguageSwitch(to:windowHeight:)`:

```swift
private func addLanguageSwitch(to contentView: NSView, windowHeight: CGFloat) {
    // Language Label
    languageLabel = NSTextField(frame: NSRect(x: 380, y: 473, width: 100, height: 20))
    languageLabel.stringValue = LocalizationService.shared.localizedString(for: "language_label")
    languageLabel.isBezeled = false
    languageLabel.drawsBackground = false
    languageLabel.isEditable = false
    languageLabel.isSelectable = false
    languageLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    languageLabel.alignment = .left
    contentView.addSubview(languageLabel)
    
    // Language Dropdown
    languageDropdown = NSPopUpButton(frame: NSRect(x: 460, y: 473, width: 100, height: 20))
    languageDropdown.bezelStyle = .rounded
    languageDropdown.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
    
    // Populate with available languages
    for language in AppLanguage.allCases {
        languageDropdown.addItem(withTitle: language.displayName)
    }
    
    // Set current selection
    let currentLanguage = LocalizationService.shared.language
    if let index = AppLanguage.allCases.firstIndex(of: currentLanguage) {
        languageDropdown.selectItem(at: index)
    }
    
    // Add target action
    languageDropdown.target = self
    languageDropdown.action = #selector(languageDropdownChanged(_:))
    
    contentView.addSubview(languageDropdown)
}
```

#### 1.3 Add Dropdown Action Handler

```swift
@objc private func languageDropdownChanged(_ sender: NSPopUpButton) {
    guard let selectedLanguage = AppLanguage.allCases.first(where: { 
        $0.displayName == sender.titleOfSelectedItem 
    }) else { return }
    
    LocalizationService.shared.setLanguage(selectedLanguage)
}
```

#### 1.4 Update languageDidChange Method

```swift
override func languageDidChange() {
    super.languageDidChange()
    
    // Update title
    titleLabel?.stringValue = LocalizationService.shared.localizedString(for: "pen_ai_preferences")
    
    // Update language label
    languageLabel?.stringValue = LocalizationService.shared.localizedString(for: "language_label")
    
    // Update tab labels
    updateTabLabels()
    
    // Refresh all tab views
    refreshTabViews()
    
    print("SettingsWindow: Language changed, UI updated")
}
```

#### 1.5 Call in setupContentView

Add the call after `addPenAILogo`:

```swift
// Add PenAI logo
addPenAILogo(to: contentView, windowHeight: windowHeight)

// Add language switch
addLanguageSwitch(to: contentView, windowHeight: windowHeight)

// Add title
titleLabel = NSTextField(frame: NSRect(x: 70, y: windowHeight - 55, width: 200, height: 30))
// ... rest of title setup
```

---

### 2. Localization Files Updates

#### 2.1 en.lproj/Localizable.strings

Add the following key:

```
"language_label" = "Language:";
```

#### 2.2 zh-Hans.lproj/Localizable.strings

Add the following key:

```
"language_label" = "语言:";
```

---

## Data Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                    Language Switch Flow                          │
└──────────────────────────────────────────────────────────────────┘

User selects language in dropdown
           │
           ▼
┌─────────────────────────┐
│ languageDropdownChanged │
│ (SettingsWindow)        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ LocalizationService     │
│ .setLanguage()          │
└───────────┬─────────────┘
            │
            ├──────────────────────────────┐
            │                              │
            ▼                              ▼
┌─────────────────────┐      ┌─────────────────────────┐
│ Save to UserDefaults│      │ Post notification       │
│ (pen.userLanguage)  │      │ languageDidChange       │
└─────────────────────┘      └───────────┬─────────────┘
                                         │
                                         ▼
                         ┌───────────────────────────────┐
                         │ All windows receive           │
                         │ languageDidChangeNotification │
                         └───────────┬───────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
            ┌───────────┐    ┌───────────┐    ┌───────────┐
            │ PenWindow │    │ Settings  │    │ Other     │
            │           │    │ Window    │    │ Windows   │
            └───────────┘    └───────────┘    └───────────┘
```

---

## File Changes Summary

| File | Changes |
|------|---------|
| `Sources/Views/SettingsWindow.swift` | Add language switch UI components and logic |
| `Resources/en.lproj/Localizable.strings` | Add "language_label" key |
| `Resources/zh-Hans.lproj/Localizable.strings` | Add "language_label" key |

---

## Testing Checklist

### Unit Tests
- [ ] Language dropdown displays all supported languages
- [ ] Current language is pre-selected in dropdown
- [ ] Selecting a language calls LocalizationService.setLanguage()
- [ ] Language label updates on language change

### Integration Tests
- [ ] Language change persists across app restarts
- [ ] All windows update when language changes
- [ ] Dropdown selection reflects current language after change

### UI Tests
- [ ] Language switch UI is positioned correctly
- [ ] Dropdown functions correctly with mouse and keyboard
- [ ] UI is accessible via VoiceOver

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Dropdown styling inconsistent with app design | Use standard macOS NSPopUpButton with system font |
| Language change not reflected in all windows | Ensure all windows listen to languageDidChangeNotification |
| Language preference lost | Verify UserDefaults persistence is working |

---

## Dependencies

- `LocalizationService` - Already implemented
- `AppLanguage` enum - Already implemented
- `languageDidChangeNotification` - Already implemented
- `languageDidChange()` override - Already implemented in BaseWindow
