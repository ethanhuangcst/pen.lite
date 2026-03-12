# AI Manager Architecture

This document describes the architecture of the AI integration system in the Pen.Lite application.

## Overview

The AIManager class centralizes the management of AI interactions in the Pen.Lite application. It follows a singleton pattern and provides a unified interface for interacting with various AI providers (OpenAI, DeepSeek, Qwen, etc.).

**Key Change**: AI configurations are stored locally in JSON files, not in a database. No authentication or user management is required.

## Architecture

```
App
├── InitializationService
│   └── Creates default configurations on first launch
├── AIManager (Singleton)
│   ├── Provider Configuration (from local file)
│   ├── Request Builder
│   ├── Transport Layer
│   ├── Response Parser
│   ├── Error Mapper
│   └── Provider Strategy
└── AIConnectionService
    └── CRUD operations for local JSON file
```

## Core Components

### 1. FileStorageService

**Location**: `/mac-app/pen.lite/Sources/Services/FileStorageService.swift`

Manages local file storage in the Application Support directory:

| Method | Purpose |
|--------|---------|
| `getAIConnectionsFile()` | Returns URL to `ai-connections.json` |
| `getPromptsDirectory()` | Returns URL to prompts directory |
| `readFile(at:)` | Reads file data |
| `writeFile(data:to:)` | Writes data to file |
| `fileExists(at:)` | Checks if file exists |

**Storage Location**: `~/Library/Application Support/Pen.Lite/`

```
Pen.Lite/
├── config/
│   ├── ai-connections.json
│   └── app-settings.json
└── prompts/
    └── *.md
```

### 2. AIConnectionService

**Location**: `/mac-app/pen.lite/Sources/Services/AIConnectionService.swift`

Manages AI configuration CRUD operations:

| Method | Purpose |
|--------|---------|
| `getConnections()` | Load all configurations from JSON file |
| `saveConnections(_:)` | Save configurations to JSON file |
| `deleteConnection(id:)` | Delete a configuration by ID |
| `getDefaultConnection()` | Get the default configuration |

### 3. AIManager Service

**Location**: `/mac-app/pen.lite/Sources/Services/AIManager.swift`

The AIManager is a singleton service that handles all AI-related operations:

| Method | Purpose |
|--------|---------|
| `callAI(prompt:content:)` | Main method for AI content enhancement |
| `testConnection(connection:)` | Test AI provider connection |
| `createProvider(from:)` | Create AIModelProvider from AIConnectionModel |

### 4. AIConnectionModel

**Location**: `/mac-app/pen.lite/Sources/Models/AIConnectionModel.swift`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique UUID identifier |
| `apiProvider` | `String` | Provider name (user-defined) |
| `apiKey` | `String` | API key for authentication |
| `apiUrl` | `String` | Base URL for the API endpoint |
| `model` | `String` | Model name to use |
| `isDefault` | `Bool` | Whether this is the default configuration |

### 5. AIModelProvider

**Location**: `/mac-app/pen.lite/Sources/Models/AIModelProvider.swift`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `Int` | Numeric identifier |
| `name` | `String` | Provider name |
| `baseURLs` | `[String: String]` | Dictionary of endpoint URLs |
| `defaultModel` | `String` | Default model to use |
| `requiresAuth` | `Bool` | Whether authentication is required |
| `authHeader` | `String` | Authentication header name |

## Default Configurations

On first launch, if no configuration file exists, `InitializationService` creates:

| Provider | API URL | Model | Default |
|----------|---------|-------|---------|
| Qwen | https://dashscope.aliyuncs.com/compatible-mode/v1 | qwen-plus | Yes |
| OpenAI | https://openaiss.com/v1 | gpt-5.2-all | No |
| DeepSeek | https://api.deepseek.com/v1 | deepseek-chat | No |

## Data Flow

```
1. App launches
2. InitializationService checks for existing config file
3. If not exists, creates default configurations
4. AIConnectionService loads configurations from JSON
5. User views configurations in Settings → AI Connections
6. User double-clicks to edit configuration
7. Edit popup window opens with current values
8. User modifies fields and clicks Test & Save
9. AIManager.testConnection() validates the configuration
10. If success, AIConnectionService saves to JSON file
11. Table refreshes with updated values
```

## Provider Strategy Pattern

The AIManager uses a strategy pattern to handle different provider implementations:

```swift
protocol AIProviderStrategy {
    func buildChatPayload(messages: [AIMessage]) -> [String: Any]
    func parseChatResponse(data: Data) throws -> AIResponse
    var chatEndpoint: String { get }
}
```

### Generic Provider Strategy

Most providers follow the OpenAI-compatible API format:

```swift
class GenericProviderStrategy: AIProviderStrategy {
    private let provider: AIModelProvider
    
    func buildChatPayload(messages: [AIMessage]) -> [String: Any] {
        return [
            "model": provider.defaultModel,
            "messages": messages.map { ["role": $0.role, "content": $0.content] },
            "temperature": 0.7
        ]
    }
}
```

## Error Handling

```swift
enum AIError: Error {
    case invalidAPIKey
    case rateLimited
    case networkError
    case invalidResponse
    case providerError(String)
    case configurationError(String)
}
```

## JSON File Format

### ai-connections.json

```json
[
  {
    "id": "UUID-STRING",
    "apiProvider": "Qwen",
    "apiKey": "sk-xxxxx",
    "apiUrl": "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "model": "qwen-plus",
    "isDefault": true
  },
  {
    "id": "UUID-STRING",
    "apiProvider": "OpenAI",
    "apiKey": "sk-xxxxx",
    "apiUrl": "https://openaiss.com/v1",
    "model": "gpt-5.2-all",
    "isDefault": false
  }
]
```

## Usage Examples

### Load Configurations

```swift
let connections = try AIConnectionService.shared.getConnections()
print("Loaded \(connections.count) configurations")
```

### Test Connection

```swift
let success = try await AIManager.shared.testConnection(connection: connection)
if success {
    print("Connection test passed")
}
```

### Call AI for Content Enhancement

```swift
let response = try await AIManager.shared.callAI(
    prompt: "Improve this text",
    content: "Hello world"
)
print(response.content)
```

### Save Configuration

```swift
try AIConnectionService.shared.saveConnections(configurations)
print("Configurations saved to local file")
```

## Security Considerations

1. **API Key Storage**: API keys are stored in plain text in the JSON file (consider encryption for production)
2. **File Permissions**: Configuration files are stored in user's Application Support directory with appropriate permissions
3. **Request Security**: All API calls use HTTPS
4. **Error Messages**: Error messages should not expose sensitive information

## Performance Considerations

1. **File Caching**: Configurations are loaded once and cached in memory
2. **Atomic Writes**: File writes use atomic operations to prevent corruption
3. **Timeout Handling**: API requests have appropriate timeouts
4. **Retry Logic**: Transient errors should be retried with exponential backoff

## UI Components

### AIConfigurationTabView

**Location**: `/mac-app/pen.lite/Sources/Views/AIConfigurationTabView.swift`

- Displays configurations in a read-only table
- Double-click opens EditAIConnectionWindow (hides Settings window)
- New button opens EditAIConnectionWindow with empty fields (hides Settings window)
- Delete button removes configuration (with validation)

### EditAIConnectionWindow

**Inherits from**: BaseWindow

**Location**: `/mac-app/pen.lite/Sources/Views/EditAIConnectionWindow.swift` (to be created)

**Properties**:
- Size: 680x520 (same as Settings window)
- Position: Same as Settings window position
- Style: Titled with fullSizeContentView (title bar hidden)
- Single instance: Only one window can be open at a time

**Behavior**:
- Opens at the exact position of Settings window
- Hides Settings window when opened
- Restores Settings window when closed
- Contains: Provider Name, API Key, Base URL, Model fields
- Buttons: Cancel, Test & Save, Delete

**See also**: [ui-ai-configurations.md](ui-ai-configurations.md) for detailed UI specifications

## Migration Notes

### Removed Components

- Database connectivity (DatabaseConnectivityPool)
- User authentication (AuthenticationService)
- User model references
- Database schema (ai_providers, ai_connections tables)

### Replaced Components

- Database storage → JSON file storage
- User-specific configurations → Global configurations
- Server-side validation → Client-side validation
