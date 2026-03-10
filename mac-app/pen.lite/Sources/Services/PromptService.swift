import Foundation

class PromptService {
    static let shared = PromptService()
    
    private let fileStorage = FileStorageService.shared
    
    private init() {}
    
    func getPrompts() throws -> [Prompt] {
        let directory = fileStorage.getPromptsDirectory()
        let files = try fileStorage.listFiles(in: directory)
        
        var prompts: [Prompt] = []
        
        for file in files {
            if file.pathExtension == "md" {
                let promptName = file.deletingPathExtension().lastPathComponent
                let content = try String(contentsOf: file, encoding: .utf8)
                
                let prompt = Prompt(
                    id: UUID().uuidString,
                    userId: 1, // Default user ID for local storage
                    promptName: promptName,
                    promptText: content,
                    createdDatetime: Date(),
                    updatedDatetime: Date(),
                    isDefault: false
                )
                
                prompts.append(prompt)
            }
        }
        
        return prompts
    }
    
    func createPrompt(name: String, text: String) throws {
        let fileURL = fileStorage.getPromptFile(named: name)
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func updatePrompt(name: String, text: String) throws {
        let fileURL = fileStorage.getPromptFile(named: name)
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    func deletePrompt(name: String) throws {
        let fileURL = fileStorage.getPromptFile(named: name)
        try fileStorage.deleteFile(at: fileURL)
    }
    
    func getPrompt(named name: String) throws -> String? {
        let fileURL = fileStorage.getPromptFile(named: name)
        if fileStorage.fileExists(at: fileURL) {
            return try String(contentsOf: fileURL, encoding: .utf8)
        }
        return nil
    }
}
