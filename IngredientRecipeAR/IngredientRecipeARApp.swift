import SwiftUI

@main
struct IngredientRecipeARApp: App {
    private let mediaProvider = MediaProvider()
    private let detectionManager: DetectionManager
    @State private var appModel = AppModel()

    init() {
        MetalHelper.setupMetalLib()
        detectionManager = DetectionManager(mediaProvider: mediaProvider)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environmentObject(mediaProvider)
                .environmentObject(detectionManager)
        }
    }
}
