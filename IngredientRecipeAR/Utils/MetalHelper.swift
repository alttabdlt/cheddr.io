import Metal
import Foundation

class MetalHelper {
    static func setupMetalLib() {
        if let device = MTLCreateSystemDefaultDevice() {
            do {
                _ = try device.makeDefaultLibrary(bundle: Bundle.main)
                print("✅ Metal library setup successful")
            } catch {
                print("⚠️ Could not create default Metal library - this is expected in simulator")
            }
        }
    }
} 