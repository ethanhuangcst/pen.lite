# Full Code Review: References to Removed Functionalities

## Executive Summary

After comprehensive code review, I found **multiple categories** of references to removed functionalities that will cause compilation errors or are unnecessary code remnants.

---

## 🔴 Critical Issues - Will Cause Compilation Errors

### 1. AIManager.swift - Database References

**File**: [AIManager.swift](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/AIManager.swift)

**Database Connectivity** (14 occurrences):
- Line 302: `private var databasePool: DatabaseConnectivityPool`
- Line 315: `self.databasePool = DatabaseConnectivityPool.shared`
- Line 660-663: MySQL connection handling
- Line 717: `connection.execute(query: query)`
- Line 831: `connection.execute(query: query)`
- Line 892: `connection.execute(query: query)`
- Line 915: `connection.execute(query: query)`
- Line 938: `connection.execute(query: query)`
- Line 977-980: MySQL connection handling
- Line 1031: `connection.execute(query: parameterizedQuery)`

**Database Methods** (6 methods):
- Line 805: `getConnections(for userId: Int)` - User-specific AI connections
- Line 878: `createConnection(userId: Int, ...)` - Create user-specific connection
- Line 901: `deleteConnection(_ connectionId: Int)` - Delete connection from database
- Line 924: `updateConnection(id: Int, ...)` - Update connection in database

**Database Row Parsing** (7 occurrences):
- Line 17: `fromDatabaseRow(_ row: [String: Any])` - AIConfiguration
- Line 76: `fromDatabaseRow(_ row: [String: Any])` - AIModelProvider
- Line 339: `AIConfiguration.fromDatabaseRow(configuration)`
- Line 696: `AIModelProvider.fromDatabaseRow(rowData)`
- Line 722: `AIModelProvider.fromDatabaseRow(row)`
- Line 836: `AIConfiguration.fromDatabaseRow(row)`
- Line 1015: `AIModelProvider.fromDatabaseRow(rowData)`
- Line 1037: `AIModelProvider.fromDatabaseRow(results[0])`

**Impact**: ❌ Will not compile - references deleted `DatabaseConnectivityPool` class

---

## ⚠️ Medium Priority - Unnecessary Code Remnants

### 2. Prompt.swift - User ID References

**File**: [Prompt.swift](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Models/Prompt.swift)

**User ID Property** (40 occurrences):
- Line 8: `let userId: Int` - Property definition
- Line 16: `init(id: String, userId: Int, ...)` - Constructor parameter
- Line 18: `self.userId = userId` - Property assignment
- Line 43-50: Database row parsing for user_id
- Line 89: `userId: userId` - Constructor call
- Line 93: `createNewPrompt(userId: Int, ...)` - Method parameter
- Line 96: `userId: userId` - Constructor call
- Line 136: `userId: 0` - System-wide default
- Line 156: `userId: 0` - System-wide default

**Database Methods**:
- Line 30: `static func fromDatabaseRow(_ row: [String: Any]) -> Prompt?` - Database parsing method

**Impact**: ⚠️ Will compile but has unnecessary user-related code

### 3. PromptService.swift - User ID Hardcoding

**File**: [PromptService.swift](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/PromptService.swift)

**Hardcoded User ID**:
- Line 23: `userId: 1, // Default user ID for local storage`

**Impact**: ⚠️ Works but references removed user concept

### 4. PromptsTabView.swift - User ID Hardcoding

**File**: [PromptsTabView.swift](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/PromptsTabView.swift)

**Hardcoded User IDs**:
- Line 262: `userId: 1,`
- Line 272: `userId: 1,`

**Impact**: ⚠️ Works but references removed user concept

### 5. NewOrEditPrompt.swift - User ID Reference

**File**: [NewOrEditPrompt.swift](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/NewOrEditPrompt.swift)

**User ID Usage**:
- Line 210: `userId: existingPrompt.userId,`
- Line 223: `userId: 0, // Will be set by the caller`

**Impact**: ⚠️ Works but references removed user concept

### 6. SystemConfigService.swift - Content History References

**File**: [SystemConfigService.swift](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/SystemConfigService.swift)

**Content History Methods**:
- Line 99: `func getContentHistoryCount(level: String) -> Int`
- Line 112: `func setContentHistoryCount(level: String, value: Int)`

**Impact**: ⚠️ References removed ContentHistoryModel functionality

---

## ✅ Acceptable References (Not Related to Removed Features)

### Authentication-Related (AI Provider Auth)

**Files**: Multiple files

These are **NOT** related to user authentication - they're for AI provider API authentication:
- `requiresAuth` - Whether AI provider requires API key
- `authHeader` - Header name for API key
- `Authorization` header - For AI API calls
- `.unauthorized` error - AI API authentication failure

**Impact**: ✅ These are correct and should remain

### Window Management

**Files**: BaseWindow.swift, WindowManager.swift

- `canBecomeVisibleWithoutLogin = true` - macOS window property (not user login)
- `registerWindow`, `unregisterWindow` - Window lifecycle management

**Impact**: ✅ These are correct and should remain

---

## Summary Statistics

| Category | Count | Impact | Priority |
|----------|-------|--------|----------|
| **Database References** | 27 | ❌ Compilation Error | Critical |
| **User ID References** | 15 | ⚠️ Unnecessary Code | Medium |
| **Content History** | 2 | ⚠️ Unnecessary Code | Medium |
| **Acceptable References** | 69 | ✅ Correct | N/A |

---

## Detailed Breakdown by File

### AIManager.swift - 27 Issues
- 14 database connectivity references
- 6 database methods
- 7 database row parsing methods

### Prompt.swift - 10 Issues
- 1 userId property
- 9 userId-related code

### PromptService.swift - 1 Issue
- 1 hardcoded userId

### PromptsTabView.swift - 2 Issues
- 2 hardcoded userIds

### NewOrEditPrompt.swift - 2 Issues
- 2 userId references

### SystemConfigService.swift - 2 Issues
- 2 content history methods

---

## Recommended Actions

### Priority 1: Fix AIManager.swift (Critical)
1. Remove all `DatabaseConnectivityPool` references
2. Remove all database connection handling
3. Remove all SQL queries
4. Remove `fromDatabaseRow` methods
5. Remove user-specific connection methods
6. Update to use file-based storage (AIConnectionService)

### Priority 2: Clean Up User ID References (Medium)
1. Remove `userId` property from Prompt model
2. Remove `fromDatabaseRow` method from Prompt model
3. Update PromptService to not use userId
4. Update PromptsTabView to not use userId
5. Update NewOrEditPrompt to not use userId

### Priority 3: Remove Content History (Medium)
1. Remove content history methods from SystemConfigService

---

## Files Requiring Changes

**Critical (Blocking Compilation)**:
1. AIManager.swift - 27 changes needed

**Medium Priority (Code Cleanup)**:
2. Prompt.swift - 10 changes
3. PromptService.swift - 1 change
4. PromptsTabView.swift - 2 changes
5. NewOrEditPrompt.swift - 2 changes
6. SystemConfigService.swift - 2 changes

**Total**: 6 files, 44 changes needed

---

## Current Status

- **Application Status**: ❌ Cannot compile
- **Blocking Issues**: 1 file (AIManager.swift)
- **Cleanup Issues**: 5 files (unnecessary code)
- **Estimated Work**: 2-3 hours for complete cleanup
