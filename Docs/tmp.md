# Plan: Keep Settings Window Open When Pen Window Opens

## Summary
When Pen window opens, keep Settings window open (instead of closing all non-Pen windows).

---

## Part 1: Documentation Changes

### 1.1 Files to Update

| File | Changes |
|------|---------|
| `Docs/Pen-Window/req-pen-features.md` | Update F1-US1 to exclude Settings window from being closed |

### 1.2 Specific Changes for req-pen-features.md

**Current User Story F1-US1 (Lines 27-40):**
```gherkin
### US1. Close non-Pen windows when Pen window opens
As a Pen user, I want Pen app to close all other windows when I open the Pen window, so that I can focus on the Pen window.

#### Acceptance Criteria
- AC1. When Pen window opens, all other app windows are closed.
- AC2. Pen window remains active and focused.

#### Scenarios
Scenario F1-US1-S1: Close non-Pen windows on Pen window open
  Given Pen app is running
  And one or more non-Pen windows are open
  When I open the Pen window
  Then all non-Pen windows are closed
  And Pen window stays open and focused
```

**New User Story F1-US1:**
```gherkin
### US1. Close non-Pen windows when Pen window opens (except Settings)
As a Pen user, I want Pen app to close all other windows except Settings when I open the Pen window, so that I can focus on the Pen window while keeping Settings accessible.

#### Acceptance Criteria
- AC1. When Pen window opens, all other app windows are closed except Settings window.
- AC2. Pen window remains active and focused.
- AC3. Settings window stays open if it was open before Pen window opened.

#### Scenarios
Scenario F1-US1-S1: Close non-Pen windows on Pen window open (except Settings)
  Given Pen app is running
  And one or more non-Pen windows are open
  And Settings window is open
  When I open the Pen window
  Then all non-Pen windows are closed except Settings window
  And Settings window stays open
  And Pen window stays open and focused

Scenario F1-US1-S2: Close non-Pen windows when Settings is not open
  Given Pen app is running
  And one or more non-Pen windows are open
  And Settings window is not open
  When I open the Pen window
  Then all non-Pen windows are closed
  And Pen window stays open and focused
```

---

## Part 2: Code Changes

### 2.1 Source Code Files

| File | Changes |
|------|---------|
| `Sources/App/Pen.swift` | Modify `closeOtherWindows()` to skip Settings window |

### 2.2 Specific Code Changes

#### Pen.swift - closeOtherWindows() method (Lines 429-437)

**Current Code:**
```swift
private func closeOtherWindows() {
    for window in NSApplication.shared.windows {
        window.orderOut(nil)
    }
    
    window = nil
    settingsWindow = nil
    newOrEditPromptWindow = nil
}
```

**New Code:**
```swift
private func closeOtherWindows() {
    for window in NSApplication.shared.windows {
        // Skip Settings window - keep it open for real-time updates
        if window is SettingsWindow {
            continue
        }
        window.orderOut(nil)
    }
    
    window = nil
    // Don't nil settingsWindow - keep it open
    newOrEditPromptWindow = nil
}
```

---

## Part 3: Implementation Order

### Phase 1: Documentation Updates
1. Update `Docs/Pen-Window/req-pen-features.md` with new User Story F1-US1

### Phase 2: Code Changes
1. Update `closeOtherWindows()` in `Pen.swift` to skip Settings window
2. Remove `settingsWindow = nil` line to keep the reference

---

## Part 4: Testing Checklist

- [ ] Pen window opens and closes normally
- [ ] Settings window stays open when Pen window opens
- [ ] Other windows (like edit windows) are closed when Pen window opens
- [ ] Settings window can still be closed manually
- [ ] Documentation reflects the new behavior

---

## Part 5: Files Summary

### Documentation Files (1 file)
- `Docs/Pen-Window/req-pen-features.md`

### Code Files (1 file)
- `mac-app/pen.lite/Sources/App/Pen.swift`
