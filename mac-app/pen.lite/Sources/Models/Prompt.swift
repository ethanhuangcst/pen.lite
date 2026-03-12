import Foundation

enum PromptError: Error, LocalizedError {
    case lastPromptCannotBeDeleted
    case promptNotFound(id: String)
    case invalidPromptData
    
    var errorDescription: String? {
        switch self {
        case .lastPromptCannotBeDeleted:
            return LocalizationService.shared.localizedString(for: "cannot_delete_last_prompt")
        case .promptNotFound(let id):
            return "Prompt not found with ID: \(id)"
        case .invalidPromptData:
            return "Invalid prompt data"
        }
    }
}

class Prompt: Codable {
    static let DEFAULT_PROMPT_ID = "DEFAULT"
    
    let id: String
    let promptName: String
    let promptText: String
    let createdDatetime: Date
    let updatedDatetime: Date?
    let systemFlag: String
    let isDefault: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case promptName
        case promptText
        case createdDatetime
        case updatedDatetime
        case systemFlag
        case isDefault
    }
    
    init(id: String, promptName: String, promptText: String, createdDatetime: Date, updatedDatetime: Date?, systemFlag: String = "PEN", isDefault: Bool = false) {
        self.id = id
        self.promptName = promptName
        self.promptText = promptText
        self.createdDatetime = createdDatetime
        self.updatedDatetime = updatedDatetime
        self.systemFlag = systemFlag
        self.isDefault = isDefault
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        promptName = try container.decode(String.self, forKey: .promptName)
        promptText = try container.decode(String.self, forKey: .promptText)
        createdDatetime = try container.decode(Date.self, forKey: .createdDatetime)
        updatedDatetime = try container.decodeIfPresent(Date.self, forKey: .updatedDatetime)
        systemFlag = try container.decodeIfPresent(String.self, forKey: .systemFlag) ?? "PEN"
        isDefault = try container.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(promptName, forKey: .promptName)
        try container.encode(promptText, forKey: .promptText)
        try container.encode(createdDatetime, forKey: .createdDatetime)
        try container.encodeIfPresent(updatedDatetime, forKey: .updatedDatetime)
        try container.encode(systemFlag, forKey: .systemFlag)
        try container.encode(isDefault, forKey: .isDefault)
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
