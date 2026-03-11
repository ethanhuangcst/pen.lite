import Cocoa

class InitializationService {
    // MARK: - Properties
    private weak var delegate: PenDelegate?
    
    // MARK: - Initialization
    init(delegate: PenDelegate) {
        self.delegate = delegate
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
        initializeDefaultPrompts()
    }
    
    /// Initializes default AI configurations if the file doesn't exist
    private func initializeDefaultAIConfigurations() {
        let fileStorage = FileStorageService.shared
        let aiConnectionsFile = fileStorage.getAIConnectionsFile()
        
        if !fileStorage.fileExists(at: aiConnectionsFile) {
            print("InitializationService: Creating default AI configurations file")
            
            // Create default AI connections
            let defaultConnections = [
                AIConnectionModel(
                    apiProvider: "Qwen",
                    apiKey: "sk-b87bcf7a745644a8bd72b5cea88d6f27",
                    apiUrl: "https://dashscope.aliyuncs.com/compatible-mode/v1",
                    model: "qwen-plus",
                    isDefault: true
                ),
                AIConnectionModel(
                    apiProvider: "OpenAI",
                    apiKey: "sk-VdihYuyJpOjAC8Qv6kmkYVT56mRaG3nkkjHm0lTIxZ38ub3O",
                    apiUrl: "https://openaiss.com/v1",
                    model: "gpt-5.2-all",
                    isDefault: false
                ),
                AIConnectionModel(
                    apiProvider: "DeepSeek",
                    apiKey: "sk-366a2d261ad84510a612fddfd47ccc9f",
                    apiUrl: "https://api.deepseek.com/v1",
                    model: "deepseek-chat",
                    isDefault: false
                )
            ]
            
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
    private func initializeDefaultPrompts() {
        let fileStorage = FileStorageService.shared
        let promptsDirectory = fileStorage.getPromptsDirectory()
        
        do {
            let files = try fileStorage.listFiles(in: promptsDirectory)
            let markdownFiles = files.filter { $0.pathExtension == "md" }
            
            if markdownFiles.isEmpty {
                print("InitializationService: Creating default prompt file")
                
                // Create default prompt
                let defaultPrompt = """
# Prompt name = Refine English
# Default = True
# Prompt
````
# Role
## You are a professional English editor
## You are a native British English speaker with a PhD in Linguistics
## You are an experienced English language coach.

# Task
## First, identify the language of the content. If it is written in a language other than English, translate it into English.
## Then refine the text while preserving its original meaning. The refinements include:
### Correct any grammatical, spelling, or punctuation errors.
### Improve sentence structure and clarity.
### Replace awkward or unnatural phrasing with expressions that sound natural to a native speaker.
### Use stronger, more precise vocabulary where appropriate, but keep it natural and not overly complex.
### Reshape the text so it flows like natural spoken English, making it smooth, conversational, and fluent.

# Rules
## Do not provide explanations; return only the revised text.
## Output the text without adding any extra characters.
## Avoid typical AI writing patterns, such as：
### Overuse of em dashes (—) or double dashes (--)** for emphasis or inserted clarification
### Clean, structured formatting with balanced bullet points and sections
### Frequent bold headers (e.g., "Key Points," "In Conclusion")
### Predictable intro → body → conclusion structure
### Neutral, professional tone even for casual topics
### Repetitive transition phrases ("Furthermore," "On the other hand," "Overall")
### Hedging language ("may," "often," "tends to," "it is worth noting")
### Even-handed, balanced arguments presenting multiple sides
### High coherence but limited specificity (few concrete examples unless prompted)
## Do not apply any formatting such as bold text.


Here is my text:
```
"""
                
                try PromptService.shared.createPrompt(name: "Refine English", text: defaultPrompt)
                print("InitializationService: Default prompt created successfully")
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
