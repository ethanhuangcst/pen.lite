# Design Document: Last Prompt Protection

## Overview

This document describes the technical design for implementing the "Last Prompt Protection" feature, which ensures that at least one prompt always remains in the system.

## Problem Statement

Currently, the system prevents deletion of "default" prompts. The new requirement is to prevent deletion of the **last prompt** regardless of whether it's a default prompt or not, ensuring users always have at least one prompt available for AI interactions.

## Current Implementation

### Files Involved

| File | Purpose |
|------|---------|
| `PromptsTabView.swift` | UI for prompts list, delete button handling |
| `EditPromptWindow.swift` | Edit window with delete functionality |
| `PromptService.swift` | Business logic for prompt CRUD operations |
| `Prompt.swift` | Prompt model with `isDefault` property |

### Current Behavior

- Delete button is disabled for prompts marked as `isDefault: true`
- Tooltip shows "Default prompt cannot be deleted"
- Edit window delete button follows same logic

## Proposed Design

### 1. UI Layer Changes

#### PromptsTabView.swift

**Current Logic:**
```swift
// Disable delete for default prompts
deleteButton.isEnabled = !prompt.isDefault
```

**New Logic:**
```swift
// Disable delete for last prompt
let isLastPrompt = prompts.count == 1
deleteButton.isEnabled = !isLastPrompt
if isLastPrompt {
    deleteButton.toolTip = "Cannot delete the last prompt"
}
```

#### EditPromptWindow.swift

**Current Logic:**
```swift
// Delete button always enabled, shows confirmation dialog
```

**New Logic:**
```swift
// Check if this is the last prompt before showing delete confirmation
func deleteButtonClicked() {
    let prompts = try? PromptService.shared.getPrompts()
    if let prompts = prompts, prompts.count == 1 {
        // Show error message instead of confirmation dialog
        WindowManager.shared.displayPopupMessage("Cannot delete the last prompt")
        return
    }
    // Show confirmation dialog
    showDeleteConfirmationDialog()
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
| User has 1 prompt | Delete button disabled, tooltip shows |
| User has 2 prompts, deletes 1 | Remaining prompt's delete button becomes disabled |
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

1. `PromptsTabViewTests.testDeleteButton_DisabledWhenOnePrompt`
2. `PromptsTabViewTests.testDeleteButton_EnabledWhenMultiplePrompts`
3. `EditPromptWindowTests.testDeleteButton_ShowsErrorForLastPrompt`

### Acceptance Tests

See acceptance criteria in `req-prompts.md`

## Migration Plan

1. **Phase 1**: Add `canDeletePrompt()` method to `PromptService`
2. **Phase 2**: Update `PromptsTabView` to use new logic
3. **Phase 3**: Update `EditPromptWindow` to use new logic
4. **Phase 4**: Add localization strings
5. **Phase 5**: Remove `isDefault` check from delete logic (cleanup)

## Rollback Plan

If issues arise, revert to checking `isDefault` property:

```swift
// Rollback: Use isDefault check
deleteButton.isEnabled = !prompt.isDefault
```

## Open Questions

1. Should we show a different tooltip for the last prompt vs. default prompt?
   - **Decision**: Yes, show "Cannot delete the last prompt" for clarity

2. Should the error message be a popup or inline?
   - **Decision**: Popup for consistency with other error messages

3. What happens if user manually deletes all prompt files?
   - **Decision**: App will recreate default prompts on next launch (existing behavior)
