# Plan: Update PenWindowService.swift

## Overview
PenWindowService.swift has 19 references to UserService and user-related code that need to be removed or updated.

## Changes Required

### 1. Remove UserService Property
**Current** (Line 14):
```swift
private var userService: UserService
```

**Action**: Remove this property

### 2. Remove UserService Initialization
**Current** (Line 29):
```swift
self.userService = UserService.shared
```

**Action**: Remove this line

### 3. Update Initializer Logging
**Current** (Line 32):
```swift
print("[PenWindowService] Initializer called, currentUser: \(userService.currentUser?.name ?? "nil")")
```

**Action**: Update to remove user reference

### 4. Remove User Authentication Checks
**Current** (Lines 168-177):
```swift
let isLoggedIn = userService.isLoggedIn
let isOnline = userService.isOnline

if isOnline && isLoggedIn {
    if userService.currentUser == nil {
        showDefaultUI()
        WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "pen_load_login_error"))
        return
    }
} else if isOnline && !isLoggedIn {
    showDefaultUI()
    WindowManager.shared.displayPopupMessage(LocalizationService.shared.localizedString(for: "pen_not_logged_in_error"))
    return
}
```

**Action**: Remove entire user authentication check block

### 5. Remove User Profile Image Handling
**Current** (Lines 697, 1604, 1615):
```swift
if let user = userService.currentUser, let profileImageData = user.profileImage, !profileImageData.isEmpty {
```

**Action**: Remove user profile image code

### 6. Remove User-Specific AI Configuration
**Current** (Lines 1282, 1291, 1300, 1312):
```swift
guard let aiManager = userService.aiManager else { ... }
guard let user = userService.currentUser else { ... }
let connections = try await aiManager.getConnections(for: user.id)
aiManager.configure(apiKey: connection.apiKey, providerName: connection.apiProvider, userId: user.id)
```

**Action**: Update to use AIConnectionService instead

### 7. Remove User from Prompt Selection
**Current** (Lines 1369, 1400):
```swift
guard let selectedTitle = selectedTitle, let user = userService.currentUser else { return nil }
guard let selectedTitle = selectedTitle, let aiManager = userService.aiManager else { return }
```

**Action**: Remove user dependency

## Implementation Strategy

1. Remove `userService` property
2. Update initializer to remove user reference
3. Remove `loadUserInformation()` method entirely
4. Update AI configuration loading to use AIConnectionService
5. Remove user profile image handling
6. Update prompt selection to remove user dependency
7. Test thoroughly

## Risk Assessment
- **High Risk**: Changes affect core functionality
- **Testing Required**: Need to verify AI enhancement still works
- **Fallback**: Keep backup of original file before changes
