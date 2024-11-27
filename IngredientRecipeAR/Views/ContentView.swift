import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mediaProvider: MediaProvider
    @EnvironmentObject var detectionManager: DetectionManager
    @State private var currentFrameIndex = 0
    @State private var isProcessing = false
    @State private var showingResults = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Ingredient Detection")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.top)
            
            // Main Content Area
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 10)
                
                VStack(spacing: 20) {
                    if isProcessing {
                        ProcessingView()
                    } else if !detectionManager.processedFrames.isEmpty {
                        // Video Preview
                        DetectionOverlayView(
                            frameImage: detectionManager.processedFrames[currentFrameIndex],
                            detectedIngredients: detectionManager.detectedIngredientsByFrame[currentFrameIndex],
                            imageSize: CGSize(
                                width: detectionManager.processedFrames[currentFrameIndex].width,
                                height: detectionManager.processedFrames[currentFrameIndex].height
                            )
                        )
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 5)
                        
                        // Frame Navigation Controls
                        HStack(spacing: 20) {
                            NavigationButton(
                                icon: "chevron.left",
                                text: "Previous",
                                action: previousFrame,
                                isDisabled: currentFrameIndex == 0
                            )
                            
                            NavigationButton(
                                icon: "chevron.right",
                                text: "Next",
                                action: nextFrame,
                                isDisabled: currentFrameIndex == detectionManager.processedFrames.count - 1
                            )
                        }
                    } else {
                        PlaceholderView()
                    }
                }
                .padding()
            }
            .frame(maxHeight: 500)
            
            // Action Buttons
            VStack(spacing: 16) {
                VideoPicker(selectedVideoURL: $mediaProvider.selectedVideoURL)
                    .disabled(isProcessing)
                
                Button(action: processVideo) {
                    ActionButtonContent(
                        icon: "play.circle.fill",
                        text: "Process Video",
                        isDisabled: mediaProvider.selectedVideoURL == nil || isProcessing
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showingResults) {
            DetectionResultsView(detectedIngredients: detectionManager.detectedIngredients)
        }
    }
    
    private func previousFrame() {
        if currentFrameIndex > 0 {
            currentFrameIndex -= 1
        }
    }
    
    private func nextFrame() {
        if currentFrameIndex < detectionManager.processedFrames.count - 1 {
            currentFrameIndex += 1
        }
    }
    
    private func processVideo() {
        guard !isProcessing else { return }
        
        Task {
            isProcessing = true
            // Clean up previous data
            detectionManager.cleanup()
            await mediaProvider.extractFrames()
            await detectionManager.processVideoFrames()
            isProcessing = false
            showingResults = true
        }
    }
}

// Helper Views
struct ProcessingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Processing video...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.fill")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text("Select a video to begin")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NavigationButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(isDisabled ? .gray.opacity(0.3) : .blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .disabled(isDisabled)
    }
}

struct ActionButtonContent: View {
    let icon: String
    let text: String
    let isDisabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(.headline)
        .padding()
        .frame(maxWidth: .infinity)
        .background(isDisabled ? .gray.opacity(0.3) : .blue)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
        .environmentObject(MediaProvider())
        .environmentObject(DetectionManager(mediaProvider: MediaProvider()))
}
