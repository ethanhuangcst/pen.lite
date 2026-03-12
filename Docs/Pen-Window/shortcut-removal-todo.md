# Shortcut Removal Action Plan

## Overview

This document provides a step-by-step action plan for removing the custom keyboard shortcut feature from Pen.lite.

## Prerequisites

- [ ] Review `shortcut-removal.md` for technical analysis
- [ ] Ensure current codebase is committed to git
- [ ] Create a new branch for the removal changes

## Action Items

### Phase 1: Remove Shortcut Display from Footer

#### 1.1 Update Pen.swift

**File**: `mac-app/pen.lite/Sources/App/Pen.swift`

**Action**: Remove shortcut loading and display code in `addFooterContainer()` method

**Lines to Modify**: ~130-145

**Changes**:
```swift
// BEFORE:
// Load saved shortcut from UserDefaults
let defaults = UserDefaults.standard
let shortcutKeyDefaultsKey = "pen.shortcutKey"
let defaultShortcut = "Command+Option+P"
let savedShortcut = defaults.string(forKey: shortcutKeyDefaultsKey) ?? defaultShortcut
let displayShortcut = LocalizationService.shared.formatShortcutForDisplay(savedShortcut)
instructionLabel.stringValue = LocalizationService.shared.localizedString(for: "pen_footer_instruction", withFormat: displayShortcut)

// AFTER:
instructionLabel.stringValue = "" // Remove or replace with other content
```

**Status**: [ ] Not started

#### 1.2 Update PenWindowService.swift

**File**: `mac-app/pen.lite/Sources/Services/PenWindowService.swift`

**Action**: Remove shortcut loading and display code (same as above)

**Lines to Modify**: ~320-325

**Status**: [ ] Not started

---

### Phase 2: Remove Unused Code

#### 2.1 Remove Carbon Import

**File**: `mac-app/pen.lite/Sources/App/Pen.swift`

**Action**: Remove `import Carbon` statement

**Line**: 2

**Status**: [ ] Not started

#### 2.2 Remove KeyCaptureView.swift

**File**: `mac-app/pen.lite/Sources/Views/KeyCaptureView.swift`

**Action**: Delete the entire file

**Status**: [ ] Not started

#### 2.3 Remove formatShortcutForDisplay Method

**File**: `mac-app/pen.lite/Sources/Services/LocalizationService.swift`

**Action**: Remove the `formatShortcutForDisplay()` method

**Lines**: 91-96

**Status**: [ ] Not started

---

### Phase 3: Update Localization

#### 3.1 Update English Localization String

**File**: `mac-app/pen.lite/Resources/en.lproj/Localizable.strings`

**Action**: Rename the key from `pen_footer_instruction` to `pen_footer_appname`:
```
"pen_footer_appname" = "Pen Lite";
```

**Line**: 159

**Status**: [ ] Not started

#### 3.2 Update Chinese Localization String

**File**: `mac-app/pen.lite/Resources/zh-Hans.lproj/Localizable.strings`

**Action**: Rename the key from `pen_footer_instruction` to `pen_footer_appname`:
```
"pen_footer_appname" = "Pen Lite";
```

**Line**: 159

**Status**: [ ] Not started

---

### Phase 4: Update Documentation

#### 4.1 Update Requirement Document

**File**: `Docs/Pen-Window/req-pen-window-behavior.md`

**Action**: Remove the following sections:
- User Story 4: Window Opening via Shortcut Key (Lines 76-93)
- User Story 5: Window Positioning for Shortcut Access (Lines 95-125)

**Status**: [ ] Not started

---

### Phase 5: Testing

#### 5.1 Build and Run

**Action**: Build and run the application

**Checklist**:
- [ ] App launches without errors
- [ ] No compiler warnings
- [ ] Footer displays correctly
- [ ] Menubar icon click opens window
- [ ] Edit menu works (Undo, Redo, Cut, Copy, Paste)
- [ ] Settings window opens correctly

**Status**: [ ] Not started

#### 5.2 Localization Test

**Action**: Test both English and Chinese localizations

**Checklist**:
- [ ] English localization works
- [ ] Chinese localization works
- [ ] No missing localization keys

**Status**: [ ] Not started

---

### Phase 6: Cleanup and Commit

#### 6.1 Code Review

**Action**: Review all changes for completeness

**Status**: [ ] Not started

#### 6.2 Git Commit

**Action**: Commit all changes with message:
```
refactor: Remove custom keyboard shortcut feature

- Remove shortcut display from Pen window footer
- Remove unused KeyCaptureView.swift
- Remove Carbon import
- Remove formatShortcutForDisplay method
- Remove related localization strings
- Update requirement document
```

**Status**: [ ] Not started

---

## Summary

| Phase | Description | Files | Status |
|-------|-------------|-------|--------|
| 1 | Remove shortcut display | Pen.swift, PenWindowService.swift | [x] Completed |
| 2 | Remove unused code | Pen.swift, KeyCaptureView.swift, LocalizationService.swift | [x] Completed |
| 3 | Update localization | en.lproj, zh-Hans.lproj | [x] Completed |
| 4 | Update documentation | req-pen-window-behavior.md | [x] Completed |
| 5 | Testing | - | [x] Completed |
| 6 | Cleanup and commit | - | [ ] Not started |

## Notes

- Keep `MainMenu.swift` - it provides the standard Edit menu
- Keep the footer container - just remove the shortcut instruction
- Keep the auto switch functionality in the footer
- Keep User Stories 1-3 (menubar icon click behavior)
