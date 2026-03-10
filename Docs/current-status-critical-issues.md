# Current Status: Critical Issues Fix

## ✅ Completed (2/5)

### Critical Issue 5: Pen.swift - tmpWindow cleanup ✅
- **Status**: Fixed
- **Change**: Removed `tmpWindow = nil` line
- **Impact**: Simple one-line fix

### Critical Issue 4: PenWindowService.swift - ContentHistoryModel ✅
- **Status**: Fixed
- **Change**: Removed ContentHistoryModel instantiation code
- **Impact**: Removed ~10 lines of code

---

## ❌ Remaining (3/5)

### Critical Issue 1: AIManager.swift - DatabaseConnectivityPool ⚠️

**Status**: In Progress
**Complexity**: HIGH
**Scope**: 51 database references across ~400 lines

**Files Affected**:
- AIManager.swift

**Changes Needed**:
1. Remove `databasePool` property
2. Remove all database connection handling
3. Remove all SQL queries
4. Update to use AIConnectionService for AI configurations
5. Remove user-specific methods (getConnections, saveConnection, etc.)

**Estimated Lines to Change**: ~400 lines

**Approach Options**:
- **Option A**: Complete rewrite using AIConnectionService
- **Option B**: Comment out database methods, add stubs
- **Option C**: Create new simplified AIManager

---

### Critical Issue 2: PenWindowService.swift - UserService ⚠️

**Status**: Pending
**Complexity**: MEDIUM-HIGH
**Scope**: 10+ references across multiple methods

**Specific Lines**:
- Line ~1207: `guard let aiManager = userService.aiManager else {`
- Line ~1216: `guard let user = userService.currentUser else {`
- Line ~1225: `let connections = try await aiManager.getConnections(for: user.id)`
- Line ~1237: `aiManager.configure(apiKey: connection.apiKey, providerName: connection.apiProvider, userId: user.id)`
- Line ~1294: `guard let selectedTitle = selectedTitle, let user = userService.currentUser else { return nil }`
- Line ~1325: `guard let selectedTitle = selectedTitle, let aiManager = userService.aiManager else { return }`
- Line ~1576: `if let user = self.userService.currentUser {`
- Line ~1587: `if let user = self.userService.currentUser, let profileImageData = user.profileImage, !profileImageData.isEmpty {`

**Changes Needed**:
1. Remove all `userService` references
2. Update AI configuration loading to use AIConnectionService
3. Remove user-specific logic
4. Update profile image handling

**Estimated Lines to Change**: ~50 lines

---

### Critical Issue 3: PenWindowService.swift - PromptsService ⚠️

**Status**: Pending
**Complexity**: MEDIUM
**Scope**: 1 reference

**Specific Line**:
- Line ~1297: `let prompts = try await promptsService.getPromptsByUserId(userId: user.id)`

**Changes Needed**:
1. Update to use PromptService.shared.getPrompts()

**Estimated Lines to Change**: ~5 lines

---

## 📊 Overall Progress

| Issue | Status | Complexity | Lines to Change |
|-------|--------|------------|-----------------|
| Issue 5 | ✅ Complete | Low | 1 |
| Issue 4 | ✅ Complete | Low | 10 |
| Issue 3 | ⏳ Pending | Medium | 5 |
| Issue 2 | ⏳ Pending | Medium-High | 50 |
| Issue 1 | ⏳ Pending | High | 400 |
| **Total** | **40%** | - | **~466 lines** |

---

## 🎯 Recommended Approach

### Phase 1: Quick Fix (Issue 3) - 5 minutes
- Update PromptsService reference to use PromptService

### Phase 2: Medium Complexity (Issue 2) - 20 minutes
- Update all UserService references in PenWindowService
- Remove user-specific logic
- Update to use file-based services

### Phase 3: High Complexity (Issue 1) - 45-60 minutes
- Complete rewrite of AIManager
- Remove all database code
- Integrate with AIConnectionService
- Test thoroughly

---

## ⚠️ Risk Assessment

**High Risk Areas**:
- AIManager rewrite affects core functionality
- User removal affects AI configuration loading
- Need to ensure file-based services work correctly

**Mitigation**:
- Test after each change
- Keep backup of working code
- Use incremental approach

---

## 📝 Next Steps

1. Fix Issue 3 (PromptsService) - Quick win
2. Fix Issue 2 (UserService) - Medium complexity
3. Fix Issue 1 (AIManager) - High complexity
4. Build and test
5. Remove unused code (if time permits)

**Estimated Total Time**: 70-90 minutes remaining
