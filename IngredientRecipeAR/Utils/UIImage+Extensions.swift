import UIKit

extension UIImage {
    static func debugLoadImage(named name: String) -> UIImage? {
        // Try loading with different methods
        if let image = UIImage(named: name) {
            print("✅ Loaded image directly: \(name)")
            return image
        }
        
        if let image = UIImage(named: name, in: .main, compatibleWith: nil) {
            print("✅ Loaded image with explicit bundle: \(name)")
            return image
        }
        
        // List available image names in asset catalog
        if let bundlePath = Bundle.main.resourcePath {
            print("📁 Bundle resource path: \(bundlePath)")
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                print("📑 Bundle contents: \(contents)")
            } catch {
                print("❌ Failed to list bundle contents: \(error)")
            }
        }
        
        return nil
    }
} 