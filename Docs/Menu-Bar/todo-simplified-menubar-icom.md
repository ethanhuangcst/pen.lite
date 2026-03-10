# Simplify Menu Bar Icon - Task List

## Phase 1: Remove User-Related Properties
- Remove isLoggedIn property
- Remove userName property
- Remove currentUser property
- Remove databaseFailure property
- Update all references to removed properties

## Phase 2: Simplify App Mode Enum
- Update AppMode enum to only have online and offline cases
- Update all references to AppMode

## Phase 3: Simplify Core Methods
- Simplify setOnlineMode() method
- Simplify updateStatusIcon() method
- Simplify handleMenuBarClick() method
- Simplify setAppMode() method

## Phase 4: Remove Login/Logout Functionality
- Remove logout() method
- Remove openLoginWindow() method
- Remove setLoginStatus() method
- Remove createGlobalUserObject() method
- Remove loadAndTestAIConfigurations() method

## Phase 5: Update Menu Items
- Remove "Open TmpWindow" menu item
- Simplify right-click menu for online mode
- Simplify right-click menu for offline mode

## Phase 6: Update Initialization
- Remove login-related initialization code
- Simplify initialization to only set online/offline mode

## Phase 7: Testing
- Test online mode behavior
- Test offline mode behavior
- Test mode transition
- Test settings window
- Test exit functionality
