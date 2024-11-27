import SwiftUI
import PhotosUI

struct VideoPicker: View {
    @Binding var selectedVideoURL: URL?
    @State private var selectedItem: PhotosPickerItem?
    @EnvironmentObject var detectionManager: DetectionManager

    var body: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .videos,
            photoLibrary: .shared()
        ) {
            HStack {
                Image(systemName: "video.badge.plus")
                Text("Select Video")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .onChange(of: selectedItem) { newItem in
            // Clean up previous data
            selectedVideoURL = nil
            detectionManager.cleanup()
            
            guard let item = newItem else { return }
            Task {
                do {
                    if let data = try await item.loadTransferable(type: Data.self),
                       let tempDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                        try data.write(to: tempURL)
                        selectedVideoURL = tempURL
                    }
                } catch {
                    print("Error loading video: \(error.localizedDescription)")
                }
            }
        }
    }
}

