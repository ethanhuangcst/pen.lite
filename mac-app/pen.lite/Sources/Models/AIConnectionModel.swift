import Foundation

struct AIConnectionModel: Codable {
    let id: String
    var apiProvider: String
    var apiKey: String
    var apiUrl: String
    var model: String
    var isDefault: Bool
    
    init(id: String = UUID().uuidString, apiProvider: String, apiKey: String, apiUrl: String, model: String, isDefault: Bool = false) {
        self.id = id
        self.apiProvider = apiProvider
        self.apiKey = apiKey
        self.apiUrl = apiUrl
        self.model = model
        self.isDefault = isDefault
    }
}
