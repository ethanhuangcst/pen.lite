import Cocoa
import Foundation

// Main entry point for the application
print("Main: Starting Pen AI application")

// Create the application instance
let app = NSApplication.shared

// Create and set the delegate
let delegate = PenDelegate()
app.delegate = delegate

// Run the application
print("Main: Running Pen AI application")
app.run()
