import Foundation

class Prompt {
    static let DEFAULT_PROMPT_ID = "DEFAULT"
    
    let id: String
    let promptName: String
    let promptText: String
    let createdDatetime: Date
    let updatedDatetime: Date?
    let systemFlag: String
    let isDefault: Bool
    
    init(id: String, promptName: String, promptText: String, createdDatetime: Date, updatedDatetime: Date?, systemFlag: String = "PEN", isDefault: Bool = false) {
        self.id = id
        self.promptName = promptName
        self.promptText = promptText
        self.createdDatetime = createdDatetime
        self.updatedDatetime = updatedDatetime
        self.systemFlag = systemFlag
        self.isDefault = isDefault
    }
    
    static func createNewPrompt(promptName: String, promptText: String, isDefault: Bool = false) -> Prompt {
        return Prompt(
            id: "prompt-\(Int(Date.timeIntervalSinceReferenceDate * 1000))",
            promptName: promptName,
            promptText: promptText,
            createdDatetime: Date(),
            updatedDatetime: nil,
            systemFlag: "PEN",
            isDefault: isDefault
        )
    }
    
    func getMarkdownText() -> String {
        return promptText
    }
    
    static func loadDefaultPrompt() -> Prompt? {
        let defaultPromptPath = "\(FileManager.default.currentDirectoryPath)/default_prompt.md"
        
        guard FileManager.default.fileExists(atPath: defaultPromptPath) else {
            print("[Prompt] default_prompt.md not found at \(defaultPromptPath)")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: defaultPromptPath, encoding: .utf8)
            
            var promptName = "Default Prompt"
            var promptText = content
            
            let lines = content.components(separatedBy: "\n")
            if let firstLine = lines.first, firstLine.hasPrefix("# ") {
                promptName = firstLine.replacingOccurrences(of: "# ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                promptText = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return Prompt(
                id: DEFAULT_PROMPT_ID,
                promptName: promptName,
                promptText: promptText,
                createdDatetime: Date(),
                updatedDatetime: nil,
                systemFlag: "PEN",
                isDefault: true
            )
        } catch {
            print("[Prompt] Failed to load default prompt: \(error)")
            return nil
        }
    }
    
    static func createFallbackDefaultPrompt() -> Prompt {
        let fallbackPromptText = "You are Pen, an AI writing assistant designed to help users improve their writing. Your goal is to analyze the provided text and enhance it while maintaining the original meaning and intent."
        
        return Prompt(
            id: DEFAULT_PROMPT_ID,
            promptName: "Default Prompt",
            promptText: fallbackPromptText,
            createdDatetime: Date(),
            updatedDatetime: nil,
            systemFlag: "PEN",
            isDefault: true
        )
    }
}
