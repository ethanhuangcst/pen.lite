# Language Switch UI Design

## Overview

This document describes the UI design for the language switch feature in the Settings window.

---

## Window Layout

### Settings Window Dimensions
- **Width**: 600px
- **Height**: 518px

### Coordinate System
- Origin (0, 0) is at the **bottom-left** corner (macOS standard)

---

## UI Components

### Header Area Layout

```
┌────────────────────────────────────────────────────────────────────┐
│  (20,463)                    (70,463)         (380,473)  (460,473) │
│    ┌────┐                     ┌─────────────┐  ┌────────┐ ┌──────┐ │
│    │Logo│ 38x38               │ Title       │  │Language│ │ ▼ En │ │
│    │    │                     │ "Pen -      │  │        │ │      │ │
│    └────┘                     │  Settings"  │  └────────┘ └──────┘ │
│                               │ 200x30      │  100x20    100x20   │
│                               └─────────────┘                     │
│                                                                    │
│  y=463 ────────────────────────────────────────────────────────── │
│  y=473 ────────────────────────────────────────────────────────── │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│                        Tab View Area                               │
│                        (AI Connections / Prompts)                  │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## Component Specifications

### 1. Language Label

| Property | Value |
|----------|-------|
| Type | NSTextField (non-editable) |
| Width | 100px |
| Height | 20px |
| Position | x: 380, y: 473 |
| Font | System font |
| Font Size | System font size (typically 13pt) |
| Alignment | Left |
| Background | Transparent |
| Border | None |

**Localized Text:**
- English: "Language:"
- Chinese: "语言:"

---

### 2. Language Dropdown (NSPopUpButton)

| Property | Value |
|----------|-------|
| Type | NSPopUpButton |
| Width | 100px |
| Height | 20px |
| Position | x: 460, y: 473 |
| Font | System font |
| Font Size | System font size (typically 13pt) |
| Style | Rounded bezel |
| Pull-down | No (pop-up style) |

**Dropdown Options:**
| Index | Display Name | Language Code |
|-------|--------------|---------------|
| 0 | English | en |
| 1 | 简体中文 | zh-Hans |

---

## Visual Design

### English UI

```
┌────────────────────────────────────────────────────────────────┐
│  ┌────┐  Pen - Settings          Language:  [English    ▼]   │
│  │ 🖊️ │                                                     │
│  └────┘                                                     │
├────────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  AI Connections  │  Prompts                          │   │
│   │──────────────────────────────────────────────────────│   │
│   │                                                      │   │
│   │  [Configuration table content...]                    │   │
│   │                                                      │   │
│   └──────────────────────────────────────────────────────┘   │
│                                                              │
└────────────────────────────────────────────────────────────────┘
```

### Chinese UI (简体中文)

```
┌────────────────────────────────────────────────────────────────┐
│  ┌────┐  Pen - 设置              语言:  [简体中文    ▼]      │
│  │ 🖊️ │                                                     │
│  └────┘                                                     │
├────────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  AI 连接  │  提示词                                   │   │
│   │──────────────────────────────────────────────────────│   │
│   │                                                      │   │
│   │  [配置表格内容...]                                    │   │
│   │                                                      │   │
│   └──────────────────────────────────────────────────────┘   │
│                                                              │
└────────────────────────────────────────────────────────────────┘
```

---

## Dropdown Expanded State

### English Expanded

```
┌─────────────────────┐
│ English        ▼   │  ← Selected
├─────────────────────┤
│ ● English           │  ← Highlighted
│   简体中文           │
└─────────────────────┘
```

### Chinese Expanded

```
┌─────────────────────┐
│ 简体中文        ▼   │  ← Selected
├─────────────────────┤
│   English           │
│ ● 简体中文           │  ← Highlighted
└─────────────────────┘
```

---

## Interaction States

### Normal State
- Label: Standard text color (labelColor)
- Dropdown: Standard bezel style, shows current selection

### Hover State (Dropdown)
- Dropdown button shows hover highlight

### Expanded State (Dropdown)
- Shows list of all available languages
- Current selection is highlighted with checkmark or bullet

### Focus State (Dropdown)
- Dropdown shows focus ring when keyboard navigation is active

---

## Accessibility

### VoiceOver Labels
- Label: "Language" (localized)
- Dropdown: "Language selector, currently [language name]"

### Keyboard Navigation
- Tab: Move focus between elements
- Space/Enter: Open dropdown when focused
- Arrow keys: Navigate dropdown options
- Escape: Close dropdown without changing selection

---

## Responsive Considerations

The Settings window has a fixed size (600x518), so no responsive adjustments are needed. The language switch UI is positioned in the header area with sufficient space from other elements.

---

## Implementation Notes

1. **Font Consistency**: Use `NSFont.systemFont(ofSize: NSFont.systemFontSize)` to match system font settings
2. **Color Consistency**: Use `NSColor.labelColor` for text to support dark/light mode
3. **Spacing**: The language switch is positioned at y=473, which is 10px higher than the title label at y=463
4. **Alignment**: The label is left-aligned, dropdown follows immediately after at x=460

---

## Localization Keys

| Key | English | Chinese |
|-----|---------|---------|
| `language_label` | Language: | 语言: |
| `language_english` | English | English |
| `language_chinese_simplified` | 简体中文 | 简体中文 |

Note: Language names in the dropdown use the native display name from `AppLanguage.displayName`, which already returns the correct localized name.
