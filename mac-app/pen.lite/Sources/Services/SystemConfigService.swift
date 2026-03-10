import Foundation
import AppKit

class SystemConfigService {
    static let shared = SystemConfigService()
    
    // Content history count constants
    var CONTENT_HISTORY_LOW = 10
    var CONTENT_HISTORY_MEDIUM = 20
    var CONTENT_HISTORY_HIGH = 40
    
    // Default prompt settings
    var DEFAULT_PROMPT_NAME: String? = nil
    var DEFAULT_PROMPT_TEXT: String? = nil
    
    // Default prompt constant
    static let DEFAULT_PROMPT_FLAG = 1
    
    // Appearance preferences
    private let autoSwitchAppearanceKey = "autoSwitchAppearance"
    private let manualAppearanceKey = "manualAppearance"
    
    var autoSwitchAppearance: Bool {
        get {
            return UserDefaults.standard.bool(forKey: autoSwitchAppearanceKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: autoSwitchAppearanceKey)
        }
    }
    
    var manualAppearance: NSAppearance.Name? {
        get {
            let rawValue = UserDefaults.standard.string(forKey: manualAppearanceKey)
            switch rawValue {
            case "dark":
                return .darkAqua
            case "light":
                return .aqua
            default:
                return nil
            }
        }
        set {
            let rawValue: String?
            switch newValue {
            case .darkAqua:
                rawValue = "dark"
            case .aqua:
                rawValue = "light"
            default:
                rawValue = nil
            }
            UserDefaults.standard.set(rawValue, forKey: manualAppearanceKey)
        }
    }
    
    private init() {
        loadConfig()
    }
    
    func loadConfig() {
        // Load default prompt from file
        if let prompt = loadDefaultPromptFromFile() {
            DEFAULT_PROMPT_NAME = prompt.name
            DEFAULT_PROMPT_TEXT = prompt.text
            print("SystemConfigService: Loaded default prompt from file: \(prompt.name)")
        } else {
            // Use hardcoded fallback values
            DEFAULT_PROMPT_NAME = "Enhance English"
            DEFAULT_PROMPT_TEXT = "Enhance English for the following text: "
            print("SystemConfigService: Using default prompt: Enhance English")
        }
        
        // Load content history counts from UserDefaults
        CONTENT_HISTORY_LOW = UserDefaults.standard.integer(forKey: "contentHistoryLow")
        if CONTENT_HISTORY_LOW == 0 { CONTENT_HISTORY_LOW = 10 }
        
        CONTENT_HISTORY_MEDIUM = UserDefaults.standard.integer(forKey: "contentHistoryMedium")
        if CONTENT_HISTORY_MEDIUM == 0 { CONTENT_HISTORY_MEDIUM = 20 }
        
        CONTENT_HISTORY_HIGH = UserDefaults.standard.integer(forKey: "contentHistoryHigh")
        if CONTENT_HISTORY_HIGH == 0 { CONTENT_HISTORY_HIGH = 40 }
        
        print(" ********************************** Load Content History Count: LOW=\(CONTENT_HISTORY_LOW), MEDIUM=\(CONTENT_HISTORY_MEDIUM), HIGH=\(CONTENT_HISTORY_HIGH) **********************************")
    }
    
    func getDefaultPrompt() -> (name: String?, text: String?) {
        print("SystemConfigService: Returning default prompt: \(DEFAULT_PROMPT_NAME ?? "Unknown")")
        return (DEFAULT_PROMPT_NAME, DEFAULT_PROMPT_TEXT)
    }
    
    func setDefaultPrompt(name: String, text: String) {
        DEFAULT_PROMPT_NAME = name
        DEFAULT_PROMPT_TEXT = text
        saveDefaultPromptToFile(name: name, text: text)
    }
    
    func getContentHistoryCount(level: String) -> Int {
        switch level.lowercased() {
        case "low":
            return CONTENT_HISTORY_LOW
        case "medium":
            return CONTENT_HISTORY_MEDIUM
        case "high":
            return CONTENT_HISTORY_HIGH
        default:
            return CONTENT_HISTORY_LOW
        }
    }
    
    func setContentHistoryCount(level: String, value: Int) {
        switch level.lowercased() {
        case "low":
            CONTENT_HISTORY_LOW = value
            UserDefaults.standard.set(value, forKey: "contentHistoryLow")
        case "medium":
            CONTENT_HISTORY_MEDIUM = value
            UserDefaults.standard.set(value, forKey: "contentHistoryMedium")
        case "high":
            CONTENT_HISTORY_HIGH = value
            UserDefaults.standard.set(value, forKey: "contentHistoryHigh")
        default:
            break
        }
    }
    
    private func loadDefaultPromptFromFile() -> (name: String, text: String)? {
        let defaultPromptPath = "\(FileManager.default.currentDirectoryPath)/default_prompt.md"
        
        guard FileManager.default.fileExists(atPath: defaultPromptPath) else {
            print("[SystemConfigService] default_prompt.md not found at \(defaultPromptPath)")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: defaultPromptPath, encoding: .utf8)
            
            var promptName = "Enhance English"
            var promptText = content
            
            let lines = content.components(separatedBy: "\n")
            if let firstLine = lines.first, firstLine.hasPrefix("# ") {
                promptName = firstLine.replacingOccurrences(of: "# ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                promptText = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return (name: promptName, text: promptText)
        } catch {
            print("[SystemConfigService] Failed to load default prompt: \(error)")
            return nil
        }
    }
    
    private func saveDefaultPromptToFile(name: String, text: String) {
        let defaultPromptPath = "\(FileManager.default.currentDirectoryPath)/default_prompt.md"
        let content = "# \(name)\n\n\(text)"
        
        do {
            try content.write(toFile: defaultPromptPath, atomically: true, encoding: .utf8)
            print("[SystemConfigService] Default prompt saved to file")
        } catch {
            print("[SystemConfigService] Failed to save default prompt: \(error)")
        }
    }
}
