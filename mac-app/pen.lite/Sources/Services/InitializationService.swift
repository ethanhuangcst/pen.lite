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
