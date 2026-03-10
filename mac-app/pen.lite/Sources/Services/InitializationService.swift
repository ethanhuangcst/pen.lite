import Cocoa

class InitializationService {
    // MARK: - Properties
    private weak var delegate: PenDelegate?
    private var isOnline: Bool = false
    private var internetFailure: Bool = false
    private var databaseFailure: Bool = false
    private var needsOnlineLogoutMode: Bool = false
    
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
    
    /// Tests internet connectivity
    private func testInternetConnectivity() -> Bool {
        print("InitializationService: Testing internet connectivity...")
        
        // Use the actual InternetConnectivityServiceTest
        let connectivityService = InternetConnectivityServiceTest()
        let isInternetAvailable = connectivityService.isInternetAvailable()
        
        if isInternetAvailable {
            print("InitializationService: Internet connection is available")
            print(" ********************************** PenAI Initialization: Internet Connectivity: AVAILABLE **********************************")
            internetFailure = false
            return true
        } else {
            print("InitializationService: Internet connection is unavailable")
            print(" ********************************** PenAI Initialization: Internet Connectivity: UNAVAILABLE **********************************")
            internetFailure = true
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
    
    /// Loads and tests AI configurations for the user
    private func loadAndTestAIConfigurations(user: User) {
        Task {
            do {
                // Load all AI configurations for the user
                guard let aiManager = UserService.shared.aiManager else {
                    print("InitializationService: AIManager not initialized")
                    return
                }
                let configurations = try await aiManager.getConnections(for: user.id)
                
                print("InitializationService: Loaded \(configurations.count) AI configurations for user \(user.name)")
                
                if configurations.isEmpty {
                    // No AI configurations found
                    print("InitializationService: No AI configurations found for user \(user.name)")
                    // Wait until previous popup messages fade out (3 seconds + 0.3 seconds fade out)
                    try await Task.sleep(nanoseconds: 3_300_000_000) // 3.3 seconds
                    // Show shorter popup message
                    WindowManager.shared.displayPopupMessage("No AI Configuration set up yet.\nGo to Preference → AI Configuration to set up.")
                } else {
                    // Test each AI configuration
                    for (index, configuration) in configurations.enumerated() {
                        print("\n********************************** Test AI Configuration for \(user.name) : Provider \(index + 1): \(configuration.apiProvider) **********************************")
                        
                        do {
                            // Test the connection
                            let success = try await aiManager.testConnection(
                                apiKey: configuration.apiKey,
                                providerName: configuration.apiProvider
                            )
                            
                            if success {
                                print("InitializationService: AI Configuration \(configuration.apiProvider) test successful")
                            } else {
                                print("InitializationService: AI Configuration \(configuration.apiProvider) test failed")
                            }
                        } catch {
                            print("InitializationService: Error testing AI Configuration \(configuration.apiProvider): \(error)")
                        }
                    }
                }
            } catch {
                print("InitializationService: Error loading AI configurations: \(error)")
            }
        }
    }
}
