import Foundation
import SwiftUI
import AVFoundation
import PhotosUI

class MediaProvider: ObservableObject {
    @Published var selectedVideoURL: URL?
    @Published var selectedFrames: [CGImage] = []

    func extractFrames() async {
        guard let videoURL = selectedVideoURL else {
            print("⚠️ No video URL selected")
            return
        }

        print("📽️ Starting frame extraction from video")
        let asset = AVAsset(url: videoURL)
        
        do {
            let duration = try await asset.load(.duration)
            let totalSeconds = Int(CMTimeGetSeconds(duration))
            print("📊 Video duration: \(totalSeconds) seconds")
            
            if let track = try await asset.loadTracks(withMediaType: .video).first {
                let size = try await track.load(.naturalSize)
                print("🖼️ Video size: \(size)")
                
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.requestedTimeToleranceBefore = .zero
                generator.requestedTimeToleranceAfter = .zero
                
                var extractedFrames: [CGImage] = []
                
                // Extract frames at 0.5-second intervals
                for frame in 0..<(totalSeconds * 2) {
                    let time = CMTime(seconds: Double(frame) * 0.5, preferredTimescale: 600)
                    do {
                        let imageResult = try await generator.image(at: time)
                        extractedFrames.append(imageResult.image)
                        print("✅ Extracted frame \(frame + 1)/\(totalSeconds * 2)")
                    } catch {
                        print("⚠️ Failed to extract frame \(frame + 1): \(error.localizedDescription)")
                    }
                }
                
                await MainActor.run {
                    self.selectedFrames = extractedFrames
                    print("🎬 Total frames extracted: \(extractedFrames.count)")
                }
            }
        } catch {
            print("❌ Error extracting frames: \(error.localizedDescription)")
        }
    }

    func cleanup() {
        selectedVideoURL = nil
        selectedFrames.removeAll()
        print("🧹 Cleaned up MediaProvider data")
    }
}