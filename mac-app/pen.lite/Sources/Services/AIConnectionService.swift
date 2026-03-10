import Foundation

class AIConnectionService {
    static let shared = AIConnectionService()
    
    private let fileStorage = FileStorageService.shared
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    private init() {
        jsonEncoder.outputFormatting = .prettyPrinted
    }
    
    func getConnections() throws -> [AIConnectionModel] {
        let fileURL = fileStorage.getAIConnectionsFile()
        
        if !fileStorage.fileExists(at: fileURL) {
            return []
        }
        
        let data = try fileStorage.readFile(at: fileURL)
        return try jsonDecoder.decode([AIConnectionModel].self, from: data)
    }
    
    func saveConnections(_ connections: [AIConnectionModel]) throws {
        let fileURL = fileStorage.getAIConnectionsFile()
        let data = try jsonEncoder.encode(connections)
        try fileStorage.writeFile(data: data, to: fileURL)
    }
    
    func addConnection(_ connection: AIConnectionModel) throws {
        var connections = try getConnections()
        connections.append(connection)
        try saveConnections(connections)
    }
    
    func updateConnection(_ connection: AIConnectionModel) throws {
        var connections = try getConnections()
        if let index = connections.firstIndex(where: { $0.id == connection.id }) {
            connections[index] = connection
            try saveConnections(connections)
        }
    }
    
    func deleteConnection(id: String) throws {
        var connections = try getConnections()
        connections.removeAll { $0.id == id }
        try saveConnections(connections)
    }
    
    func getDefaultConnection() throws -> AIConnectionModel? {
        let connections = try getConnections()
        return connections.first { $0.isDefault }
    }
    
    func setDefaultConnection(id: String) throws {
        var connections = try getConnections()
        for i in 0..<connections.count {
            let connection = connections[i]
            let updatedConnection = AIConnectionModel(
                id: connection.id,
                apiProvider: connection.apiProvider,
                apiKey: connection.apiKey,
                apiUrl: connection.apiUrl,
                model: connection.model,
                isDefault: (connection.id == id)
            )
            connections[i] = updatedConnection
        }
        try saveConnections(connections)
    }
}
