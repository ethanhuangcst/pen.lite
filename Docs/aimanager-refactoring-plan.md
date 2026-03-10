# AIManager.swift Refactoring Plan

## Current State Analysis

**File Size**: ~1000+ lines
**Database References**: 27 occurrences
**Complexity**: HIGH

### Current Structure:
1. **Nested Structs** (Lines 8-296):
   - `AIConfiguration` - with database parsing methods
   - `AIModelProvider` - with database parsing methods
   - `AIProvider` - public struct
   - `ProviderStrategy` - protocol and implementations

2. **Properties** (Lines 298-310):
   - `databasePool: DatabaseConnectivityPool` ❌
   - `currentConfiguration: AIConfiguration?`
   - `cachedProviders: [AIModelProvider]?`
   - `strategies: [String: ProviderStrategy]`

3. **Methods**:
   - Database methods (Lines 805-1037) ❌
   - Core AI methods (Lines 320-800) ✅ Keep
   - Helper methods ✅ Keep

## Refactoring Strategy

### Approach: Simplified AIManager

**Goal**: Remove all database code while preserving core AI functionality

### Phase 1: Remove Database Dependencies

1. **Remove databasePool property** (Line 302)
2. **Remove database initialization** (Line 315)
3. **Remove userId parameter** from configure method (Line 326)

### Phase 2: Update Nested Structs

1. **AIConfiguration**:
   - Remove `fromDatabaseRow` method (Lines 17-62)
   - Remove `userId` property (Line 10)
   - Simplify to basic struct

2. **AIModelProvider**:
   - Remove `fromDatabaseRow` method (Lines 76-150)
   - Keep basic struct for provider info

### Phase 3: Remove Database Methods

Remove these methods entirely (Lines 805-1037):
- `getConnections(for userId: Int)` ❌
- `createConnection(userId: Int, ...)` ❌
- `deleteConnection(_ connectionId: Int)` ❌
- `updateConnection(id: Int, ...)` ❌
- `loadProviderByName()` - Update to use file storage
- `loadAllProviders()` - Update to use file storage

### Phase 4: Update Core Methods

1. **configure()** - Remove userId parameter
2. **loadProviderByName()** - Use AIConnectionService instead of database
3. **loadAllProviders()** - Use AIConnectionService instead of database

## Simplified AIManager Structure

```swift
public class AIManager {
    
    // MARK: - Private Nested Types
    
    private struct AIConfiguration {
        var apiKey: String
        var apiProvider: String
        let createdAt: Date
        var updatedAt: Date?
    }
    
    private struct AIModelProvider {
        let name: String
        let baseURLs: [String: String]
        let defaultModel: String
        let requiresAuth: Bool
        let authHeader: String
    }
    
    // MARK: - Private Properties
    
    private var strategies: [String: ProviderStrategy] = [:]
    private var currentConfiguration: AIConfiguration?
    private var _isInitialized: Bool = false
    
    // MARK: - Public Properties
    
    public var isInitialized: Bool {
        return _isInitialized
    }
    
    // MARK: - Initialization
    
    public init() {
        // No database initialization needed
    }
    
    public func initialize() {
        _isInitialized = true
    }
    
    // MARK: - Public Methods
    
    public func configure(apiKey: String, providerName: String) {
        let configuration = AIConfiguration(
            apiKey: apiKey,
            apiProvider: providerName,
            createdAt: Date(),
            updatedAt: nil
        )
        currentConfiguration = configuration
    }
    
    // Core AI methods remain unchanged:
    // - sendChat()
    // - testConnection()
    // - AITestCall()
    // - performRequest()
    // - etc.
    
    // MARK: - Private Helper Methods
    
    private func loadProviderByName(_ name: String) async throws -> AIModelProvider? {
        // Load from AIConnectionService instead of database
        let connections = try AIConnectionService.shared.getConnections()
        guard let connection = connections.first(where: { $0.apiProvider == name }) else {
            return nil
        }
        
        return AIModelProvider(
            name: connection.apiProvider,
            baseURLs: ["default": connection.apiUrl],
            defaultModel: connection.model,
            requiresAuth: true,
            authHeader: "Authorization"
        )
    }
}
```

## Implementation Steps

### Step 1: Create Backup
- Keep current AIManager.swift as AIManager.swift.backup

### Step 2: Remove Database Code
1. Remove `databasePool` property
2. Remove database initialization
3. Remove `fromDatabaseRow` methods
4. Remove userId from AIConfiguration
5. Remove all database query methods

### Step 3: Update Methods
1. Update `configure()` to remove userId
2. Update `loadProviderByName()` to use AIConnectionService
3. Update any other methods that reference database

### Step 4: Test
1. Build the application
2. Test basic AI functionality
3. Verify file-based storage works

## Risk Assessment

**High Risk Areas**:
- Provider loading logic changes
- Configuration management changes
- Core AI functionality must remain intact

**Mitigation**:
- Keep backup of original file
- Test thoroughly after changes
- Incremental approach

## Estimated Effort

- **Code removal**: ~400 lines
- **Code updates**: ~50 lines
- **Testing**: 15-30 minutes
- **Total**: 45-60 minutes

## Success Criteria

- ✅ Application compiles without errors
- ✅ No database references remain
- ✅ AI functionality works with file-based storage
- ✅ No runtime errors
