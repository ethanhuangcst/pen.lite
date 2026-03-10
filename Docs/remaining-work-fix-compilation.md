# Remaining Work: Fix Compilation Errors

## Current Status

### ✅ Completed:
1. **Pen.swift** - Removed TmpWindow references
2. **PenWindowService.swift** - Partially updated:
   - Removed `userService` and `promptsService` properties
   - Removed `loadUserInformation()` method
   - Simplified `addUserLabelContainer()` to remove user profile handling

### ❌ Still Broken - Will Not Compile:

## Critical Issues

### 1. PenWindowService.swift - Still Has UserService References

**Lines with errors**:
- Line 1207: `guard let aiManager = userService.aiManager else {`
- Line 1216: `guard let user = userService.currentUser else {`
- Line 1225: `let connections = try await aiManager.getConnections(for: user.id)`
- Line 1237: `aiManager.configure(apiKey: connection.apiKey, providerName: connection.apiProvider, userId: user.id)`
- Line 1294: `guard let selectedTitle = selectedTitle, let user = userService.currentUser else { return nil }`
- Line 1400: `guard let selectedTitle = selectedTitle, let aiManager = userService.aiManager else { return }`
- Line 1576: `if let user = self.userService.currentUser {`
- Line 1587: `if let user = self.userService.currentUser, let profileImageData = user.profileImage, !profileImageData.isEmpty {`

**Problem**: These lines reference `userService` which was deleted in Phase 1.

**Solution Required**:
- Remove all `userService` references
- Update AI configuration loading to use `AIConnectionService.shared`
- Remove user-specific AI connection logic
- Update prompt selection to work without user context

### 2. AIManager.swift - Has Database References

**51 occurrences** of database-related code:
- DatabaseConnectivityPool references
- MySQL connection handling
- SQL queries for AI providers and connections
- User-specific AI connection methods

**Problem**: References deleted `DatabaseConnectivityPool` class.

**Solution Required**:
- Remove all database code
- Update to use file-based storage via `AIConnectionService`
- Remove `getConnections(for userId:)` method
- Remove user-specific methods

## Recommended Approach

Given the complexity and the number of changes required, I recommend:

### Option 1: Incremental Fix (Current Approach)
- Continue making small, targeted changes
- Test after each change
- Risk: Time-consuming, may introduce bugs

### Option 2: Create Stub/Simplified Versions
- Create simplified versions of PenWindowService and AIManager
- Focus on core functionality only
- Remove all complex user/database logic
- Risk: May lose some functionality temporarily

### Option 3: Comment Out Broken Code
- Comment out all methods that reference deleted classes
- Get app compiling first
- Gradually restore functionality
- Risk: App will have reduced functionality

## Files Requiring Updates

### High Priority (Blocking Compilation):
1. **PenWindowService.swift** - 10 remaining references to deleted classes
2. **AIManager.swift** - 51 database-related references

### Medium Priority (Will Compile But Has Unnecessary Code):
3. **Prompt.swift** - Database methods and userId property

## Estimated Work

- **PenWindowService.swift**: ~200 lines need updating
- **AIManager.swift**: ~400 lines need updating  
- **Prompt.swift**: ~70 lines need updating

## Next Steps

1. Decide on approach (incremental vs. rewrite vs. comment-out)
2. Fix PenWindowService.swift compilation errors
3. Fix AIManager.swift compilation errors
4. Clean up Prompt.swift
5. Build and test

## Current Blockers

The application **cannot compile** until:
1. All `userService` references are removed from PenWindowService.swift
2. All `DatabaseConnectivityPool` references are removed from AIManager.swift

Without these fixes, the application is in a broken state.
