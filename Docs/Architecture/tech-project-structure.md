# Pen Lite Project Structure

This document outlines the folder structure for Pen Lite, including ATDD workflow alignment and internationalization (i18n) support.

## Root-Level Structure

```
/pen.lite
├── /mac-app              # Swift/AppKit Mac application
├── /Docs                 # Project documentation
│   ├── readme.md         # Main project docs
│   ├── project_structure.md # This file
│   ├── /Architecture     # Technical architecture documents
│   ├── /Pen-Window       # Pen window requirements and design
│   ├── /ai-configurations # AI configuration requirements and design
│   ├── /Prompts          # Prompts requirements and design
│   ├── /Menu-Bar         # Menu bar icon requirements and design
│   ├── /Settings         # Settings requirements and design
│   ├── /system           # System requirements and design
│   ├── /UI-Components    # UI component requirements and design
│   └── /back-end         # Backend initialization requirements
└── /web-app              # (Legacy/Unused) React web app skeleton
```

## 1. Mac App (`/mac-app`)

```
/mac-app
├── /pen.lite
│   ├── /Sources          # Swift source code
│   │   ├── /App          # App entry point (main.swift, Pen.swift)
│   │   ├── /Models       # Data models (Prompt, AIConnectionModel)
│   │   ├── /Services     # Business logic services
│   │   │   ├── AIConnectionService.swift  # AI provider integration
│   │   │   ├── ColorService.swift         # UI color management
│   │   │   ├── FileStorageService.swift   # Local file storage
│   │   │   ├── InitializationService.swift # App initialization
│   │   │   ├── KeychainService.swift      # Secure key storage
│   │   │   ├── LocalizationService.swift  # i18n support
│   │   │   ├── Logger.swift               # Logging service
│   │   │   ├── PenWindowService.swift     # Pen window management
│   │   │   ├── PromptService.swift        # Prompts CRUD
│   │   │   ├── ResourceService.swift      # App bundle resources
│   │   │   └── SystemConfigService.swift  # System configuration
│   │   └── /Views        # AppKit views
│   │       ├── AIConfigurationTabView.swift  # AI connections tab
│   │       ├── BaseWindow.swift              # Base window class
│   │       ├── GeneralTabView.swift          # General settings tab
│   │       ├── SettingsWindow.swift          # Main settings window
│   │       ├── PromptsTabView.swift          # Prompts management tab
│   │       ├── NewOrEditPrompt.swift         # Prompt editor
│   │       └── WindowManager.swift           # Window state management
│   ├── /Resources        # App resources
│   │   ├── /Assets       # Images, icons (icon.png, logo.png, etc.)
│   │   ├── /ai-config    # Default AI configurations
│   │   │   └── default-ai-configurations.json
│   │   ├── /prompts      # Default prompts
│   │   │   ├── default-refine-english.json
│   │   │   ├── default-translator.json
│   │   │   └── default-prompt-creator.json
│   │   ├── en.lproj/     # English localization
│   │   │   └── Localizable.strings
│   │   └── zh-Hans.lproj/ # Chinese (Simplified) localization
│   │       └── Localizable.strings
│   ├── /Tests            # Xcode tests
│   ├── Info.plist        # App configuration
│   ├── Package.swift     # Swift Package Manager config
│   └── build-app.sh      # Build script
├── icon.png              # App icon
├── logo.png              # App logo (light mode)
└── logo_dark.png         # App logo (dark mode)
```

## 2. Documentation (`/Docs`)

```
/Docs
├── readme.md             # Main project documentation
├── tmp-doc-review.md     # Documentation review report
├── /Architecture         # Technical architecture documents
│   ├── tech-global-objects-architecture.md
│   ├── tech-project-structure.md
│   ├── coding-best-practice.md
│   └── tech-challenges.md
├── /Pen-Window           # Pen window requirements and design
│   ├── req-pen-window-behavior.md
│   ├── ui-pen-window.md
│   └── design-pen-window-service.md
├── /ai-configurations    # AI configuration requirements and design
│   ├── req-ai-configurations.md
│   ├── ui-ai-configurations.md
│   └── design-ai-manager.md
├── /Prompts              # Prompts requirements and design
│   ├── req-prompts.md
│   ├── req-prompts-ui.md
│   └── design-prompt.md
├── /Menu-Bar             # Menu bar icon requirements and design
│   ├── req-simplified-menubar-icom.md.md
│   └── design-simplified-menubar-icom.md
├── /Settings             # Settings requirements and design
│   ├── req-general-settings.md
│   └── req-preferences.md
├── /system               # System requirements and design
│   ├── req-language-switch.md
│   └── design-system-config-service.md
├── /UI-Components        # UI component requirements and design
│   ├── req-mac-ui.md
│   └── ui-style-guide.md
└── /back-end             # Backend initialization requirements
    └── req-simplified-initialization.md
```

## ATDD Workflow Alignment

| ATDD Step | Location | Purpose |
|-----------|----------|--------|
| **1. Define User Stories** | `/Docs/*/req-*.md` | High-level user requirements in Markdown |
| **2. Technical Design** | `/Docs/*/design-*.md` | Technical specifications and design decisions |
| **3. UI Definition** | `/Docs/*/ui-*.md` | UI component specifications |
| **4. Implement Code** | `/mac-app/pen.lite/Sources/` | Swift implementation |
| **5. Write Tests** | `/mac-app/pen.lite/Tests/` | Xcode unit and UI tests |
| **6. Run Tests** | Xcode / `swift test` | Execute all tests |

## Internationalization (i18n) Resource Locations

### Mac App
- **Location**: `/mac-app/pen.lite/Resources/en.lproj/` and `/mac-app/pen.lite/Resources/zh-Hans.lproj/`
- **Format**: `.strings` files (key-value pairs)
- **Usage**: `LocalizationService.shared.localizedString(for: "key")`
- **Runtime Switching**: Supported via `LocalizationService.setLanguage()`

### Example `.strings` file:
```
/* Greeting message */
"hello_user" = "Hello, I'm Pen, your AI writing assistant.";
"save_button" = "Save";
"cancel_button" = "Cancel";
```

## Key Considerations

1. **Offline-First Design**: Mac app runs entirely locally without requiring a database or backend server.

2. **Local Data Storage**: All user data stored in `~/Library/Application Support/Pen.Lite/`

3. **i18n Consistency**: Use consistent key naming conventions (e.g., `section_label`, `action_button`).

4. **Scalability**: The architecture supports adding new AI models and features without major refactoring.

5. **Security**: API keys stored locally in JSON files; sensitive data can use Keychain.

6. **Performance**: No network latency for local operations; only AI calls require internet.

7. **Deployment**: Mac app distributed as .dmg; no server infrastructure required.
