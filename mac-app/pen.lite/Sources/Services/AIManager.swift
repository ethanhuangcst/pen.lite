import Foundation

public class AIManager {
    

    // MARK: - Private Nested Types
    
    private struct AIConfiguration {
        let id: Int
        var apiKey: String
        var apiProvider: String
        let createdAt: Date
        var updatedAt: Date?
    }
    
    private struct AIModelProvider {
        let id: Int
        let name: String
        let baseURLs: [String: String]
        let defaultModel: String
        let requiresAuth: Bool
        let authHeader: String
        let createdAt: Date
        let updatedAt: Date?
    }
    
    private enum AIError: Error {
        case invalidAPIKey
        case rateLimited
        case networkError
        case invalidResponse
        case providerError(String)
        case configurationError(String)
        case unauthorized(String)
        case forbidden(String)
        case notFound(String)
        case serverError(Int, String)
        case clientError(Int, String)
        case invalidJSONResponse(String)
        
        var localizedDescription: String {
            switch self {
            case .invalidAPIKey:
                return "Invalid API key"
            case .rateLimited:
                return "Rate limited - too many requests"
            case .networkError:
                return "Network error - unable to connect"
            case .invalidResponse:
                return "Invalid response from server"
            case .providerError(let message):
                return "Provider error: \(message)"
            case .configurationError(let message):
                return "Configuration error: \(message)"
            case .unauthorized(let message):
                return "Unauthorized: \(message)"
            case .forbidden(let message):
                return "Forbidden: \(message)"
            case .notFound(let message):
                return "Not found: \(message)"
            case .serverError(let code, let message):
                return "Server error (\(code)): \(message)"
            case .clientError(let code, let message):
                return "Client error (\(code)): \(message)"
            case .invalidJSONResponse(let message):
                return "Invalid JSON response: \(message)"
            }
        }
    }
    
    private protocol ProviderStrategy {
        func buildChatPayload(messages: [AIMessage]) -> [String: Any]
        func parseChatResponse(data: Data) throws -> AIResponse
        var chatEndpoint: String { get }
        var embeddingEndpoint: String { get }
        var imageEndpoint: String { get }
    }
    
    public struct AIMessage {
        public let role: String
        public let content: String
    }
    
    public struct AIResponse {
        public let id: String
        public let content: String
        public let model: String
        public let usage: AIUsage?
    }
    
    public struct AIUsage {
        public let promptTokens: Int
        public let completionTokens: Int
        public let totalTokens: Int
    }
    
    public struct AIProvider {
        public let id: Int
        public let name: String
        public let baseURLs: [String: String]
        public let defaultModel: String
        public let requiresAuth: Bool
        public let authHeader: String
    }
    
    // MARK: - Private Properties
    
    private var strategies: [String: ProviderStrategy] = [:]
    private var cachedProviders: [AIModelProvider]?
    private var currentConfiguration: AIConfiguration?
    private var _isInitialized: Bool = false
    
    // MARK: - Public Properties
    
    public var isInitialized: Bool {
        return _isInitialized
    }
    
    // MARK: - Initialization
    
    public init() {
        // No initialization needed
    }
    
    // MARK: - Initialization Method
    
    public func initialize() {
        _isInitialized = true
    }
    
    // MARK: - Public Methods
    
    public func configure(apiKey: String, providerName: String) {
        let configuration = AIConfiguration(
            id: 0,
            apiKey: apiKey,
            apiProvider: providerName,
            createdAt: Date(),
            updatedAt: nil
        )
        currentConfiguration = configuration
    }
    
    public func sendChat(
        messages: [AIMessage],
        model: String? = nil,
        temperature: Double = 0.7,
        maxTokens: Int? = nil
    ) async throws -> AIResponse {
        guard let configuration = currentConfiguration else {
            throw AIError.configurationError("Not configured")
        }
        
        let provider = try await loadProviderByName(configuration.apiProvider)
        guard let provider = provider else {
            throw AIError.providerError("Provider not found")
        }
        
        let strategy = createStrategy(for: provider)
        var payload = strategy.buildChatPayload(messages: messages)
        
        // Override with custom parameters if provided
        if let model = model {
            payload["model"] = model
        }
        
        payload["temperature"] = temperature
        
        if let maxTokens = maxTokens {
            payload["max_tokens"] = maxTokens
        }
        
        let data = try await performRequest(
            endpoint: strategy.chatEndpoint,
            body: payload,
            apiKey: configuration.apiKey,
            authHeader: provider.authHeader,
            requiresAuth: provider.requiresAuth
        )
        
        return try strategy.parseChatResponse(data: data)
    }
    
    public func testConnection(apiKey: String, providerName: String) async throws -> Bool {
        let provider = try await loadProviderByName(providerName)
        guard let provider = provider else {
            throw AIError.providerError("Provider not found")
        }
        
        func maskSecret(_ value: String) -> String {
            if value.count <= 8 {
                return String(repeating: "*", count: value.count)
            }
            return "\(value.prefix(4))...\(value.suffix(4))"
        }
        
        // Get all base URLs from the provider, sorted by key for consistent ordering
        let sortedKeys = provider.baseURLs.keys.sorted()
        var baseURLs = sortedKeys.map { provider.baseURLs[$0]! }
        
        // Filter to only test chat completion endpoints
        baseURLs = baseURLs.filter { $0.contains("chat/completions") }
        
        if baseURLs.isEmpty {
            throw AIError.providerError("No chat completion endpoints found")
        }
        
        // Test each base URL in order
        var totalAttempts = 0
        var lastError: AIError?
        
        for baseURL in baseURLs {
            totalAttempts += 1
            print("[AIManager] Testing connection attempt \(totalAttempts) for \(providerName): \(baseURL)")
            
            do {
                guard let url = URL(string: baseURL) else {
                    let error = AIError.configurationError("Invalid URL: \(baseURL)")
                    print("[AIManager] ❌ \(error.localizedDescription)")
                    lastError = error
                    continue
                }
                
                // Create URLRequest
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.timeoutInterval = 30.0 // 30 seconds timeout
                
                // Add authorization header
                if provider.requiresAuth {
                    if provider.authHeader == "Authorization" {
                        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: provider.authHeader)
                    } else {
                        request.setValue(apiKey, forHTTPHeaderField: provider.authHeader)
                    }
                }
                
                // Create test payload
                let testPayload: [String: Any] = [
                    "model": provider.defaultModel,
                    "messages": [
                        ["role": "user", "content": "Hello, this is a test to verify API connectivity. Please respond with 'API test successful'."]
                    ],
                    "max_tokens": 20,
                    "temperature": 0.7
                ]
                
                // Encode payload to JSON
                let jsonData = try JSONSerialization.data(withJSONObject: testPayload)
                request.httpBody = jsonData
                
                let requestBodyString = String(data: jsonData, encoding: .utf8) ?? "{}"
                var headerSnapshot = request.allHTTPHeaderFields ?? [:]
                if provider.requiresAuth {
                    if provider.authHeader == "Authorization" {
                        headerSnapshot[provider.authHeader] = "Bearer \(maskSecret(apiKey))"
                    } else {
                        headerSnapshot[provider.authHeader] = maskSecret(apiKey)
                    }
                }
                print("[AIManager] ---- Outbound Request ----")
                print("[AIManager] Provider: \(provider.name)")
                print("[AIManager] Model: \(provider.defaultModel)")
                print("[AIManager] URL: \(baseURL)")
                print("[AIManager] Method: \(request.httpMethod ?? "POST")")
                print("[AIManager] Headers: \(headerSnapshot)")
                print("[AIManager] Body: \(requestBodyString)")
                print("[AIManager] --------------------------")
                
                // Make API call
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Check response status code
                guard let httpResponse = response as? HTTPURLResponse else {
                    let error = AIError.invalidResponse
                    print("[AIManager] ❌ Failed: Invalid response type - \(baseURL)")
                    lastError = error
                    continue
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                    print("[AIManager] ❌ Failed: HTTP \(statusCode) - \(baseURL)")
                    print("[AIManager] Response: \(responseBody.prefix(200))")
                    let mappedError = mapError(data, response: httpResponse)
                    lastError = mappedError
                    continue
                }
                
                // Parse response
                do {
                    // First, check if response looks like valid JSON
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    
                    // Check if response starts with '{' or '[' (valid JSON)
                    let trimmedResponse = responseString.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmedResponse.hasPrefix("{") || trimmedResponse.hasPrefix("[") else {
                        // Response is not JSON - likely HTML or plain text
                        let preview = trimmedResponse.prefix(100)
                        let errorMessage = "Server returned non-JSON response (likely wrong endpoint). Response starts with: \(preview)"
                        print("[AIManager] ❌ Failed: Non-JSON response - \(baseURL)")
                        print("[AIManager] Response preview: \(preview)")
                        lastError = AIError.invalidJSONResponse(errorMessage)
                        continue
                    }
                    
                    let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let choices = responseData?["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        print("[AIManager] ✅ Successfully connected to \(providerName)")
                        print("[AIManager] URL: \(baseURL)")
                        print("[AIManager] Response: \(content)")
                        return true
                    } else if let errorDict = responseData?["error"] as? [String: Any] {
                        // API returned an error object
                        let errorMsg = errorDict["message"] as? String ?? "Unknown error"
                        let errorType = errorDict["type"] as? String ?? "unknown"
                        print("[AIManager] ❌ API Error: \(errorMsg) (type: \(errorType)) - \(baseURL)")
                        lastError = AIError.providerError("\(errorMsg) (type: \(errorType))")
                        continue
                    } else {
                        let errorMessage = "Invalid API response format - missing expected fields"
                        print("[AIManager] ❌ Failed: \(errorMessage) - \(baseURL)")
                        print("[AIManager] Response keys: \(responseData?.keys.sorted().joined(separator: ", ") ?? "none")")
                        lastError = AIError.invalidResponse
                        continue
                    }
                } catch let jsonError as NSError {
                    // JSON parsing failed
                    let responsePreview = String(data: data, encoding: .utf8)?.prefix(200) ?? "Unable to decode"
                    let errorMessage = "JSON parsing failed: \(jsonError.localizedDescription)"
                    print("[AIManager] ❌ Failed: \(errorMessage) - \(baseURL)")
                    print("[AIManager] Response preview: \(responsePreview)")
                    lastError = AIError.invalidJSONResponse(errorMessage)
                    continue
                }
            } catch {
                let errorMessage = "Network error: \(error.localizedDescription)"
                print("[AIManager] ❌ Failed: \(errorMessage) - \(baseURL)")
                lastError = AIError.networkError
                continue
            }
        }
        
        // All URLs failed
        print("[AIManager] ❌ All \(totalAttempts) attempts failed for \(providerName)")
        print("[AIManager] Last error: \(lastError?.localizedDescription ?? "Unknown error")")
        throw lastError ?? AIError.networkError
    }
    
    public func testConnectionWithValues(apiKey: String, baseURL: String, model: String, providerName: String) async throws -> Bool {
        func maskSecret(_ value: String) -> String {
            if value.count <= 8 {
                return String(repeating: "*", count: value.count)
            }
            return "\(value.prefix(4))...\(value.suffix(4))"
        }
        
        // Build full endpoint URL
        var endpointURL = baseURL
        if !endpointURL.hasSuffix("/chat/completions") {
            if endpointURL.hasSuffix("/") {
                endpointURL = String(endpointURL.dropLast())
            }
            endpointURL += "/chat/completions"
        }
        
        print("[AIManager] Testing connection for \(providerName)")
        print("[AIManager] Base URL: \(baseURL)")
        print("[AIManager] Endpoint URL: \(endpointURL)")
        print("[AIManager] Model: \(model)")
        
        guard let url = URL(string: endpointURL) else {
            throw AIError.configurationError("Invalid URL: \(endpointURL)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30.0
        
        let testPayload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": "Hello, this is a test to verify API connectivity. Please respond with 'API test successful'."]
            ],
            "max_tokens": 20,
            "temperature": 0.7
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: testPayload)
        request.httpBody = jsonData
        
        print("[AIManager] ---- Outbound Request ----")
        print("[AIManager] Provider: \(providerName)")
        print("[AIManager] Model: \(model)")
        print("[AIManager] URL: \(baseURL)")
        print("[AIManager] Method: \(request.httpMethod ?? "POST")")
        print("[AIManager] Headers: [\"Authorization\": \"Bearer \(maskSecret(apiKey))\"]")
        print("[AIManager] --------------------------")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("[AIManager] ❌ Failed: HTTP \(httpResponse.statusCode)")
            print("[AIManager] Response: \(responseBody.prefix(200))")
            throw mapError(data, response: httpResponse)
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        let trimmedResponse = responseString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedResponse.hasPrefix("{") || trimmedResponse.hasPrefix("[") else {
            throw AIError.invalidJSONResponse("Server returned non-JSON response")
        }
        
        let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let errorDict = responseData?["error"] as? [String: Any] {
            let errorMsg = errorDict["message"] as? String ?? "Unknown error"
            throw AIError.providerError(errorMsg)
        }
        
        if let choices = responseData?["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            print("[AIManager] ✅ Successfully connected to \(providerName)")
            print("[AIManager] Response: \(content)")
            return true
        }
        
        print("[AIManager] ✅ Successfully connected to \(providerName)")
        return true
    }
    
    // Test Call
    public func AITestCall(
        prompt: String,
        model: String? = nil,
        temperature: Double = 0.7,
        maxTokens: Int = 1200
    ) async throws -> AIResponse {
        // Implementation for testing a complete AI call with custom parameters
        let testMessage = AIMessage(role: "user", content: prompt)
        return try await sendChat(
            messages: [testMessage],
            model: model,
            temperature: temperature,
            maxTokens: maxTokens
        )
    }
    
    // Clear configuration
    public func clearConfiguration() {
        currentConfiguration = nil
    }
    
    // Reset the entire AIManager instance
    public func reset() {
        strategies = [:]
        cachedProviders = nil
        currentConfiguration = nil
        _isInitialized = false
    }
    
    // Validate configuration
    public func validateConfiguration() -> Bool {
        return currentConfiguration != nil
    }
    
    // MARK: - Public Methods for UI
    
    // Public struct for UI use
    public struct PublicAIConfiguration {
        public let id: Int
        public let apiKey: String
        public let apiProvider: String
        public let createdAt: Date
        public let updatedAt: Date?
    }
    
    // Public struct for UI use
    public struct PublicAIModelProvider {
        public let id: Int
        public let name: String
        public let baseURLs: [String: String]
        public let defaultModel: String
        public let requiresAuth: Bool
        public let authHeader: String
        public let createdAt: Date
        public let updatedAt: Date?
    }
    
    // Load all providers for UI
    public func loadAllProviders() async throws -> [PublicAIModelProvider] {
        // Load from AIConnectionService
        let connections = try AIConnectionService.shared.getConnections()
        
        let providers = connections.map { connection in
            PublicAIModelProvider(
                id: Int(connection.id.hashValue),
                name: connection.apiProvider,
                baseURLs: ["default": connection.apiUrl],
                defaultModel: connection.model,
                requiresAuth: true,
                authHeader: "Authorization",
                createdAt: Date(),
                updatedAt: nil
            )
        }
        
        return providers.isEmpty ? getDefaultPublicProviders() : providers
    }
    private func getDefaultPublicProviders() -> [PublicAIModelProvider] {
        let now = Date()
        
        // OpenAI
        let openAI = PublicAIModelProvider(
            id: 1,
            name: "OpenAI",
            baseURLs: ["completion": "https://api.openai.com/v1/chat/completions"],
            defaultModel: "gpt-4",
            requiresAuth: true,
            authHeader: "Authorization",
            createdAt: now,
            updatedAt: now
        )
        
        // Anthropic
        let anthropic = PublicAIModelProvider(
            id: 2,
            name: "Anthropic",
            baseURLs: ["completion": "https://api.anthropic.com/v1/messages"],
            defaultModel: "claude-3-opus-20240229",
            requiresAuth: true,
            authHeader: "x-api-key",
            createdAt: now,
            updatedAt: now
        )
        
        // Google AI
        let googleAI = PublicAIModelProvider(
            id: 3,
            name: "Google AI",
            baseURLs: ["completion": "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"],
            defaultModel: "gemini-pro",
            requiresAuth: true,
            authHeader: "x-goog-api-key",
            createdAt: now,
            updatedAt: now
        )
        
        // Azure OpenAI
        let azureOpenAI = PublicAIModelProvider(
            id: 4,
            name: "Azure OpenAI",
            baseURLs: ["completion": "https://{your-resource-name}.openai.azure.com/openai/deployments/{deployment-id}/chat/completions?api-version=2024-02-01"],
            defaultModel: "gpt-4",
            requiresAuth: true,
            authHeader: "api-key",
            createdAt: now,
            updatedAt: now
        )
        
        return [openAI, anthropic, googleAI, azureOpenAI]
    }
    
    // MARK: - Provider Methods
    
    public func getProviders() async throws -> [AIProvider] {
        let publicProviders = try await loadAllProviders()
        return publicProviders.map { provider in
            AIProvider(
                id: provider.id,
                name: provider.name,
                baseURLs: provider.baseURLs,
                defaultModel: provider.defaultModel,
                requiresAuth: provider.requiresAuth,
                authHeader: provider.authHeader
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func loadProviderByName(_ name: String) async throws -> AIModelProvider? {
        // Load from AIConnectionService
        let connections = try AIConnectionService.shared.getConnections()
        guard let connection = connections.first(where: { $0.apiProvider == name }) else {
            return nil
        }
        
        // Build full endpoint URL
        var endpointURL = connection.apiUrl
        if !endpointURL.hasSuffix("/chat/completions") {
            if endpointURL.hasSuffix("/") {
                endpointURL = String(endpointURL.dropLast())
            }
            endpointURL += "/chat/completions"
        }
        
        return AIModelProvider(
            id: Int(connection.id.hashValue),
            name: connection.apiProvider,
            baseURLs: ["completion": endpointURL],
            defaultModel: connection.model,
            requiresAuth: true,
            authHeader: "Authorization",
            createdAt: Date(),
            updatedAt: nil
        )
    }
    
    private func createDefaultProvider(for name: String) -> AIModelProvider {
        // Create a default provider based on name
        let now = Date()
        var baseURLs: [String: String] = [:]
        var defaultModel: String = ""
        
        switch name.lowercased() {
        case "openai", "gpt-4o-mini":
            baseURLs = [
                "completion": "https://api.openai.com/v1/chat/completions",
                "embedding": "https://api.openai.com/v1/embeddings",
                "image": "https://api.openai.com/v1/images/generations"
            ]
            defaultModel = "gpt-4o-mini"
        case "deepseek", "deepseek3.2":
            baseURLs = ["completion": "https://api.deepseek.com/v1/chat/completions"]
            defaultModel = "deepseek-ai/deepseek-v1.5"
        case "baichuan":
            baseURLs = ["completion": "https://api.baichuan-ai.com/v1/chat/completions"]
            defaultModel = "Baichuan2-13B-Chat"
        case "qwen", "qwen-plus":
            baseURLs = ["completion": "https://api.baichuan-ai.com/v1/chat/completions"]
            defaultModel = "Qwen2.5-72B-Instruct"
        default:
            baseURLs = ["completion": "https://api.openai.com/v1/chat/completions"]
            defaultModel = "gpt-4o-mini"
        }
        
        return AIModelProvider(
            id: Int(Date.timeIntervalSinceReferenceDate * 1000),
            name: name,
            baseURLs: baseURLs,
            defaultModel: defaultModel,
            requiresAuth: true,
            authHeader: "Authorization",
            createdAt: now,
            updatedAt: now
        )
    }
    
    private func createStrategy(for provider: AIModelProvider) -> ProviderStrategy {
        return GenericProviderStrategy(provider: provider)
    }
    
    private struct GenericProviderStrategy: ProviderStrategy {
        private let provider: AIModelProvider
        
        init(provider: AIModelProvider) {
            self.provider = provider
        }
        
        func buildChatPayload(messages: [AIMessage]) -> [String: Any] {
            return [
                "model": provider.defaultModel,
                "messages": messages.map { ["role": $0.role, "content": $0.content] },
                "temperature": 0.7
            ]
        }
        
        func parseChatResponse(data: Data) throws -> AIResponse {
            // Parse response based on provider type
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let id = json?["id"] as? String,
                  let choices = json?["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let model = json?["model"] as? String else {
                throw AIError.invalidResponse
            }
            
            var usage: AIUsage?
            if let usageData = json?["usage"] as? [String: Any],
               let promptTokens = usageData["prompt_tokens"] as? Int,
               let completionTokens = usageData["completion_tokens"] as? Int,
               let totalTokens = usageData["total_tokens"] as? Int {
                usage = AIUsage(promptTokens: promptTokens, completionTokens: completionTokens, totalTokens: totalTokens)
            }
            
            return AIResponse(
                id: id,
                content: content,
                model: model,
                usage: usage
            )
        }
        
        var chatEndpoint: String {
            // Get the first completion endpoint from baseURLs
            return provider.baseURLs.first { $0.key.contains("completion") }?.value ?? ""
        }
        
        var embeddingEndpoint: String {
            return provider.baseURLs["embedding"] ?? ""
        }
        
        var imageEndpoint: String {
            return provider.baseURLs["image"] ?? ""
        }
    }
    
    private func performRequest(
        endpoint: String,
        body: [String: Any],
        apiKey: String,
        authHeader: String,
        requiresAuth: Bool,
        providerName: String = "unknown"
    ) async throws -> Data {
        guard let url = URL(string: endpoint) else {
            throw AIError.configurationError("Invalid endpoint URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0
        
        if requiresAuth {
            if authHeader == "Authorization" {
                request.setValue("Bearer \(apiKey)", forHTTPHeaderField: authHeader)
            } else {
                request.setValue(apiKey, forHTTPHeaderField: authHeader)
            }
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[AIManager] ❌ Invalid response type")
            throw AIError.invalidResponse
        }
        
        let statusCode = httpResponse.statusCode
        
        print("[AIManager] HTTP Status: \(statusCode)")
        
        let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        
        guard (200...299).contains(statusCode) else {
            let responsePrefix = String(responseBody.prefix(200))
            
            // Check if response is non-JSON (likely HTML error page)
            let trimmedResponse = responseBody.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedResponse.hasPrefix("{") && !trimmedResponse.hasPrefix("[") {
                print("[AIManager] ❌ Non-JSON response received (likely wrong endpoint or server error)")
                print("[AIManager] Response preview: \(trimmedResponse.prefix(100))")
                throw AIError.invalidJSONResponse("Server returned non-JSON response. This usually means the endpoint URL is incorrect. Preview: \(trimmedResponse.prefix(100))")
            }
            
            switch statusCode {
            case 401:
                print("[AIManager] ❌ Unauthorized (401) - API key may be invalid or missing")
                throw AIError.unauthorized("Authentication failed. Please check your API key for \(providerName). Response: \(responsePrefix)")
            case 403:
                print("[AIManager] ❌ Forbidden (403) - Access denied")
                throw AIError.forbidden("Access denied. Your API key may not have permission for this operation. Response: \(responsePrefix)")
            case 404:
                print("[AIManager] ❌ Not Found (404) - Endpoint not found")
                throw AIError.notFound("API endpoint not found. Please check the URL configuration. Response: \(responsePrefix)")
            case 429:
                print("[AIManager] ❌ Rate Limited (429) - Too many requests")
                throw AIError.rateLimited
            case 400...499:
                print("[AIManager] ❌ Client Error (\(statusCode))")
                throw AIError.clientError(statusCode, responsePrefix)
            case 500...599:
                print("[AIManager] ❌ Server Error (\(statusCode))")
                throw AIError.serverError(statusCode, responsePrefix)
            default:
                print("[AIManager] ❌ Unknown Error (\(statusCode))")
                throw AIError.networkError
            }
        }
        
        return data
    }
    
    private func mapError(_ data: Data, response: HTTPURLResponse) -> AIError {
        let statusCode = response.statusCode
        let responseBody = String(data: data, encoding: .utf8) ?? "Unable to decode response"
        
        print("[AIManager] Mapping error for HTTP \(statusCode)")
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let error = json?["error"] as? [String: Any],
               let message = error["message"] as? String {
                let errorType = error["type"] as? String ?? "unknown"
                let errorCode = error["code"] as? String ?? "unknown"
                print("[AIManager] Provider error - Type: \(errorType), Code: \(errorCode), Message: \(message)")
                return AIError.providerError("\(message) (type: \(errorType), code: \(errorCode))")
            }
            
            if let message = json?["message"] as? String {
                print("[AIManager] Provider error - Message: \(message)")
                return AIError.providerError(message)
            }
        } catch {
            print("[AIManager] Failed to parse error response as JSON: \(error)")
        }
        
        let responsePrefix = String(responseBody.prefix(200))
        
        switch statusCode {
        case 401:
            return AIError.unauthorized("Authentication failed. Response: \(responsePrefix)")
        case 403:
            return AIError.forbidden("Access denied. Response: \(responsePrefix)")
        case 404:
            return AIError.notFound("Endpoint not found. Response: \(responsePrefix)")
        case 429:
            return AIError.rateLimited
        case 400...499:
            return AIError.clientError(statusCode, responsePrefix)
        case 500...599:
            return AIError.serverError(statusCode, responsePrefix)
        default:
            print("[AIManager] Returning generic error for HTTP \(statusCode)")
            return AIError.clientError(statusCode, responsePrefix)
        }
    }
}
