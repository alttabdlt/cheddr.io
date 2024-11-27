import Vision
import CoreML
import SwiftUI

class DetectionManager: ObservableObject {
    @Published var detectedIngredients: [DetectedIngredient] = []
    @Published var state: DetectionState = .initializing
    @Published var processedFrames: [CGImage] = []
    @Published var detectedIngredientsByFrame: [[DetectedIngredient]] = []
    
    var mediaProvider: MediaProvider
    private var visionModel: VNCoreMLModel?

    init(mediaProvider: MediaProvider) {
        self.mediaProvider = mediaProvider
        setupModel()
    }

    private func setupModel() {
        do {
            print("Setting up ML model...")
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndGPU

            guard let modelURL = Bundle.main.url(forResource: "best", withExtension: "mlmodelc") else {
                throw NSError(domain: "ModelLoading", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "No model file found in bundle"])
            }

            print("Found compiled model at: \(modelURL)")
            let model = try MLModel(contentsOf: modelURL, configuration: config)
            visionModel = try VNCoreMLModel(for: model)
            print("✅ ML model setup successful")
            state = DetectionState.ready
        } catch {
            state = DetectionState.failed(error)
            print("❌ Error setting up model: \(error.localizedDescription)")
        }
    }

    func processVideoFrames() async {
        guard let visionModel = visionModel else {
            print("⚠️ Vision model not initialized")
            return
        }

        print("🔍 Starting video frame processing")
        print("📊 Number of frames to process: \(mediaProvider.selectedFrames.count)")
        
        await MainActor.run {
            detectedIngredients.removeAll()
            detectedIngredientsByFrame.removeAll()
            processedFrames = mediaProvider.selectedFrames
            state = .scanning
        }

        for (index, cgImage) in mediaProvider.selectedFrames.enumerated() {
            print("🔍 Processing frame \(index + 1)/\(mediaProvider.selectedFrames.count)")
            await detectIngredients(in: cgImage, atIndex: index)
        }

        await MainActor.run {
            print("✅ Frame processing complete")
            print("📊 Total detected ingredients: \(detectedIngredients.count)")
            
            // Remove duplicates from overall detected ingredients
            detectedIngredients = Array(Set(detectedIngredients))
            
            state = .ready
        }
    }

    func detectIngredients(in cgImage: CGImage, atIndex index: Int) async {
        return await withCheckedContinuation { continuation in
            let request = VNCoreMLRequest(model: visionModel!) { [weak self] request, error in
                guard let self = self else { 
                    continuation.resume()
                    return 
                }
                
                if let error = error {
                    print("❌ Vision request error: \(error.localizedDescription)")
                    continuation.resume()
                    return
                }

                if let observations = request.results as? [VNRecognizedObjectObservation] {
                    print("✅ Found \(observations.count) objects in frame \(index)")
                    self.processObservations(observations, forFrameAt: index)
                } else {
                    print("⚠️ No observations found in frame \(index)")
                    Task { @MainActor in
                        self.detectedIngredientsByFrame.append([])
                    }
                }
                continuation.resume()
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("❌ Vision request failed: \(error.localizedDescription)")
                continuation.resume()
            }
        }
    }

    private func processObservations(_ observations: [VNRecognizedObjectObservation], forFrameAt index: Int) {
        let ingredients = observations.compactMap { observation -> DetectedIngredient? in
            guard let topLabel = observation.labels.max(by: { $0.confidence < $1.confidence }) else {
                return nil
            }

            return DetectedIngredient(
                name: topLabel.identifier,
                confidence: topLabel.confidence,
                boundingBox: observation.boundingBox
            )
        }

        Task { @MainActor in
            self.detectedIngredients.append(contentsOf: ingredients)
            if index >= self.detectedIngredientsByFrame.count {
                self.detectedIngredientsByFrame.append(ingredients)
            } else {
                self.detectedIngredientsByFrame[index] = ingredients
            }
            print("💡 Added \(ingredients.count) ingredients for frame \(index)")
        }
    }

    func cleanup() {
        detectedIngredients.removeAll()
        detectedIngredientsByFrame.removeAll()
        processedFrames.removeAll()
        state = .ready
        print("🧹 Cleaned up DetectionManager data")
    }
}
