# Pen Lite Coding Best Practices

> A comprehensive guide for developers working on the Pen Lite project, documenting best practices, anti-patterns, and lessons learned from real project experience.

---

## Purpose

This document serves as:
1. **A coding standard** for the Pen Lite development team
2. **A knowledge base** of lessons learned from real debugging sessions
3. **A reference** for onboarding new developers
4. **A skill file** that can be used directly as SKILL.md for AI assistants

---

## File Naming Conventions

### Temporary Files

| Pattern | Example | Purpose |
|---------|---------|---------|
| `tmp-*` | `tmp-test-connection.swift` | Temporary test files, should be deleted |
| `test-*.swift` | `test-connection.swift` | Standalone test scripts |
| `Test*.swift` | `TestConnection.swift` | Unit test files (in Tests directory) |

### Source Files

| Category | Naming Pattern | Example |
|----------|---------------|---------|
| Models | `*Model.swift` | `AIConnectionModel.swift` |
| Services | `*Service.swift` | `PromptService.swift` |
| Views | `*View.swift` or `*Window.swift` | `SettingsWindow.swift` |
| Controllers | `*Controller.swift` | (Avoid if possible, use MVVM) |

### Documentation Files

| Pattern | Purpose |
|---------|---------|
| `req-*.md` | Requirements documents |
| `design-*.md` | Design documents |
| `tech-*.md` | Technical documentation |
| `ui-*.md` | UI/UX documentation |

---

## Logging Standards

### Log Format

```swift
// ✅ Good: Structured log with context
print("[PromptService] Loading prompts from local storage")
print("[AIConnectionService] Loaded \(connections.count) connections")
print("[PenWindowService] Clipboard content unchanged, skipping enhancement")

// ❌ Bad: Unstructured logs
print("loading...")
print("error")
print("here")
```

### Log Prefixes

| Prefix | Usage |
|--------|-------|
| `[ClassName]` | Standard class method logs |
| `[MethodName]` | Critical method entry/exit |
| `ERROR:` | Error conditions |
| `WARNING:` | Warning conditions |
| `DEBUG:` | Debug-only information |

### Log Levels

```swift
// Development: Verbose logging for debugging
print("[PromptService] DEBUG: Prompt keys: \(prompt.keys)")

// Production: Essential logs only
print("[PromptService] Loaded \(count) prompts")
```

### Critical Debug Points

Always add logs at:
1. **File operations** - Print file paths and results
2. **Async operations** - Print start/end
3. **Error handling** - Print error details
4. **State changes** - Print before/after values

```swift
// ✅ Good: Comprehensive logging for debugging
func loadPrompts() -> [Prompt] {
    print("========== PromptService.loadPrompts START ==========")
    
    do {
        let promptsDirectory = fileStorage.getPromptsDirectory()
        print("[PromptService] Loading from: \(promptsDirectory)")
        
        let files = try FileManager.default.contentsOfDirectory(atPath: promptsDirectory)
        print("[PromptService] Found \(files.count) files")
        
        return prompts
    } catch {
        print("[PromptService] ERROR: \(error)")
        return []
    }
    
    print("========== PromptService.loadPrompts END ==========")
}
```

---

## JSON File Naming

### Critical Rule: Match Model Properties to JSON Keys

```swift
// ✅ Good: Property names match JSON keys exactly
struct AIConnectionModel: Codable {
    let id: String              // JSON: "id"
    let apiProvider: String     // JSON: "apiProvider"
    let apiKey: String          // JSON: "apiKey"
    let apiUrl: String          // JSON: "apiUrl"
    let model: String           // JSON: "model"
    let isDefault: Bool         // JSON: "isDefault"
}

// ❌ Bad: Different names cause decoding failures
struct AIConnectionModel: Codable {
    let identifier: String      // JSON: "id" - MISMATCH!
    let provider: String        // JSON: "apiProvider" - MISMATCH!
}
```

### When Creating JSON Files

```json
// ✅ Good: All required fields present
{
  "id": "default-qwen",
  "apiProvider": "qwen",
  "apiKey": "sk-xxx",
  "apiUrl": "https://dashscope.aliyuncs.com/compatible-mode/v1",
  "model": "qwen-plus",
  "isDefault": true
}

// ❌ Bad: Missing required field causes decoding failure
{
  "apiProvider": "qwen",
  "apiKey": "sk-xxx",
  // Missing "id" field!
}
```

---

## Reducing Complexity

### Function Size

```swift
// ✅ Good: Small, focused functions
func initiatePen() async {
    await initializeUIComponents()
    await loadAIConfigurations()
    await loadPrompts()
    await loadClipboardContent()
}

// ❌ Bad: One giant function doing everything
func initiatePen() async {
    // 100+ lines of code doing multiple things
}
```

### Guard Clauses

```swift
// ✅ Good: Early returns reduce nesting
func enhanceText() async {
    guard let window = window else { return }
    guard let selectedPrompt = await getSelectedPrompt() else { return }
    guard let selectedProvider = await getSelectedProvider() else { return }
    guard let originalText = getOriginalText() else { return }
    
    // Main logic here
}

// ❌ Bad: Deep nesting
func enhanceText() async {
    if let window = window {
        if let selectedPrompt = await getSelectedPrompt() {
            if let selectedProvider = await getSelectedProvider() {
                if let originalText = getOriginalText() {
                    // Main logic buried in nesting
                }
            }
        }
    }
}
```

### Single Responsibility

```swift
// ✅ Good: Each function does one thing
func initializeUIComponents() { ... }
func loadAIConfigurations() async { ... }
func loadPrompts() -> [Prompt] { ... }

// ❌ Bad: Function does multiple unrelated things
func loadDataAndSetupUI() async {
    // Loads AI configurations
    // Sets up UI
    // Loads prompts
    // Monitors clipboard
}
```

---

## Async/Concurrency Patterns

### Preventing Concurrent Execution

```swift
// ✅ Good: Use flags to prevent concurrent execution
class PenWindowService {
    private var isEnhancing: Bool = false
    
    func enhanceText() async {
        guard !isEnhancing else {
            print("[PenWindowService] Already enhancing, skipping duplicate request")
            return
        }
        
        isEnhancing = true
        defer { isEnhancing = false }
        
        // Enhancement logic
    }
}
```

### Initialization State Management

```swift
// ✅ Good: Track initialization state
class PenWindowService {
    private var isInitializing: Bool = false
    
    func initiatePen() async {
        isInitializing = true
        defer { isInitializing = false }
        
        // Initialization logic
    }
    
    @objc func handleSelectionChanged() {
        guard !isInitializing else {
            print("Skipping during initialization")
            return
        }
        // Handle selection change
    }
}
```

### Avoid Fire-and-Forget Tasks

```swift
// ❌ Bad: Multiple Tasks can run concurrently
func initiatePen() async {
    Task { await enhanceText() }  // Task A
    Task { await enhanceText() }  // Task B - runs concurrently!
}

// ✅ Good: Sequential execution or proper state management
func initiatePen() async {
    await enhanceText()  // Sequential
}
```

---

## Error Handling

### Comprehensive Error Messages

```swift
// ✅ Good: Detailed error context
catch {
    print("[PromptService] Error loading prompts: \(error)")
    print("[PromptService] Directory: \(promptsDirectory)")
    fflush(stdout)
    return []
}

// ❌ Bad: Silent failure
catch {
    return []
}
```

### Result Type Usage

```swift
// ✅ Good: Use Result type for async operations
func loadPrompts() -> Result<[Prompt], Error> {
    do {
        let prompts = try fetchPrompts()
        return .success(prompts)
    } catch {
        return .failure(error)
    }
}

// Usage:
let result = promptService.loadPrompts()
switch result {
case .success(let prompts):
    // Handle success
case .failure(let error):
    // Handle error
}
```

---

## Anti-Patterns

### Mistakes Made in This Project

#### 1. JSON Field Missing

**Problem**: JSON file missing required field caused silent decoding failure.

```swift
// ❌ What we did wrong
// JSON file had no "id" field
// Model required "id" field
// Result: AI configurations not created on fresh install
```

**Solution**: Always verify JSON files have all required fields matching the model.

---

#### 2. Concurrent Enhancement Calls

**Problem**: Multiple `Task { await enhanceText() }` blocks created duplicate operations.

```swift
// ❌ What caused the bug
func initiatePen() async {
    // Dropdown selection triggers this during initialization
    // Task { await enhanceText() }  // Called 3 times!
}
```

**Solution**: Added `isInitializing` and `isEnhancing` flags.

---

#### 3. Missing Main Menu for Shortcuts

**Problem**: System shortcuts (Cmd+C, Cmd+V) didn't work in text fields.

**Root Cause**: Menu bar apps have no main menu by default, so AppKit has nowhere to route shortcuts.

**Solution**: Install a minimal main menu with Edit menu at app launch.

---

#### 4. Unstructured Debug Logs

**Problem**: Logs like `print("here")`, `print("error")` made debugging impossible.

**Solution**: Use structured logging with class/method prefixes.

---

### Other Anti-Patterns to Avoid

#### Magic Numbers

```swift
// ❌ Bad
let frame = NSRect(x: 20, y: 228, width: 338, height: 30)

// ✅ Good
let spacing: CGFloat = 20
let controllerHeight: CGFloat = 30
let frame = NSRect(x: spacing, y: 228, width: 338, height: controllerHeight)
```

#### Hardcoded Strings

```swift
// ❌ Bad
let fileName = "default-ai-configurations.json"

// ✅ Good
let configFileName = "default-ai-configurations"
let fileName = "\(configFileName).json"
```

#### Ignoring Optional Safety

```swift
// ❌ Bad
let value = dictionary["key"]!  // Force unwrap

// ✅ Good
if let value = dictionary["key"] {
    // Safe usage
} else {
    print("WARNING: Key not found in dictionary")
}
```

#### Not Cleaning Up Resources

```swift
// ❌ Bad
var monitor: Any?
func startMonitoring() {
    monitor = NSEvent.addLocalMonitorForEvents(...)
}
// No cleanup in deinit

// ✅ Good
deinit {
    if let monitor = monitor {
        NSEvent.removeMonitor(monitor)
    }
}
```

---

## Industry Best Practices

### Code Organization

```
Sources/
├── App/           # App lifecycle, delegates
├── Models/        # Data models
├── Services/      # Business logic, API calls
├── Views/         # UI components
└── Utils/         # Helpers, extensions
```

### Dependency Injection

```swift
// ✅ Good: Dependencies injected
class PenWindowService {
    private let promptService: PromptService
    private let aiConnectionService: AIConnectionService
    
    init(promptService: PromptService, aiConnectionService: AIConnectionService) {
        self.promptService = promptService
        self.aiConnectionService = aiConnectionService
    }
}
```

### Protocol-Oriented Design

```swift
// ✅ Good: Protocol for file storage
protocol FileStorage {
    func getPromptsDirectory() -> String
    func getAIConnectionsFile() -> String
    func createDirectories() -> Bool
}

class LocalFileStorage: FileStorage { ... }
```

### Testing Practices

```swift
// Test file naming: <Class>Tests.swift
class PromptServiceTests: XCTestCase {
    var sut: PromptService!
    
    override func setUp() {
        sut = PromptService()
    }
    
    func testLoadPromptsReturnsCorrectCount() {
        let prompts = sut.getPrompts()
        // Assert...
    }
}
```

---

## Code Review Checklist

Before submitting code, verify:

- [ ] **Naming**: Do model properties match JSON keys?
- [ ] **Logging**: Are logs structured with prefixes?
- [ ] **Concurrency**: Are there guards against concurrent execution?
- [ ] **Error Handling**: Are errors logged with context?
- [ ] **Resources**: Are event monitors and timers cleaned up?
- [ ] **Memory**: Are weak self references used in closures?
- [ ] **Optionals**: Are optionals safely unwrapped?
- [ ] **Constants**: Are magic numbers extracted to constants?
- [ ] **i18n**: Are user-facing strings localized?

---

## Quick Reference Card

### Do's

| Practice | Example |
|----------|---------|
| Match JSON keys | `apiProvider` → `apiProvider` |
| Structured logs | `print("[ClassName] Message")` |
| Guard clauses | `guard let x = x else { return }` |
| State flags | `isEnhancing = true; defer { isEnhancing = false }` |
| Early returns | Return early to reduce nesting |
| Error context | Log file path and error |

### Don'ts

| Anti-Pattern | Why It's Bad |
|--------------|--------------|
| Missing JSON fields | Silent decoding failures |
| Unstructured logs | Impossible to trace issues |
| Fire-and-forget Tasks | Race conditions, duplicates |
| Force unwrapping | Crashes |
| Magic numbers | Unmaintainable |
| Missing cleanup | Memory leaks |

---

## Document History

| Date | Author | Changes |
|------|--------|---------|
| March 2024 | Dev Team | Initial creation |
| March 2026 | Dev Team | Updated for offline-first architecture |

---

*This document is a living resource. Update it as new patterns and anti-patterns are discovered.*
