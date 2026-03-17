# System Config Service Design

## Overview

This document describes the design for the `SystemConfigService` which manages system configurations stored locally. The service provides centralized configuration management for the application.

## Design of SystemConfigService

### Architecture

- **Singleton Pattern**: The service follows the singleton pattern to ensure a single instance throughout the application lifecycle.
- **Local Storage**: Uses UserDefaults for simple configuration storage.
- **Caching**: Caches configuration values in memory for fast access during runtime.
- **Lazy Loading**: Loads configuration only when needed.

### Class Structure

```swift
class SystemConfigService {
    static let shared = SystemConfigService()
    
    // Default prompt settings
    var DEFAULT_PROMPT_NAME: String? = "Refine English"
    var DEFAULT_PROMPT_TEXT: String? = "Refine English for the following text: "
    
    private let defaults = UserDefaults.standard
    
    private init() {
        loadConfig()
    }
    
    func loadConfig() {
        // Load configuration from UserDefaults
    }
    
    func updateConfig() {
        // Update configuration in UserDefaults
    }
    
    // Default prompt methods
    func getDefaultPrompt() -> (name: String, text: String) {
        // Return default prompt as tuple
    }
    
    func setDefaultPrompt(name: String, text: String) {
        // Update default prompt values
    }
}
```

### Key Methods

1. **loadConfig()**: Loads configuration from UserDefaults.
2. **updateConfig()**: Updates the configuration in UserDefaults with current values.
3. **getDefaultPrompt()**: Returns the default prompt as a tuple of (name, text).
4. **setDefaultPrompt(name: String, text: String)**: Updates the default prompt values in memory and persists them.

## Configuration Storage

### UserDefaults Keys

| Key | Type | Description |
|-----|------|-------------|
| `defaultPromptName` | String | Name of the default prompt |
| `defaultPromptText` | String | Text of the default prompt |
| `inputMode` | String | Last used input mode (auto/manual) |

## Impact Analysis

### Positive Impact

1. **Simplified Architecture**: No database dependency, all configuration stored locally.
2. **Fast Access**: In-memory caching provides instant access to configuration values.
3. **Reliability**: UserDefaults is highly reliable and persistent across app restarts.
4. **Offline-First**: All configuration works without internet connection.

### Potential Risks

1. **Limited Storage**: UserDefaults is not suitable for large amounts of data.
2. **No Sync**: Configuration is not synced across devices.

### Mitigation Strategies

1. **Use for Small Data Only**: Only store small configuration values in UserDefaults.
2. **Document Limitations**: Make it clear that configuration is local-only.

## Integration Points

### External Services

- **PromptService**: Uses SystemConfigService for default prompt settings
- **PenWindowService**: Uses SystemConfigService for input mode persistence

### UI Components

- **GeneralTabView**: May use SystemConfigService for general settings

## Conclusion

The `SystemConfigService` provides a simple and reliable way to manage system configurations locally. By using UserDefaults and in-memory caching, it offers fast access to configuration values while maintaining a clean architecture that fits the offline-first design of Pen Lite.
