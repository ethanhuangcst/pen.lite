# Plan: Rename "Preferences" to "Settings" and Update Window Behavior

## Summary
1. Change all text "Preferences" to "Settings" in documentation and code
2. Keep Pen window open when Settings window is open
3. Pen window behaviors (language, AI connections, prompts) should update when settings change

---

## Part 1: Documentation Changes

### 1.1 Files to Update

| File | Changes |
|------|---------|
| `Docs/Settings/req-preferences.md` | Rename file to `req-settings.md`, change all "Preferences" to "Settings", update User Story 0 behavior |
| `Docs/Prompts/req-prompts-ui.md` | Line 10: Change "Preferences window size" to "Settings window size" |
| `Docs/Architecture/tech-challenges.md` | Line 351-357: Change "Preferences" to "Settings" in onboarding wizard |
| `Docs/Architecture/app-packaging-free.md` | Line 167-171: Change "Preferences" to "Settings" in first run setup |
| `Docs/Architecture/app-distribution-plan.md` | Line 80: Change "Preferences window" to "Settings window" |
| `Docs/system/design-light-dark-mode.md` | Line 80-83: Change "Preferences window" to "Settings window" |

### 1.2 Specific Changes for req-preferences.md (rename to req-settings.md)

**Current User Story 0:**
```
# User Story 0: Close Other Windows when open Preferences window
As a Pen user, I want Pen app to close all other windows when I open Preferences window, so that I can focus on the Preferences window
Scenario: close other windows when open Preferences window
    Given Pen app is running
    AND other windows are open
    When I open Preferences window
    Then all other windows should be closed
```

**New User Story 0:**
```
# User Story 0: Keep Pen Window Open When Settings Window Opens
As a Pen user, I want the Pen window to remain open when I open the Settings window, so that I can see the changes reflected in the Pen window immediately
Scenario: Keep Pen window open when Settings window opens
    Given Pen app is running
    AND Pen window is open
    When I open Settings window
    Then the Pen window should remain open
    And the Settings window should appear at the same position as the Pen window
```

**New User Story (add):**
```
## User Story: Real-time Settings Update
As a Pen user, I want the Pen window to update immediately when I change settings, so that I can see the effect of my changes without reopening the window

### Acceptance Criteria
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

---

## Part 2: Code Changes

### 2.1 Localization Files

| File | Changes |
|------|---------|
| `Resources/en.lproj/Localizable.strings` | Line 10: Change `"pen_ai_preferences"` value from "Pen Lite - Preferences" to "Pen Lite - Settings" |
| `Resources/zh-Hans.lproj/Localizable.strings` | Update corresponding Chinese translation |

### 2.2 Source Code Files

| File | Changes |
|------|---------|
| `Sources/App/Pen.swift` | 1. Remove `closeOtherWindows()` call in `openSettings()` method (Line 330) <br> 2. Add notification observers for AI connections and prompts changes |
| `Sources/Views/SettingsWindow.swift` | No changes needed (already named Settings) |
| `Tests/PreferencesWindowTests.swift` | Rename to `SettingsWindowTests.swift`, update all references |

### 2.3 Specific Code Changes

#### Pen.swift - openSettings() method

**Current Code (Line 329-341):**
```swift
@objc private func openSettings() {
    closeOtherWindows()
    
    if let window = settingsWindow {
        window.showAndFocus()
    } else {
        settingsWindow = SettingsWindow()
        
        if let window = settingsWindow {
            window.showAndFocus()
        }
    }
}
```

**New Code:**
```swift
@objc private func openSettings() {
    // Don't close other windows - keep Pen window open
    
    if let window = settingsWindow {
        window.showAndFocus()
    } else {
        settingsWindow = SettingsWindow()
        
        if let window = settingsWindow {
            window.showAndFocus()
        }
    }
}
```

#### Pen.swift - Add notification observers for real-time updates

**Add in applicationDidFinishLaunching():**
```swift
// Observe AI connection changes
NotificationCenter.default.addObserver(
    self,
    selector: #selector(aiConnectionsDidChange(_:)),
    name: AIConnectionService.connectionsDidChangeNotification,
    object: nil
)

// Observe prompt changes
NotificationCenter.default.addObserver(
    self,
    selector: #selector(promptsDidChange(_:)),
    name: PromptService.promptsDidChangeNotification,
    object: nil
)
```

**Add handler methods:**
```swift
@objc private func aiConnectionsDidChange(_ notification: Notification) {
    // Reload AI connections in Pen window if open
    Task {
        await penWindowService?.reloadAIConnections()
    }
}

@objc private func promptsDidChange(_ notification: Notification) {
    // Reload prompts in Pen window if open
    Task {
        await penWindowService?.reloadPrompts()
    }
}
```

### 2.4 Service Layer Changes

| File | Changes |
|------|---------|
| `Sources/Services/AIConnectionService.swift` | Add `static let connectionsDidChangeNotification = Notification.Name("AIConnectionsDidChangeNotification")` and post notification after save/delete operations |
| `Sources/Services/PromptService.swift` | Add `static let promptsDidChangeNotification = Notification.Name("PromptsDidChangeNotification")` and post notification after save/delete operations |

### 2.5 PenWindowService Changes

**Add new methods:**
```swift
func reloadAIConnections() async {
    // Reload AI connections and update dropdown
    await loadAIConfigurations()
}

func reloadPrompts() async {
    // Reload prompts and update dropdown
    await loadPrompts()
}
```

---

## Part 3: Implementation Order

### Phase 1: Documentation Updates
1. Rename `req-preferences.md` to `req-settings.md`
2. Update all "Preferences" to "Settings" in all docs
3. Update User Story 0 behavior
4. Add new User Story for real-time updates

### Phase 2: Localization Updates
1. Update `en.lproj/Localizable.strings`
2. Update `zh-Hans.lproj/Localizable.strings`

### Phase 3: Core Code Changes
1. Update `Pen.swift` - remove `closeOtherWindows()` in `openSettings()`
2. Add notification observers in `Pen.swift`
3. Add notification posting in `AIConnectionService.swift`
4. Add notification posting in `PromptService.swift`
5. Add reload methods in `PenWindowService.swift`

### Phase 4: Test Updates
1. Rename `PreferencesWindowTests.swift` to `SettingsWindowTests.swift`
2. Update test class name and references

---

## Part 4: Files Summary

### Documentation Files (6 files)
- `Docs/Settings/req-preferences.md` → rename to `req-settings.md`
- `Docs/Prompts/req-prompts-ui.md`
- `Docs/Architecture/tech-challenges.md`
- `Docs/Architecture/app-packaging-free.md`
- `Docs/Architecture/app-distribution-plan.md`
- `Docs/system/design-light-dark-mode.md`

### Code Files (6 files)
- `mac-app/pen.lite/Resources/en.lproj/Localizable.strings`
- `mac-app/pen.lite/Resources/zh-Hans.lproj/Localizable.strings`
- `mac-app/pen.lite/Sources/App/Pen.swift`
- `mac-app/pen.lite/Sources/Services/AIConnectionService.swift`
- `mac-app/pen.lite/Sources/Services/PromptService.swift`
- `mac-app/pen.lite/Sources/Services/PenWindowService.swift`
- `mac-app/pen.lite/Tests/PreferencesWindowTests.swift` → rename to `SettingsWindowTests.swift`

---

## Part 5: Testing Checklist

- [ ] Settings window opens without closing Pen window
- [ ] Language change in Settings updates Pen window immediately
- [ ] Adding AI connection in Settings updates Pen dropdown immediately
- [ ] Editing AI connection in Settings updates Pen dropdown immediately
- [ ] Deleting AI connection in Settings updates Pen dropdown immediately
- [ ] Adding prompt in Settings updates Pen dropdown immediately
- [ ] Editing prompt in Settings updates Pen dropdown immediately
- [ ] Deleting prompt in Settings updates Pen dropdown immediately
- [ ] All documentation shows "Settings" instead of "Preferences"
- [ ] All UI text shows "Settings" instead of "Preferences"
