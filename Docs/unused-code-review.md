# Full Code Review: Unused Code Findings

## Executive Summary

Comprehensive code review identified **34 instances** of unused code across the codebase, including:
- **5 critical issues** (references to deleted classes - will cause compilation errors)
- **25 unused methods** (dead code)
- **4 unused properties** (never referenced)

## Critical Issues - References to Deleted Classes

### 1. AIManager.swift - DatabaseConnectivityPool
- **File**: [AIManager.swift:302](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/AIManager.swift#L302)
- **Line 302**: `private var databasePool: DatabaseConnectivityPool`
- **Line 315**: `self.databasePool = DatabaseConnectivityPool.shared`
- **Type**: Missing class reference
- **Issue**: References `DatabaseConnectivityPool` class which was deleted in Phase 1
- **Impact**: ❌ Will cause compilation error

### 2. PenWindowService.swift - UserService
- **File**: [PenWindowService.swift:1207](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/PenWindowService.swift#L1207)
- **Lines**: 1207, 1216, 1294, 1325, 1529, 1540
- **Type**: Missing class reference
- **Issue**: References `userService.aiManager`, `userService.currentUser` which were deleted
- **Impact**: ❌ Will cause compilation error

### 3. PenWindowService.swift - PromptsService
- **File**: [PenWindowService.swift:1297](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/PenWindowService.swift#L1297)
- **Line 1297**: `let prompts = try await promptsService.getPromptsByUserId(userId: user.id)`
- **Type**: Missing method
- **Issue**: References `promptsService.getPromptsByUserId` which was deleted
- **Impact**: ❌ Will cause compilation error

### 4. PenWindowService.swift - ContentHistoryModel
- **File**: [PenWindowService.swift:1252](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/PenWindowService.swift#L1252)
- **Line 1252**: `let historyModel = ContentHistoryModel(...)`
- **Type**: Missing class reference
- **Issue**: References `ContentHistoryModel` class which was deleted in Phase 1
- **Impact**: ❌ Will cause compilation error

### 5. Pen.swift - tmpWindow
- **File**: [Pen.swift:393](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L393)
- **Line 393**: `tmpWindow = nil`
- **Type**: Undeclared property
- **Issue**: References `tmpWindow` property which was removed but cleanup code remains
- **Impact**: ❌ Will cause compilation error

---

## Unused Methods (Dead Code)

### Pen.swift

**6. addFooterContainer**
- **File**: [Pen.swift:124-220](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L124-L220)
- **Type**: Unused method
- **Issue**: Method is defined but never called
- **Reason**: Duplicate of same method in PenWindowService.swift

**7. positionWindowRelativeToMouseCursor**
- **File**: [Pen.swift:398-410](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L398-L410)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**8. openPenAI**
- **File**: [Pen.swift:433-459](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L433-L459)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**9. handlePasteButton**
- **File**: [Pen.swift:572-576](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L572-L576)
- **Type**: Unused method
- **Issue**: Method is defined but never called (empty implementation)

**10. openTestWindow**
- **File**: [Pen.swift:346-350](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L346-L350)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**11. closeWindow**
- **File**: [Pen.swift:493-495](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L493-L495)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**12. setAppMode**
- **File**: [Pen.swift:499-509](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L499-L509)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**13. updateMenuBarIcon**
- **File**: [Pen.swift:512-514](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L512-L514)
- **Type**: Unused method
- **Issue**: Method is defined but never called

### BaseWindow.swift

**14. getDefaultMainWindowWidth**
- **File**: [BaseWindow.swift:514-516](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L514-L516)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**15. buttonAction**
- **File**: [BaseWindow.swift:519-521](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L519-L521)
- **Type**: Unused method
- **Issue**: Method is defined but never called (empty implementation)

**16. button1Action**
- **File**: [BaseWindow.swift:534-536](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L534-L536)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**17. createTestWindow**
- **File**: [BaseWindow.swift:539-649](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L539-L649)
- **Type**: Unused method
- **Issue**: Method is defined but never called (111 lines of dead code)

**18. findFirstActiveButton**
- **File**: [BaseWindow.swift:501-511](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L501-L511)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**19. displayPopupMessage**
- **File**: [BaseWindow.swift:378-498](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L378-L498)
- **Type**: Unused method
- **Issue**: Method is defined but never called (duplicate of WindowManager.displayPopupMessage)

### Other Files

**20. NewOrEditPrompt.swift - findFirstFocusableElement**
- **File**: [NewOrEditPrompt.swift:266-290](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/NewOrEditPrompt.swift#L266-L290)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**21. PromptsTabView.swift - loadMockData**
- **File**: [PromptsTabView.swift:258-285](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/PromptsTabView.swift#L258-L285)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**22. Prompt.swift - getMarkdownText**
- **File**: [Prompt.swift:107-109](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Models/Prompt.swift#L107-L109)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**23. Prompt.swift - loadDefaultPrompt**
- **File**: [Prompt.swift:112-148](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Models/Prompt.swift#L112-L148)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**24. Prompt.swift - createFallbackDefaultPrompt**
- **File**: [Prompt.swift:151-164](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Models/Prompt.swift#L151-L164)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**25. ColorService.swift - isDarkMode**
- **File**: [ColorService.swift:52-54](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/ColorService.swift#L52-L54)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**26. ResourceService.swift - resourceExists**
- **File**: [ResourceService.swift:42-45](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/ResourceService.swift#L42-L45)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**27. ResourceService.swift - loadImage**
- **File**: [ResourceService.swift:47-50](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/ResourceService.swift#L47-L50)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**28. ResourceService.swift - loadSVG**
- **File**: [ResourceService.swift:52-55](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/ResourceService.swift#L52-L55)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**29. ResourceService.swift - loadPNG**
- **File**: [ResourceService.swift:57-60](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/ResourceService.swift#L57-L60)
- **Type**: Unused method
- **Issue**: Method is defined but never called

**30. FileStorageService.swift - getAppSettingsFile**
- **File**: [FileStorageService.swift:42-44](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/FileStorageService.swift#L42-L44)
- **Type**: Unused method
- **Issue**: Method is defined but never called

---

## Unused Properties

**31. Pen.swift - windowWidth, windowHeight, mouseOffset**
- **File**: [Pen.swift:21-23](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/App/Pen.swift#L21-L23)
- **Type**: Unused properties
- **Issue**: Properties are defined but never used

**32. SettingsWindow.swift - mouseOffset**
- **File**: [SettingsWindow.swift:6](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/SettingsWindow.swift#L6)
- **Type**: Unused property
- **Issue**: Property is defined but never used

**33. BaseWindow.swift - defaultMainWindowWidth**
- **File**: [BaseWindow.swift:10](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Views/BaseWindow.swift#L10)
- **Type**: Unused property
- **Issue**: Property is defined but only used in unused method

**34. ColorService.swift - textBackgroundColorCGColor**
- **File**: [ColorService.swift:40-42](file:///Users/ethanhuang/code/pen.lite/mac-app/pen.lite/Sources/Services/ColorService.swift#L40-L42)
- **Type**: Unused property
- **Issue**: Property is defined but never used

---

## Summary Statistics

| Category | Count | Impact |
|----------|-------|--------|
| **Critical Issues** | 5 | ❌ Compilation errors |
| **Unused Methods** | 25 | ⚠️ Dead code |
| **Unused Properties** | 4 | ⚠️ Dead code |
| **Total** | 34 | Mixed |

## Files Most Affected

1. **Pen.swift**: 8 unused methods + 3 unused properties = 11 issues
2. **BaseWindow.swift**: 6 unused methods + 1 unused property = 7 issues
3. **PenWindowService.swift**: 4 critical issues (missing class references)
4. **AIManager.swift**: 1 critical issue (missing class reference)
5. **Prompt.swift**: 3 unused methods
6. **ResourceService.swift**: 4 unused methods

## Recommendations

### Priority 1: Fix Critical Issues (Blocking Compilation)
1. Remove all references to `DatabaseConnectivityPool` in AIManager.swift
2. Remove all references to `UserService` in PenWindowService.swift
3. Remove all references to `PromptsService` methods in PenWindowService.swift
4. Remove all references to `ContentHistoryModel` in PenWindowService.swift
5. Remove remaining `tmpWindow` cleanup code in Pen.swift

### Priority 2: Remove Dead Code
1. Remove all 25 unused methods
2. Remove all 4 unused properties
3. This will reduce code complexity and maintenance burden

### Priority 3: Consolidate Duplicate Functionality
1. Consolidate popup message display (BaseWindow vs WindowManager)
2. Consolidate window positioning methods
3. Remove test/debug methods that are no longer needed

## Estimated Code Reduction

- **Critical fixes**: ~500 lines to update/remove
- **Unused methods**: ~800 lines to remove
- **Unused properties**: ~10 lines to remove
- **Total estimated reduction**: ~1,310 lines of code

This cleanup will significantly improve code maintainability and reduce confusion.
