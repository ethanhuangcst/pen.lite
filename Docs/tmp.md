# Consistency Review: AI Connections vs Prompts Tab (Deep Analysis)

## Problem Statement

Settings - AI Connections tab and Prompts tab have different behaviors:

| Feature | AI Connections Tab | Prompts Tab |
|---------|-------------------|-------------|
| **Launching edit window** | Double-click row | Edit button per row |
| **Cancel popup message** | No popup, closes directly | Shows popup message, then closes |
| **Delete button location** | In edit window | In table row |
| **Delete confirmation** | Custom dialog in edit window | Direct delete with popup |
| **Edit window buttons** | Cancel, Delete, Test & Save | Cancel, Save |
| **Edit window size** | 680 × 518 | 600 × 518 |
| **Table columns** | Provider, API Key, Delete | Prompt Name, Edit, Delete |

**Target**: Use AI Connections tab behavior consistently.

---

## Current Implementation Analysis

### AI Connections Tab

#### Table Structure (`AIConfigurationTabView.swift`)

```swift
// Lines 176-192: Table columns
let providerColumn = NSTableColumn(identifier: "provider")
providerColumn.width = 120

let apiKeyColumn = NSTableColumn(identifier: "apiKey")
apiKeyColumn.width = 380

let deleteColumn = NSTableColumn(identifier: "delete")
deleteColumn.width = 60

// NO edit button column
```

#### Double-Click Handler (`AIConfigurationTabView.swift`)

```swift
// Lines 76-77: Setup
configurationsTable.target = self
configurationsTable.doubleAction = #selector(handleDoubleClick(_:))

// Lines 87-93: Handler
@objc private func handleDoubleClick(_ sender: NSTableView) {
    let row = sender.clickedRow
    guard row >= 0, row < configurations.count else { return }
    let configuration = configurations[row]
    showEditWindow(configuration: configuration, row: row)
}
```

#### Edit Window (`EditAIConnectionWindow.swift`)

```swift
// Line 32: Window size
let windowSize = NSSize(width: 680, height: 518)

// Lines 171-202: Buttons (3 buttons)
// Cancel button: x = windowSize.width - 500
let ai_btn_cancel = FocusableButton(frame: NSRect(x: windowSize.width - 500, y: 40, width: 120, height: 32))

// Delete button: x = windowSize.width - 370 (RED BORDER)
let ai_btn_delete = FocusableButton(frame: NSRect(x: windowSize.width - 370, y: 40, width: 120, height: 32))
ai_btn_delete.layer?.borderColor = NSColor.systemRed.cgColor
ai_btn_delete.contentTintColor = NSColor.systemRed

// Test & Save button: x = windowSize.width - 240 (GREEN BORDER)
let ai_btn_test_save = FocusableButton(frame: NSRect(x: windowSize.width - 240, y: 40, width: 120, height: 32))
ai_btn_test_save.layer?.borderColor = NSColor.systemGreen.cgColor

// Lines 222-224: Cancel action - NO popup
@objc private func cancelButtonClicked() {
    closeWindowAndRestoreSettings()
}

// Lines 310-313: Delete action - calls callback
@objc private func deleteButtonClicked() {
    guard let config = configuration else { return }
    onDelete?(config, row)
}
```

#### Delete Confirmation Dialog (`AIConfigurationTabView.swift`)

```swift
// Lines 347-470: Custom dialog
let dialogWidth: CGFloat = 238
let dialogHeight: CGFloat = 100

// Dialog has:
// - Title: "Are you sure?"
// - Cancel button (gray border)
// - Delete button (red border)

// Dialog is centered in edit window or settings window
```

### Prompts Tab

#### Table Structure (`PromptsTabView.swift`)

```swift
// Lines 176-205: Table columns
let nameColumn = NSTableColumn(identifier: "name")
nameColumn.width = 447

let editColumn = NSTableColumn(identifier: "edit")  // ← HAS EDIT COLUMN
editColumn.width = 33

let deleteColumn = NSTableColumn(identifier: "delete")
deleteColumn.width = 33

// NO double-click handler defined
```

#### Edit Window (`NewOrEditPrompt.swift`)

```swift
// Line 36: Window size
let windowSize = NSSize(width: 600, height: 518)

// Lines 132-146: Buttons (2 buttons only)
// Cancel button: x = windowSize.width - 68 - 20 - 68 - 20 - 20
let cancelButton = FocusableButton(frame: NSRect(x: ..., y: 26, width: 68, height: 32))

// Save button: x = windowSize.width - 68 - 20 - 20
let saveButton = FocusableButton(frame: NSRect(x: ..., y: 26, width: 68, height: 32))

// NO Delete button

// Lines 234-243: Cancel action - HAS popup
@objc private func cancelButtonClicked() {
    let message = isNewPrompt ? 
        LocalizationService.shared.localizedString(for: "create_new_prompt_canceled") : 
        LocalizationService.shared.localizedString(for: "edit_prompt_canceled")
    WindowManager.shared.displayPopupMessage(message)
    closeAndUnhideOriginatingWindow()
}

// NO onDelete callback defined
```

---

## Required Changes

### 1. Code Changes

#### File: `Sources/Views/PromptsTabView.swift`

**Change 1: Remove edit button column**

Remove lines 200-205:
```swift
// DELETE THIS:
let editColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("edit"))
editColumn.title = LocalizationService.shared.localizedString(for: "edit_button")
editColumn.width = 33
tableView.addTableColumn(editColumn)
```

**Change 2: Remove delete button column**

Remove lines 206-211:
```swift
// DELETE THIS:
let deleteColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("delete"))
deleteColumn.title = ""
deleteColumn.width = 33
tableView.addTableColumn(deleteColumn)
```

**Change 3: Update table column to match AI Connections style**

Update lines 176-199 to have single column:
```swift
let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
nameColumn.title = LocalizationService.shared.localizedString(for: "prompt_name_column")
nameColumn.width = 520  // Full width
tableView.addTableColumn(nameColumn)
```

**Change 4: Add double-click handler**

Add after line 183:
```swift
// Add double-click handler
tableView.target = self
tableView.doubleAction = #selector(handleDoubleClick(_:))
```

**Change 5: Add handleDoubleClick method**

Add new method:
```swift
@objc private func handleDoubleClick(_ sender: NSTableView) {
    let row = sender.clickedRow
    guard row >= 0, row < prompts.count, let parentWindow = parentWindow else { return }
    
    let prompt = prompts[row]
    let editWindow = NewOrEditPrompt(prompt: prompt, originatingWindow: parentWindow)
    
    editWindow.onSave = { [weak self] updatedPrompt in
        guard let self = self else { return }
        Task {
            do {
                try PromptService.shared.updatePrompt(updatedPrompt)
                DispatchQueue.main.async {
                    self.loadPromptsFromFiles()
                    WindowManager.shared.displayPopupMessage(
                        LocalizationService.shared.localizedString(for: "prompt_updated_successfully")
                    )
                }
            } catch {
                print("[PromptsTabView] Failed to update prompt: \(error)")
            }
        }
    }
    
    editWindow.onDelete = { [weak self] promptToDelete in
        guard let self = self else { return }
        self.deletePrompt(prompt: promptToDelete, row: row)
    }
    
    parentWindow.orderOut(nil)
    editWindow.showAndFocus()
}
```

**Change 6: Remove edit button related code**

Remove:
- Lines 303-305: Edit button case in `tableView(_:viewFor:row:)`
- Lines 373-387: `createEditButton` method
- Lines 427-456: `editButtonClicked` method

**Change 7: Remove delete button related code**

Remove:
- Lines 305-307: Delete button case in `tableView(_:viewFor:row:)`
- Lines 389-403: `createDeleteButton` method
- Lines 458-487: `deleteButtonClicked` method

**Change 8: Add delete confirmation dialog**

Add method similar to AI Connections:
```swift
private var promptsForDelete: [Prompt] = []

private func showDeleteConfirmationDialog(prompt: Prompt, row: Int) {
    let dialogWidth: CGFloat = 238
    let dialogHeight: CGFloat = 100
    
    // Calculate position - center in edit window if available
    var originX: CGFloat = 0
    var originY: CGFloat = 0
    
    if let editWindow = NewOrEditPrompt.sharedWindow {
        let editFrame = editWindow.frame
        originX = editFrame.origin.x + (editFrame.width - dialogWidth) / 2
        originY = editFrame.origin.y + (editFrame.height - dialogHeight) / 2
    } else if let settingsWindow = self.window {
        let settingsFrame = settingsWindow.frame
        originX = settingsFrame.origin.x + (settingsFrame.width - dialogWidth) / 2
        originY = settingsFrame.origin.y + (settingsFrame.height - dialogHeight) / 2
    }
    
    // Create dialog window with Cancel and Delete buttons
    // ... (same as AIConfigurationTabView)
}

private func deletePrompt(prompt: Prompt, row: Int) {
    if prompts.count <= 1 {
        WindowManager.shared.displayPopupMessage(
            LocalizationService.shared.localizedString(for: "cannot_delete_last_prompt")
        )
        return
    }
    
    showDeleteConfirmationDialog(prompt: prompt, row: row)
}
```

#### File: `Sources/Views/NewOrEditPrompt.swift`

**Change 1: Add singleton pattern**

Add after class declaration:
```swift
// MARK: - Singleton
static var sharedWindow: NewOrEditPrompt?
```

**Change 2: Add onDelete callback**

Add after `onSave`:
```swift
var onDelete: ((Prompt) -> Void)?
```

**Change 3: Update window size (optional)**

Change line 36:
```swift
// Option A: Keep current size
let windowSize = NSSize(width: 600, height: 518)

// Option B: Match AI Connections
let windowSize = NSSize(width: 680, height: 518)
```

**Change 4: Add Delete button**

Add after cancelButton setup (around line 146):
```swift
// Delete button (only for edit mode, not new)
private let deleteButton = FocusableButton()

// In setupUI, add:
if !isNewPrompt {
    deleteButton.frame = NSRect(x: windowSize.width - 68 - 20 - 68 - 20 - 68 - 20 - 20, y: 26, width: 68, height: 32)
    deleteButton.title = localizedString(for: "delete_button")
    deleteButton.bezelStyle = .rounded
    deleteButton.target = self
    deleteButton.action = #selector(deleteButtonClicked)
    deleteButton.wantsLayer = true
    deleteButton.layer?.borderWidth = 1.0
    deleteButton.layer?.borderColor = NSColor.systemRed.cgColor
    deleteButton.layer?.cornerRadius = 6.0
    deleteButton.contentTintColor = NSColor.systemRed
    contentView.addSubview(deleteButton)
}
```

**Change 5: Add delete action**

Add method:
```swift
@objc private func deleteButtonClicked() {
    guard let prompt = prompt else { return }
    onDelete?(prompt)
}
```

**Change 6: Remove popup message on cancel**

Change lines 234-243:
```swift
// BEFORE:
@objc private func cancelButtonClicked() {
    let message = isNewPrompt ? 
        LocalizationService.shared.localizedString(for: "create_new_prompt_canceled") : 
        LocalizationService.shared.localizedString(for: "edit_prompt_canceled")
    WindowManager.shared.displayPopupMessage(message)
    closeAndUnhideOriginatingWindow()
}

// AFTER:
@objc private func cancelButtonClicked() {
    closeAndUnhideOriginatingWindow()
}
```

**Change 7: Update static showWindow method**

Add similar to EditAIConnectionWindow:
```swift
static func showWindow(prompt: Prompt? = nil, originatingWindow: NSWindow?) -> NewOrEditPrompt {
    if let existing = sharedWindow {
        existing.prompt = prompt
        existing.isNewPrompt = prompt == nil
        existing.updateFields()
        existing.originatingWindow = originatingWindow
        originatingWindow?.orderOut(nil)
        existing.showAndFocus()
        return existing
    }
    
    let window = NewOrEditPrompt(prompt: prompt, originatingWindow: originatingWindow)
    sharedWindow = window
    originatingWindow?.orderOut(nil)
    window.showAndFocus()
    return window
}

static func closeWindow() {
    sharedWindow?.closeAndUnhideOriginatingWindow()
    sharedWindow = nil
}
```

**Change 8: Update closeAndUnhideOriginatingWindow**

Update to match AI Connections:
```swift
private func closeAndUnhideOriginatingWindow() {
    orderOut(nil)
    originatingWindow?.makeKeyAndOrderFront(nil)
    NewOrEditPrompt.sharedWindow = nil
}
```

---

### 2. Documentation Changes

#### File: `Docs/Prompts/req-prompts-ui.md`

**Remove:**
- Lines 42-47: Edit column from table columns
- Lines 48-54: Delete column from table columns
- Lines 55-61: Edit button section
- Lines 62-68: Delete button section

**Add:**
```markdown
#### Table Columns
| Column | Width | Description |
|--------|-------|-------------|
| Prompt Name | 520px | Displays the prompt name |

#### Double-Click Behavior
- **Action**: Double-click on row opens NewOrEditPrompt window with existing prompt data
- **Requirement**: Only one NewOrEditPrompt window can be open at a time
```

#### File: `Docs/Prompts/req-prompts.md`

**Add User Story:**
```markdown
## User Story 3: Edit Prompt via Double-Click
As a Pen user
I want to edit a prompt by double-clicking it
So that I can modify the prompt details

### Acceptance Criteria

Scenario: Open edit window on double-click
  Given the user is using the app
  And the user navigates to Settings - Prompts tab
  And there is at least one prompt in the list
  When the user double-clicks on a row
  Then the Settings window is hidden
  And an edit window appears at the exact same position as the Settings window
  And the edit window contains the prompt data pre-filled with current values
  And only one edit window can be open at a time

Scenario: Cancel edit without saving
  Given the edit window is open
  And the user has modified some fields
  When the user clicks the Cancel button
  Then the edit window closes
  And the Settings window is restored at the same position
  And no changes are saved
  And no popup message is displayed

Scenario: Delete prompt from edit window
  Given the edit window is open for an existing prompt
  And there are multiple prompts in the list
  When the user clicks the Delete button
  Then a confirmation dialog appears
  And the dialog has Cancel and Delete buttons
  And the Delete button has a red border

Scenario: Confirm delete from edit window
  Given the delete confirmation dialog is open
  When the user clicks the Delete button
  Then the prompt is deleted
  And the edit window closes
  And the Settings window is restored
  And a success message is displayed

Scenario: Cancel delete from edit window
  Given the delete confirmation dialog is open
  When the user clicks the Cancel button
  Then the dialog closes
  And the edit window remains open
```

---

## Todo List for Implementation

### Phase 1: NewOrEditPrompt.swift Changes

1. [ ] Add singleton pattern (`sharedWindow`)
2. [ ] Add `onDelete` callback
3. [ ] Add Delete button (only for edit mode)
4. [ ] Add `deleteButtonClicked()` method
5. [ ] Remove popup message on cancel
6. [ ] Add `showWindow()` static method
7. [ ] Update `closeAndUnhideOriginatingWindow()` to clear singleton

### Phase 2: PromptsTabView.swift Changes

8. [ ] Remove edit button column
9. [ ] Remove delete button column
10. [ ] Update table to single column (Prompt Name)
11. [ ] Add double-click handler
12. [ ] Add `handleDoubleClick()` method
13. [ ] Remove `createEditButton()` method
14. [ ] Remove `createDeleteButton()` method
15. [ ] Remove `editButtonClicked()` method
16. [ ] Remove `deleteButtonClicked()` method
17. [ ] Add `showDeleteConfirmationDialog()` method
18. [ ] Add `deletePrompt()` method
19. [ ] Add `cancelDeleteDialog()` method
20. [ ] Add `confirmDeleteDialog()` method

### Phase 3: Documentation Updates

21. [ ] Update `req-prompts-ui.md` - remove edit/delete columns, add double-click
22. [ ] Update `req-prompts.md` - add User Story 3

### Phase 4: Testing

23. [ ] Build and run
24. [ ] Test double-click opens edit window
25. [ ] Test cancel closes without popup
26. [ ] Test delete button shows confirmation dialog
27. [ ] Test delete confirmation deletes prompt
28. [ ] Test last prompt protection
29. [ ] Test new prompt creation still works

---

## Files Affected

| File | Type | Lines Changed | Description |
|------|------|---------------|-------------|
| `PromptsTabView.swift` | Code | ~100 lines | Major refactor |
| `NewOrEditPrompt.swift` | Code | ~50 lines | Add delete, remove cancel popup |
| `req-prompts-ui.md` | Doc | ~20 lines | Update table structure |
| `req-prompts.md` | Doc | ~30 lines | Add User Story 3 |

---

## Testing Checklist

After implementation:

- [ ] Double-click on prompt row opens edit window
- [ ] Cancel button closes window without popup message
- [ ] Settings window is restored after edit window closes
- [ ] Only one edit window can be open at a time
- [ ] Delete button appears in edit window (not in table)
- [ ] Delete button has red border
- [ ] Clicking Delete shows confirmation dialog
- [ ] Confirmation dialog has Cancel and Delete buttons
- [ ] Cancel in dialog closes dialog, keeps edit window open
- [ ] Delete in dialog deletes prompt and closes edit window
- [ ] Cannot delete last prompt (shows error message)
- [ ] New button still works for creating new prompts
- [ ] Save button still works for saving changes
