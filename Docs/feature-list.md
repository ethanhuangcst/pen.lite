# Pen Feature List

# Features to Keep

## App Initialization
### Internet Connectivity Test
- Test internet connectivity on app launch
- Determine online/offline mode based on connection status
- Display appropriate status indicators

## Menu Bar
### Menu Bar Icon
- Display menu bar icon with different states (online/offline)
- Update icon appearance based on app status
### Menu Bar Tooltip
- Show tooltip message on menu bar icon hover
- Display current app status in tooltip
### Menu Bar Left Click
- Open Pen window when clicked
- Position window relative to menu bar icon
### Menu Bar Right Click
- Display dropdown menu with options
- Include Settings and Exit options

## Pen Window
### Window Positioning
- Position Pen window relative to mouse cursor
- Position to position relative to menu bar icon
- Save window position for future launches
### Window Access Control
- Allow Pen window access in both online and offline modes
- Handle offline mode gracefully
### Close Other Windows
- Close all other windows when Pen window opens
- Ensure only one Pen window is open at a time

## Input Mode
### Auto Mode
- Automatically load text from clipboard into original text field
- Detect clipboard changes and update accordingly
- Provide visual indication of auto mode status
### Manual Mode
- Allow user to manually input text for enhancement
- Provide text area for manual input
- Support text editing and formatting
### Mode Toggle
- Switch between Auto and Manual mode via toggle switch
- Persist selected mode across sessions
- Provide clear visual indication of current mode
### Mode Persistence
- Remember selected input mode across app restarts
- Store mode preference in local storage
- Restore mode on app launch
### Manual Paste
- Manually trigger clipboard text intake in Auto mode
- Provide paste button for user convenience
- Handle clipboard errors gracefully

## Text Enhancement
### AI Enhancement
- Send original text to selected AI provider
- Display enhanced text in real-time
- Support text formatting in enhanced output
### Provider Selection
- Select AI provider from available configurations
- Display provider status (connected/disconnected)
- Allow quick switching between providers
### Prompt Selection
- Select prompt template from user prompts
- Display prompt preview
- Allow quick switching between prompts
### Clipboard Comparison
- Compare clipboard content before automatic enhancement
- Only process if clipboard content has changed
- Prevent duplicate processing
### Copy Enhanced Text
- Click enhanced text to copy to clipboard
- Provide visual feedback on successful copy
- Handle copy errors gracefully
### Loading Indicator
- Display loading indicator during AI processing
- Show progress or animation during enhancement
- Hide indicator when processing completes
### Enhancement Triggers
- Trigger enhancement on window open
- Trigger enhancement on provider change
- Trigger enhancement on prompt change
- Trigger enhancement on text input change

## User Interface
### Dark Mode
- Support for macOS dark mode
- Automatically switch based on system preference
- Manual override option
### Light Mode
- Support for macOS light mode
- Default mode when dark mode is disabled
- Consistent UI elements across modes
### Internationalization
- Support for English language
- Support for Chinese language
- Easy addition of new languages
- Language preference persistence
### Popup Messages
- Display temporary popup messages
- Show success, error, and information messages
- Auto-dismiss after timeout
### Custom Switch Control
- Custom toggle switch for UI consistency
- Support for dark/light mode appearance
- Accessible design for all users

## System
### Clipboard Access
- Read from system clipboard
- Write to system clipboard
- Monitor clipboard changes
- Handle clipboard permissions
### Error Handling
- Handle and display errors to users
- Log errors for debugging
- Provide user-friendly error messages
- Recover from common errors automatically
### Logging
- Log application events for debugging
- Rotate log files to prevent size issues
- Include timestamps and severity levels
- Support different logging levels

# To Be Changed

## Load AI Configurations
- Load AI configurations on Pen window launch
- Load user prompts and preferences
- Handle missing configurations gracefully
- Change: AI configuration and user prompts will be stored in local files

## AI Integration
- Add new AI provider connections
- Edit existing AI provider connections
- Delete AI provider connections
- Organize connections by provider type
- Test AI connection before saving
- Display test results and error messages
- Handle connection timeouts and errors
- Support OpenAI API
- Support DeepSeek API
- Support Qwen API
- Support custom AI providers
- Store API keys securely
- Encrypt API keys at rest
- Allow API key rotation
- Handle API key validation
- Change: AI configuration and user prompts will be stored in local files

## Prompts
- System-provided default prompt for all users
- Optimized for general text enhancement
- Editable by users
- Create new custom prompts
- Edit existing custom prompts
- Delete custom prompts
- Organize prompts by category
- Select prompt from dropdown in Pen window
- Search and filter prompts
- Preview prompt content before selection
- Change: AI configuration and user prompts will be stored in local files

## Settings
- Open settings window from menu bar
- Tabbed interface for different settings
- Save settings automatically
- Manage AI provider connections
- Test connections from settings
- Organize connections by provider
- Manage custom prompts
- Create and edit prompts
- Import/export prompts
- Change: Renamed from 'Preferences' to 'Settings'

# Features to Remove

## Database Connection Pool
- Create singleton database connectivity pool
- Manage database connections
- Pen.Lite does not need database at all

## Auto Login
- Automatically login with stored credentials
- Load user data on app launch
- Pen.Lite does not need user system at all

## Authentication
- User Registration
- User Login
- User Logout
- Password Reset
- Pen.Lite does not need user system at all

## Load User Information
- Load user account information
- Load user preferences
- Pen.Lite does not need user system at all

## Content History
- View list of enhanced content history
- Copy from history
- History limit management
- Auto add to history
- Pen.Lite does not need content history

## Account Tab (Settings)
- View and edit user account information
- Profile image management
- Change password functionality
- Pen.Lite does not need user system at all

## History Tab (Settings)
- View content enhancement history
- Manage history settings
- Pen.Lite does not need content history

## General Settings (Settings)
- Configure general app settings
- Shortcut key configuration
- Pen.Lite does not need these settings

## Keyboard Shortcut
- Global keyboard shortcut to open Pen window
- Shortcut configuration
- Pen.Lite does not need global shortcuts

## Database Operations
- CRUD operations for user data
- CRUD operations for AI connections
- CRUD operations for prompts
- CRUD operations for history
- Pen.Lite does not need database at all