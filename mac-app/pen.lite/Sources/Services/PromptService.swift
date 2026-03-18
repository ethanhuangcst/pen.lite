import Foundation

class PromptService {
    static let shared = PromptService()
    static let promptsDidChangeNotification = Notification.Name("PromptsDidChangeNotification")
    
    private let fileStorage = FileStorageService.shared
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private init() {
        jsonEncoder.outputFormatting = .prettyPrinted
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    func getPrompts() throws -> [Prompt] {
        let directory = fileStorage.getPromptsDirectory()
        let files = try fileStorage.listFiles(in: directory)
        
        var prompts: [Prompt] = []
        
        for file in files {
            if file.pathExtension == "json" {
                do {
                    let data = try fileStorage.readFile(at: file)
                    let prompt = try jsonDecoder.decode(Prompt.self, from: data)
                    prompts.append(prompt)
                } catch {
                    print("[PromptService] Error loading prompt from \(file.lastPathComponent): \(error)")
                }
            }
        }
        
        return prompts.sorted { $0.isDefault && !$1.isDefault }
    }
    
    func createPrompt(_ prompt: Prompt) throws {
        let fileURL = fileStorage.getPromptFile(named: prompt.id)
        let data = try jsonEncoder.encode(prompt)
        try fileStorage.writeFile(data: data, to: fileURL)
        NotificationCenter.default.post(name: Self.promptsDidChangeNotification, object: nil)
    }
    
    func updatePrompt(_ prompt: Prompt) throws {
        let fileURL = fileStorage.getPromptFile(named: prompt.id)
        let data = try jsonEncoder.encode(prompt)
        try fileStorage.writeFile(data: data, to: fileURL)
        NotificationCenter.default.post(name: Self.promptsDidChangeNotification, object: nil)
    }
    
    func deletePrompt(id: String) throws {
        if !canDeletePrompt() {
            throw PromptError.lastPromptCannotBeDeleted
        }
        let fileURL = fileStorage.getPromptFile(named: id)
        try fileStorage.deleteFile(at: fileURL)
        NotificationCenter.default.post(name: Self.promptsDidChangeNotification, object: nil)
    }
    
    func canDeletePrompt() -> Bool {
        do {
            let prompts = try getPrompts()
            return prompts.count > 1
        } catch {
            return false
        }
    }
    
    func getPrompt(id: String) throws -> Prompt? {
        let fileURL = fileStorage.getPromptFile(named: id)
        if fileStorage.fileExists(at: fileURL) {
            let data = try fileStorage.readFile(at: fileURL)
            return try jsonDecoder.decode(Prompt.self, from: data)
        }
        return nil
    }
    
    func getDefaultPrompt() throws -> Prompt? {
        let prompts = try getPrompts()
        return prompts.first { $0.isDefault }
    }
    
    func setDefaultPrompt(id: String) throws {
        var prompts = try getPrompts()
        
        for i in 0..<prompts.count {
            let prompt = prompts[i]
            let updatedPrompt = Prompt(
                id: prompt.id,
                promptName: prompt.promptName,
                promptText: prompt.promptText,
                createdDatetime: prompt.createdDatetime,
                updatedDatetime: Date(),
                systemFlag: prompt.systemFlag,
                isDefault: (prompt.id == id)
            )
            prompts[i] = updatedPrompt
            try updatePrompt(updatedPrompt)
        }
    }
}
