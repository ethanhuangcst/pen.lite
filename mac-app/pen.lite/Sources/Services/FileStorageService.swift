import Foundation

class FileStorageService {
    static let shared = FileStorageService()
    
    private let configDirectory = "config"
    private let promptsDirectory = "prompts"
    
    private init() {
        createDirectories()
    }
    
    private func createDirectories() {
        let fileManager = FileManager.default
        let appSupportDir = getAppSupportDirectory()
        
        let configPath = appSupportDir.appendingPathComponent(configDirectory)
        let promptsPath = appSupportDir.appendingPathComponent(promptsDirectory)
        
        do {
            try fileManager.createDirectory(at: configPath, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: promptsPath, withIntermediateDirectories: true, attributes: nil)
            print("[FileStorageService] Directories created successfully")
        } catch {
            print("[FileStorageService] Error creating directories: \(error)")
        }
    }
    
    private func getAppSupportDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDir = urls[0].appendingPathComponent("Pen.Lite")
        return appSupportDir
    }
    
    // MARK: - Configuration Files
    
    func getAIConnectionsFile() -> URL {
        return getAppSupportDirectory().appendingPathComponent(configDirectory).appendingPathComponent("ai-connections.json")
    }
    
    func getAppSettingsFile() -> URL {
        return getAppSupportDirectory().appendingPathComponent(configDirectory).appendingPathComponent("app-settings.json")
    }
    
    // MARK: - Prompt Files
    
    func getPromptsDirectory() -> URL {
        return getAppSupportDirectory().appendingPathComponent(promptsDirectory)
    }
    
    func getPromptFile(named name: String) -> URL {
        return getPromptsDirectory().appendingPathComponent("\(name).md")
    }
    
    // MARK: - File Operations
    
    func readFile(at url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }
    
    func writeFile(data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
    
    func listFiles(in directory: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
        return files
    }
    
    func deleteFile(at url: URL) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(at: url)
    }
    
    func fileExists(at url: URL) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: url.path)
    }
}
