# Fix Plan: Critical Compilation Issues

## Overview

The application has 5 critical compilation issues that must be fixed before it can build. This plan outlines the approach for each fix.

## Critical Issue 1: AIManager.swift - DatabaseConnectivityPool

### Problem
AIManager.swift has 51 references to `DatabaseConnectivityPool` and database operations.

### Solution Approach
**Option A: Complete Rewrite** (Recommended)
- Create a simplified AIManager that uses AIConnectionService
- Remove all database code
- Keep only essential AI functionality

**Option B: Stub Methods**
- Comment out all database methods
- Add TODO comments
- Get app compiling first

### Files to Update
- AIManager.swift (~400 lines to change)

---

## Critical Issue 2: PenWindowService.swift - UserService

### Problem
PenWindowService.swift has 10+ references to `userService.aiManager` and `userService.currentUser`.

### Solution Approach
1. Remove `userService` property (already done)
2. Update AI configuration loading to use `AIConnectionService.shared`
3. Remove user-specific AI connection logic
4. Update prompt selection to work without user context

### Specific Changes Needed

**Line ~1207**: AI enhancement method
```swift
// OLD:
guard let aiManager = userService.aiManager else { ... }
guard let user = userService.currentUser else { ... }
let connections = try await aiManager.getConnections(for: user.id)

// NEW:
let connections = try AIConnectionService.shared.getConnections()
```

**Line ~1294**: Prompt selection
```swift
// OLD:
guard let selectedTitle = selectedTitle, let user = userService.currentUser else { return nil }

// NEW:
guard let selectedTitle = selectedTitle else { return nil }
```

**Line ~1325**: Provider loading
```swift
// OLD:
guard let aiManager = userService.aiManager else { return }
let providers = try await aiManager.getProviders()

// NEW:
// Load providers from AIConnectionService or use defaults
```

---

## Critical Issue 3: PenWindowService.swift - PromptsService

### Problem
Line 1297 references `promptsService.getPromptsByUserId(userId: user.id)`.

### Solution Approach
Update to use `PromptService.shared.getPrompts()` (file-based).

```swift
// OLD:
let prompts = try await promptsService.getPromptsByUserId(userId: user.id)

// NEW:
let prompts = try PromptService.shared.getPrompts()
```

---

## Critical Issue 4: PenWindowService.swift - ContentHistoryModel

### Problem
Line 1252 references `ContentHistoryModel` which was deleted.

### Solution Approach
Remove content history functionality entirely (feature was removed in Phase 1).

```swift
// OLD:
let historyModel = ContentHistoryModel(...)

// NEW:
// Remove this code block entirely
```

---

## Critical Issue 5: Pen.swift - tmpWindow

### Problem
Line 393 has `tmpWindow = nil` but property was removed.

### Solution Approach
Remove the line entirely (cleanup code for deleted property).

---

## Implementation Order

### Phase 1: Quick Wins (5 minutes)
1. ✅ Fix Critical Issue 5: Remove tmpWindow cleanup in Pen.swift
2. ✅ Fix Critical Issue 4: Remove ContentHistoryModel code in PenWindowService.swift

### Phase 2: Medium Complexity (15 minutes)
3. Fix Critical Issue 3: Update PromptsService usage in PenWindowService.swift

### Phase 3: High Complexity (30-60 minutes)
4. Fix Critical Issue 2: Update all UserService references in PenWindowService.swift
5. Fix Critical Issue 1: Rewrite AIManager.swift to use file-based storage

---

## Risk Assessment

**Low Risk**:
- Issues 3, 4, 5 - Simple removals/updates

**Medium Risk**:
- Issue 2 - Requires understanding AI flow

**High Risk**:
- Issue 1 - Major rewrite of AIManager, affects core functionality

---

## Testing Strategy

After each fix:
1. Build the project
2. Check for new compilation errors
3. Verify no regressions

After all fixes:
1. Run the application
2. Test basic AI enhancement functionality
3. Verify file-based storage works

---

## Fallback Plan

If fixes are too complex:
1. Comment out broken methods temporarily
2. Get app compiling
3. Restore functionality incrementally
4. Use stub implementations where needed

---

## Estimated Time

- **Quick wins**: 5 minutes
- **Medium complexity**: 15 minutes
- **High complexity**: 45-60 minutes
- **Testing**: 15 minutes
- **Total**: 80-95 minutes

## Success Criteria

- ✅ Application compiles without errors
- ✅ Application launches successfully
- ✅ Menu bar icon works
- ✅ Basic AI enhancement works with file-based storage
- ✅ No runtime crashes
