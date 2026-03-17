# Global Objects Architecture

This document describes the global objects and singleton services used in the Pen Lite application.

## Singleton Objects

### Core Services (Global State Required)

| Object Name | Location | Purpose |
|------------|----------|--------|
| `KeychainService.shared` | Sources/Services/KeychainService.swift | Secure credential storage for sensitive data |
| `LocalizationService.shared` | Sources/Services/LocalizationService.swift | Global resource for UI localization and language switching |
| `FileStorageService.shared` | Sources/Services/FileStorageService.swift | Local file storage management |
| `ResourceService.shared` | Sources/Services/ResourceService.swift | App bundle resource access |

### Feature Services (Instantiated Per Use)

| Object Name | Location | Purpose |
|------------|----------|--------|
| `AIConnectionService.shared` | Sources/Services/AIConnectionService.swift | Manages AI configurations and API calls |
| `PenWindowService.shared` | Sources/Services/PenWindowService.swift | Manages the Pen application window |
| `PromptService.shared` | Sources/Services/PromptService.swift | Manages user prompts CRUD operations |
| `SystemConfigService.shared` | Sources/Services/SystemConfigService.swift | System configuration values |
| `ColorService.shared` | Sources/Services/ColorService.swift | UI color management for light/dark mode |
| `InitializationService.shared` | Sources/Services/InitializationService.swift | App initialization and startup logic |
| `InternetConnectivityServiceTest.shared` | Sources/Services/InternetConnectivityServiceTest.swift | Tests internet connectivity |

## Static Properties

| Property Name | Type | Location | Purpose |
|--------------|------|----------|--------|
| `NewOrEditPrompt.isWindowOpen` | Bool | Sources/Views/NewOrEditPrompt.swift | Tracks if the NewOrEditPrompt window is currently open |
| `NewOrEditPrompt.currentInstance` | NewOrEditPrompt? | Sources/Views/NewOrEditPrompt.swift | Holds the current instance of NewOrEditPrompt window |
| `BaseWindow.messageQueue` | [String] | Sources/Views/BaseWindow.swift | Queue for popup messages |
| `BaseWindow.isDisplayingMessage` | Bool | Sources/Views/BaseWindow.swift | Tracks if a popup message is currently being displayed |

## Global State Management

The application uses a combination of singleton services to manage global state:

### AI Configuration State
Managed by `AIConnectionService.shared`
- AI provider configurations
- API keys
- Connection status

### Prompt State
Managed by `PromptService.shared`
- User prompts
- System prompts
- Default prompts

### Window State
Managed by `PenWindowService.shared`
- Window position and visibility
- UI component states

### File Storage State
Managed by `FileStorageService.shared`
- Local file paths
- Directory management

## Architecture Decisions

### Why Singletons?

1. **Core Services** - Services like `LocalizationService` and `FileStorageService` provide configuration and resources that should have a single source of truth.

2. **Feature Services** - Services like `AIConnectionService`, `PromptService`, and `PenWindowService` use singletons for convenience but could be refactored to dependency injection if needed.

### Design Considerations

- **Thread Safety**: Some singletons may require thread safety considerations when accessed from multiple threads
- **Memory Management**: Singletons persist for the lifetime of the application
- **Testing**: Singletons introduce global state which can make unit testing more challenging
- **Future Refactoring**: Feature services could be converted to dependency injection for better testability

## Usage Patterns

Global objects are accessed using the singleton pattern:

```swift
// Accessing a singleton service
let prompts = PromptService.shared.getPrompts()

// Calling singleton methods
AIConnectionService.shared.callAI(prompt: "Hello")

// Setting global state
LocalizationService.shared.setLanguage(.chineseSimplified)
```

## Service Dependencies

```
AIConnectionService
    └── FileStorageService (for loading configurations)

PromptService
    └── FileStorageService (for loading prompts)

PenWindowService
    └── depends on AIConnectionService
    └── depends on PromptService

InitializationService
    └── orchestrates all services during app startup
```
