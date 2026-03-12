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
        print("InitializationService: Starting initialization process")
        
        // Step 1: Initialize file storage
        print("InitializationService: Step 1 - Initializing file storage")
        let fileStorage = FileStorageService.shared
        print("InitializationService: File storage initialized successfully")
        
        // Step 1.5: Initialize default configurations if needed
        print("InitializationService: Step 1.5 - Checking default configurations")
        initializeDefaultConfigurations()
        
        // Step 2: Test internet connectivity (optional, app can work offline)
        print("InitializationService: Step 2 - Testing internet connectivity")
        let isInternetAvailable = testInternetConnectivity()
        print("InitializationService: Internet connectivity: \(isInternetAvailable ? "Available" : "Unavailable")")
        
        // Step 3: Load AI configurations from local files
        print("InitializationService: Step 3 - Loading AI configurations")
        loadAIConfigurationsFromFiles()
        
        print("InitializationService: Initialization process completed successfully")
        print("InitializationService: App is ready for use")
        
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
            print("InitializationService: Creating default AI configurations file")
            
            // Load default AI connections from JSON file
            var defaultConnections: [AIConnectionModel] = []
            
            let configPath = ResourceService.shared.getResourcePath(relativePath: "config/default_ai_configurations.json")
            
            if FileManager.default.fileExists(atPath: configPath) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
                    let decoder = JSONDecoder()
                    let config = try decoder.decode(DefaultAIConfigurations.self, from: data)
                    defaultConnections = config.connections
                    print("InitializationService: Loaded \(defaultConnections.count) default configurations from JSON")
                } catch {
                    print("InitializationService: Error loading default configurations from JSON: \(error)")
                    // Fallback to empty array
                    defaultConnections = []
                }
            } else {
                print("InitializationService: Warning - default_ai_configurations.json not found at \(configPath)")
            }
            
            do {
                try AIConnectionService.shared.saveConnections(defaultConnections)
                print("InitializationService: Default AI configurations created successfully")
            } catch {
                print("InitializationService: Error creating default AI configurations: \(error)")
            }
        } else {
            print("InitializationService: AI configurations file already exists, skipping default creation")
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
                    print("InitializationService: Force reinitializing prompts (deleting existing)")
                    for file in jsonFiles {
                        try fileStorage.deleteFile(at: file)
                    }
                }
                print("InitializationService: Creating default prompts from bundle")
                
                // Load default prompts from Resources/prompts directory
                var loadedCount = 0
                
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
                    
                    if FileManager.default.fileExists(atPath: promptPath) {
                        do {
                            let data = try Data(contentsOf: URL(fileURLWithPath: promptPath))
                            let prompt = try decoder.decode(Prompt.self, from: data)
                            try PromptService.shared.createPrompt(prompt)
                            loadedCount += 1
                            print("InitializationService: Loaded default prompt: \(prompt.promptName)")
                        } catch {
                            print("InitializationService: Error loading prompt from \(promptFileName).json: \(error)")
                        }
                    } else {
                        print("InitializationService: Warning - \(promptFileName).json not found at \(promptPath)")
                    }
                }
                
                print("InitializationService: Loaded \(loadedCount) default prompts from bundle")
                
                if loadedCount == 0 {
                    
                    // Fallback: create a simple default prompt
                    let fallbackPrompt = Prompt(
                        id: "default-refine-english",
                        promptName: "Refine English",
                        promptText: "You are a professional English editor. Refine the following text while preserving its original meaning.",
                        createdDatetime: Date(),
                        updatedDatetime: nil,
                        systemFlag: "PEN",
                        isDefault: true
                    )
                    
                    try PromptService.shared.createPrompt(fallbackPrompt)
                }
                
                print("InitializationService: Default prompts created successfully")
            } else {
                print("InitializationService: Prompts directory already contains files, skipping default creation")
            }
        } catch {
            print("InitializationService: Error checking/creating default prompts: \(error)")
        }
    }
    
    /// Tests internet connectivity
    private func testInternetConnectivity() -> Bool {
        print("InitializationService: Testing internet connectivity...")
        
        // Use the actual InternetConnectivityServiceTest
        let connectivityService = InternetConnectivityServiceTest()
        let isInternetAvailable = connectivityService.isInternetAvailable()
        
        if isInternetAvailable {
            print("InitializationService: Internet connection is available")
            print("********************************** PenAI Initialization: Internet Connectivity: AVAILABLE **********************************")
            return true
        } else {
            print("InitializationService: Internet connection is unavailable")
            print("********************************** PenAI Initialization: Internet Connectivity: UNAVAILABLE **********************************")
            return false
        }
    }
    

    

    

    
    /// Loads AI configurations from local files
    private func loadAIConfigurationsFromFiles() {
        print("InitializationService: Loading AI configurations from files")
        
        do {
            let connections = try AIConnectionService.shared.getConnections()
            print("InitializationService: Loaded \(connections.count) AI configurations from files")
            
            if connections.isEmpty {
                print("InitializationService: No AI configurations found in files")
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
