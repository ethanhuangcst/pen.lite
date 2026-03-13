import Cocoa

struct DefaultAIConfigurations: Codable {
    let connections: [AIConnectionModel]
    let defaultBaseURLs: [String: [String: String]]?
}

class InitializationService {
    // MARK: - Properties
    private weak var delegate: PenDelegate?
    private var forceReinitPrompts: Bool = false
    
    // MARK: - Initialization
    init(delegate: PenDelegate, forceReinitPrompts: Bool = false) {
        self.delegate = delegate
        self.forceReinitPrompts = forceReinitPrompts
    }
    
    // MARK: - Public Methods
    
    /// Performs the initialization process
    func performInitialization() {
        Logger.info("Starting initialization process")
        
        // Step 1: Initialize file storage
        Logger.debug("Step 1 - Initializing file storage")
        _ = FileStorageService.shared
        Logger.info("File storage initialized successfully")
        
        // Step 1.5: Initialize default configurations if needed
        Logger.debug("Step 1.5 - Checking default configurations")
        initializeDefaultConfigurations()
        
        // Step 2: Test internet connectivity (optional, app can work offline)
        Logger.debug("Step 2 - Testing internet connectivity")
        let isInternetAvailable = testInternetConnectivity()
        Logger.info("Internet connectivity: \(isInternetAvailable ? "Available" : "Unavailable")")
        
        // Step 3: Load AI configurations from local files
        Logger.debug("Step 3 - Loading AI configurations")
        loadAIConfigurationsFromFiles()
        
        Logger.info("Initialization process completed successfully")
        Logger.info("App is ready for use")
        
        // Set app to online mode if internet is available
        delegate?.setOnlineMode(isInternetAvailable)
    }
    
    // MARK: - Private Methods
    
    /// Initializes default configurations if they don't exist
    private func initializeDefaultConfigurations() {
        // Initialize default AI configurations
        initializeDefaultAIConfigurations()
        
        // Initialize default prompts
        initializeDefaultPrompts(force: forceReinitPrompts)
    }
    
    /// Initializes default AI configurations if the file doesn't exist
    private func initializeDefaultAIConfigurations() {
        let fileStorage = FileStorageService.shared
        let aiConnectionsFile = fileStorage.getAIConnectionsFile()
        
        if !fileStorage.fileExists(at: aiConnectionsFile) {
            Logger.debug("Creating default AI configurations file")
            
            let configPath = ResourceService.shared.getResourcePath(relativePath: "ai-config/default-ai-configurations.json")
            
            guard FileManager.default.fileExists(atPath: configPath) else {
                Logger.error("CRITICAL: default_ai_configurations.json not found at \(configPath)")
                return
            }
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
                let decoder = JSONDecoder()
                let config = try decoder.decode(DefaultAIConfigurations.self, from: data)
                try AIConnectionService.shared.saveConnections(config.connections)
                Logger.info("Loaded \(config.connections.count) default configurations from JSON")
            } catch {
                Logger.error("Error loading default configurations from JSON: \(error)")
            }
        } else {
            Logger.debug("AI configurations file already exists, skipping default creation")
        }
    }
    
    /// Initializes default prompts if the directory is empty
    /// - Parameter force: If true, reinitializes prompts even if directory has files (for testing)
    private func initializeDefaultPrompts(force: Bool = false) {
        let fileStorage = FileStorageService.shared
        let promptsDirectory = fileStorage.getPromptsDirectory()
        
        do {
            let files = try fileStorage.listFiles(in: promptsDirectory)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            if jsonFiles.isEmpty || force {
                if force && !jsonFiles.isEmpty {
                    Logger.debug("Force reinitializing prompts (deleting existing)")
                    for file in jsonFiles {
                        try fileStorage.deleteFile(at: file)
                    }
                }
                Logger.debug("Creating default prompts from bundle")
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                // List of default prompt files to load
                let defaultPromptFiles = [
                    "default-refine-english",
                    "default-translator",
                    "default-prompt-creator"
                ]
                
                for promptFileName in defaultPromptFiles {
                    let promptPath = ResourceService.shared.getResourcePath(relativePath: "prompts/\(promptFileName).json")
                    
                    guard FileManager.default.fileExists(atPath: promptPath) else {
                        Logger.error("CRITICAL: \(promptFileName).json not found at \(promptPath)")
                        continue
                    }
                    
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: promptPath))
                        let prompt = try decoder.decode(Prompt.self, from: data)
                        try PromptService.shared.createPrompt(prompt)
                        Logger.info("Loaded default prompt: \(prompt.promptName)")
                    } catch {
                        Logger.error("Error loading prompt from \(promptFileName).json: \(error)")
                    }
                }
                
                Logger.info("Default prompts created successfully")
            } else {
                Logger.debug("Prompts directory already contains files, skipping default creation")
            }
        } catch {
            Logger.error("Error checking/creating default prompts: \(error)")
        }
    }
    
    /// Tests internet connectivity
    private func testInternetConnectivity() -> Bool {
        Logger.debug("Testing internet connectivity...")
        
        // Use this actual InternetConnectivityServiceTest
        let connectivityService = InternetConnectivityServiceTest()
        let isInternetAvailable = connectivityService.isInternetAvailable()
        
        if isInternetAvailable {
            Logger.info("Internet connection is available")
            Logger.info("********************************** PenAI Initialization: Internet Connectivity: AVAILABLE **********************************")
            return true
        } else {
            Logger.warning("Internet connection is unavailable")
            Logger.info("********************************** PenAI Initialization: Internet Connectivity: UNAVAILABLE **********************************")
            return false
        }
    }
    
    

    

    
    /// Loads AI configurations from local files
    private func loadAIConfigurationsFromFiles() {
        Logger.debug("Loading AI configurations from files")
        
        do {
            let connections = try AIConnectionService.shared.getConnections()
            Logger.info("Loaded \(connections.count) AI configurations from files")
            
            if connections.isEmpty {
                Logger.warning("No AI configurations found in files")
                // Show message about setting up AI configurations
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    WindowManager.shared.displayPopupMessage("No AI Configuration set up yet.\nGo to Settings → AI Configuration to set up.")
                }
            } else {
                print("InitializationService: AI configurations loaded successfully")
            }
        } catch {
            print("InitializationService: Error loading AI configurations from files: \(error)")
        }
    }
}
