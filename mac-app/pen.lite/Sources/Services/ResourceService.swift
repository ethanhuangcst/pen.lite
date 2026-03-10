import Cocoa

class ResourceService {
    static let shared = ResourceService()
    
    private init() {}
    
    func getResourcePath(relativePath: String) -> String {
        // Try Bundle.main.resourcePath first (for app bundle)
        if let bundlePath = Bundle.main.resourcePath {
            let path = "\(bundlePath)/\(relativePath)"
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Try executable directory (for app bundle structure)
        if let executablePath = Bundle.main.executablePath {
            let executableDir = URL(fileURLWithPath: executablePath).deletingLastPathComponent().path
            let path = "\(executableDir)/../Resources/\(relativePath)"
            let standardizedPath = URL(fileURLWithPath: path).standardized.path
            if FileManager.default.fileExists(atPath: standardizedPath) {
                return standardizedPath
            }
        }
        
        // Fallback to current directory (for development)
        let currentDir = FileManager.default.currentDirectoryPath
        let path = "\(currentDir)/Resources/\(relativePath)"
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        
        // Return the bundle path even if it doesn't exist (for error messages)
        if let bundlePath = Bundle.main.resourcePath {
            return "\(bundlePath)/\(relativePath)"
        }
        
        return "\(currentDir)/Resources/\(relativePath)"
    }
    
    func resourceExists(relativePath: String) -> Bool {
        let path = getResourcePath(relativePath: relativePath)
        return FileManager.default.fileExists(atPath: path)
    }
    
    func loadImage(named name: String) -> NSImage? {
        let path = getResourcePath(relativePath: "Assets/\(name)")
        return NSImage(contentsOfFile: path)
    }
    
    func loadSVG(named name: String) -> NSImage? {
        let path = getResourcePath(relativePath: "Assets/\(name).svg")
        return NSImage(contentsOfFile: path)
    }
    
    func loadPNG(named name: String) -> NSImage? {
        let path = getResourcePath(relativePath: "Assets/\(name).png")
        return NSImage(contentsOfFile: path)
    }
}
