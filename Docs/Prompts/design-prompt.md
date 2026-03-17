# Design Document: Last Prompt Protection

## Overview

This document describes the technical design for implementing the "Last Prompt Protection" feature, which ensures that at least one prompt always remains in the system.

## Problem Statement

Currently, the system prevents deletion of "default" prompts. The new requirement is to prevent deletion of the **last prompt** regardless of whether it's a default prompt or not, ensuring users always have at least one prompt available for AI interactions.

## Current Implementation

### Files Involved

| File | Purpose |
|------|---------|
| `PromptsTabView.swift` | UI for prompts list, double-click handler |
| `NewOrEditPrompt.swift` | Edit window with delete functionality |
| `PromptService.swift` | Business logic for prompt CRUD operations |
| `Prompt.swift` | Prompt model with `isDefault` property |

### Current Behavior

- Delete button is in the edit window (not in table)
- Double-click on row opens edit window
- Delete confirmation dialog is centered in edit window
- Last prompt cannot be deleted (shows error message)

## Proposed Design

### 1. UI Layer Changes

#### PromptsTabView.swift

**Implementation:**
```swift
// Table has 2 columns: Name (120px) | Prompt (380px)
// Double-click to open edit window
tableView.target = self
tableView.doubleAction = #selector(handleDoubleClick(_:))

// No delete button in table - delete is in edit window
```

#### NewOrEditPrompt.swift

**Implementation:**
```swift
// Delete button only visible in edit mode
if !isNewPrompt {
    deleteButton.isHidden = false
}

// Check if this is the last prompt before showing delete confirmation
func deleteButtonClicked() {
    let prompts = try? PromptService.shared.getPrompts()
    if let prompts = prompts, prompts.count == 1 {
        // Show error message instead of confirmation dialog
        WindowManager.shared.displayPopupMessage("Cannot delete the last prompt")
        return
    }
    // Show confirmation dialog centered in edit window
    showDeleteConfirmationDialog()
}

// Cancel button closes without popup
func cancelButtonClicked() {
    closeAndUnhideOriginatingWindow()
}
```

### 2. Service Layer Changes

#### PromptService.swift

Add a new method to check if a prompt can be deleted:

```swift
/// Checks if a prompt can be deleted (i.e., there are other prompts remaining)
/// - Returns: true if the prompt can be deleted, false if it's the last prompt
func canDeletePrompt() -> Bool {
    do {
        let prompts = try getPrompts()
        return prompts.count > 1
    } catch {
        return false
    }
}

/// Deletes a prompt, but only if there are other prompts remaining
/// - Parameter id: The ID of the prompt to delete
/// - Throws: PromptError.lastPromptCannotBeDeleted if attempting to delete the last prompt
func deletePrompt(id: String) throws {
    if !canDeletePrompt() {
        throw PromptError.lastPromptCannotBeDeleted
    }
    
    let fileURL = fileStorage.getPromptFile(named: id)
    try fileStorage.deleteFile(at: fileURL)
}
```

### 3. Model Layer Changes

#### Prompt.swift

Add a new error type:

```swift
enum PromptError: Error, LocalizedError {
    case lastPromptCannotBeDeleted
    case promptNotFound(id: String)
    case invalidPromptData
    
    var errorDescription: String? {
        switch self {
        case .lastPromptCannotBeDeleted:
            return "Cannot delete the last prompt. At least one prompt must remain."
        case .promptNotFound(let id):
            return "Prompt not found with ID: \(id)"
        case .invalidPromptData:
            return "Invalid prompt data"
        }
    }
}
```

### 4. Localization Changes

Add new localization strings:

```
// en.lproj/Localizable.strings
"cannot_delete_last_prompt" = "Cannot delete the last prompt";
"at_least_one_prompt_required" = "At least one prompt must remain in the system";

// zh-Hans.lproj/Localizable.strings
"cannot_delete_last_prompt" = "无法删除最后一个提示词";
"at_least_one_prompt_required" = "系统中必须至少保留一个提示词";
```

## Data Flow

```
User clicks Delete button
        │
        ▼
┌─────────────────────────┐
│ PromptsTabView /        │
│ EditPromptWindow        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ PromptService           │
│ .canDeletePrompt()      │
└───────────┬─────────────┘
            │
      ┌─────┴─────┐
      │           │
      ▼           ▼
   true         false
      │           │
      ▼           ▼
┌──────────┐  ┌──────────────────────┐
│ Delete   │  │ Show error message   │
│ prompt   │  │ "Cannot delete the   │
│          │  │ last prompt"         │
└──────────┘  └──────────────────────┘
```

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| User has 1 prompt | Delete button in edit window shows error when clicked |
| User has 2 prompts, deletes 1 | Remaining prompt's delete button shows error when clicked |
| User opens edit window for last prompt | Delete button shows error on click |
| User force-deletes via API | Service layer throws error |
| User deletes all prompts via file system | App recreates default prompt on next launch |

## Testing Strategy

### Unit Tests

1. `PromptServiceTests.testCanDeletePrompt_WithOnePrompt_ReturnsFalse`
2. `PromptServiceTests.testCanDeletePrompt_WithMultiplePrompts_ReturnsTrue`
3. `PromptServiceTests.testDeletePrompt_WithOnePrompt_ThrowsError`
4. `PromptServiceTests.testDeletePrompt_WithMultiplePrompts_Succeeds`

### Integration Tests

1. `PromptsTabViewTests.testDoubleClick_OpensEditWindow`
2. `PromptsTabViewTests.testTableHasTwoColumns`
3. `NewOrEditPromptTests.testDeleteButton_ShowsErrorForLastPrompt`
4. `NewOrEditPromptTests.testCancelButton_ClosesWithoutPopup`

### Acceptance Tests

See acceptance criteria in `req-prompts.md`

## Migration Plan

1. **Phase 1**: Add `canDeletePrompt()` method to `PromptService`
2. **Phase 2**: Update `PromptsTabView` to use 2-column table with double-click handler
3. **Phase 3**: Update `NewOrEditPrompt` with delete button and confirmation dialog
4. **Phase 4**: Add localization strings
5. **Phase 5**: Remove "set as default prompt" checkbox (cleanup)

## Rollback Plan

If issues arise, revert to previous implementation with edit/delete buttons in table.

## Open Questions

1. Should we show a different tooltip for the last prompt vs. default prompt?
   - **Decision**: N/A - Delete button is in edit window, not in table

2. Should the error message be a popup or inline?
   - **Decision**: Popup for consistency with other error messages

3. What happens if user manually deletes all prompt files?
   - **Decision**: App will recreate default prompts on next launch (existing behavior)

4. Should the delete confirmation be centered in the edit window?
   - **Decision**: Yes, for consistency with AI Connections tab
