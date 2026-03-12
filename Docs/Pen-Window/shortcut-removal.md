# Technical Analysis: Shortcut Feature Removal

## Overview

This document analyzes the technical approach for removing the custom keyboard shortcut feature from Pen.lite.

## Features to Remove

Based on the requirement document `/Docs/Pen-Window/req-pen-window-behavior.md`, the following features need to be removed:

1. **User Story 4: Window Opening via Shortcut Key** (Lines 76-93)
   - Opening window via shortcut key
   - Reload Pen window via shortcut key

2. **User Story 5: Window Positioning for Shortcut Access** (Lines 95-125)
   - Window positioned at mouse cursor when pressing shortcut
   - Window positioning edge cases for shortcut access

## Current Implementation Analysis

### Files with Shortcut-Related Code

| File | Location | Code | Purpose |
|------|----------|------|---------|
| `Pen.swift` | Line 2 | `import Carbon` | Carbon framework for keyboard shortcuts |
| `Pen.swift` | Line 4 | `// Import MainMenu for shortcut support` | Comment |
| `Pen.swift` | Line 50 | `installMainMenu()` | Install main menu for shortcut support |
| `Pen.swift` | Lines 141-145 | `shortcutKeyDefaultsKey`, `defaultShortcut`, `formatShortcutForDisplay` | Load and display shortcut in footer |
| `PenWindowService.swift` | Lines 321-325 | Same shortcut display code | Load and display shortcut in footer |
| `LocalizationService.swift` | Lines 91-96 | `formatShortcutForDisplay()` | Format shortcut for display |
| `KeyCaptureView.swift` | Entire file | `KeyCaptureView` class | View for capturing keyboard events |
| `MainMenu.swift` | Entire file | `installMainMenu()` | Main menu for shortcut support |
| `en.lproj/Localizable.strings` | Line 159 | `"pen_footer_instruction"` | Localization string |
| `zh-Hans.lproj/Localizable.strings` | Line 159 | `"pen_footer_instruction"` | Localization string |

### Code Flow Analysis

```
App Launch
    │
    ├── import Carbon (for keyboard shortcuts)
    │
    ├── installMainMenu() → Creates main menu for shortcut support
    │
    └── createMainWindow()
        │
        └── addFooterContainer()
            │
            ├── Load shortcut from UserDefaults ("pen.shortcutKey")
            │
            ├── Format shortcut for display
            │
            └── Display in footer: "Hotkey: Cmd+Opt+P"
```

### Key Observations

1. **No Global Keyboard Monitor Found**: The code does NOT contain:
   - `NSEvent.addGlobalMonitorForEvents`
   - `NSEvent.addLocalMonitorForEvents`
   - Any actual keyboard event monitoring

2. **Shortcut Display Only**: The current implementation only:
   - Loads a saved shortcut string from UserDefaults
   - Formats it for display
   - Shows it in the footer

3. **KeyCaptureView Unused**: The `KeyCaptureView.swift` file exists but is NOT used anywhere in the codebase.

4. **MainMenu for Edit Menu**: The `MainMenu.swift` provides standard Edit menu (Undo, Redo, Cut, Copy, Paste, Find) - this should be KEPT.

5. **Carbon Import Unused**: The `import Carbon` statement is present but no Carbon APIs are actually used.

## Technical Solution

### Phase 1: Remove Shortcut Display

Remove the shortcut display from the footer of the Pen window.

**Files to Modify:**
- `Pen.swift` - Remove shortcut loading and display code in `addFooterContainer()`
- `PenWindowService.swift` - Remove shortcut loading and display code

### Phase 2: Remove Unused Code

Remove code that is no longer needed.

**Files to Delete:**
- `KeyCaptureView.swift` - Not used anywhere

**Files to Modify:**
- `Pen.swift` - Remove `import Carbon`
- `LocalizationService.swift` - Remove `formatShortcutForDisplay()` method

### Phase 3: Update Localization

Remove localization strings related to shortcuts.

**Files to Modify:**
- `en.lproj/Localizable.strings` - Remove `pen_footer_instruction`
- `zh-Hans.lproj/Localizable.strings` - Remove `pen_footer_instruction`

### Phase 4: Update Documentation

Update the requirement document to remove the shortcut-related user stories.

**Files to Modify:**
- `Docs/Pen-Window/req-pen-window-behavior.md` - Remove User Story 4 and 5

## What to Keep

1. **MainMenu.swift** - Keep for standard Edit menu functionality
2. **Footer Container** - Keep the footer, just remove the shortcut instruction
3. **Auto Switch** - Keep the auto switch functionality in the footer
4. **Window positioning via menubar icon** - Keep User Story 1-3 (menubar icon click)

## Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Breaking footer layout | Low | Test footer display after changes |
| Missing localization keys | Low | Remove all related keys |
| Unused imports causing warnings | Low | Remove Carbon import |

## Testing Checklist

- [ ] App launches without errors
- [ ] Footer displays correctly without shortcut instruction
- [ ] Menubar icon click still opens window
- [ ] Edit menu still works (Undo, Redo, Cut, Copy, Paste)
- [ ] No compiler warnings
- [ ] Localization works for remaining strings
