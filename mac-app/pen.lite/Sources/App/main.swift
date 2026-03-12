import Cocoa
import Foundation

// Main entry point for the application
print("Main: Starting Pen AI application")

// Check for command line arguments
let arguments = CommandLine.arguments
let forceReinitPrompts = arguments.contains("--reinit-prompts")

if forceReinitPrompts {
    print("Main: Force reinitializing prompts requested")
}

// Create the application instance
let app = NSApplication.shared

// Create and set the delegate
let delegate = PenDelegate(forceReinitPrompts: forceReinitPrompts)
app.delegate = delegate

// Run the application
print("Main: Running Pen AI application")
app.run()
