import SwiftUI

struct DetectionOverlayView: View {
    let frameImage: CGImage
    let detectedIngredients: [DetectedIngredient]
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            let (displayedImageSize, imageOrigin) = calculateImageLayout(
                containerSize: geometry.size,
                imageSize: imageSize
            )
            
            ZStack {
                // Background container
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                // Image
                Image(decorative: frameImage, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                
                // Bounding boxes with improved visual style
                ForEach(detectedIngredients) { ingredient in
                    let scaledBox = getScaledBoundingBox(
                        ingredient.boundingBox,
                        imageSize: imageSize,
                        displayedImageSize: displayedImageSize,
                        imageOrigin: imageOrigin
                    )
                    
                    BoundingBoxView(
                        frame: scaledBox,
                        ingredient: ingredient
                    )
                    .shadow(radius: 2)
                }
            }
        }
    }
    
    private func calculateImageLayout(containerSize: CGSize, imageSize: CGSize) -> (size: CGSize, origin: CGPoint) {
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = containerSize.width / containerSize.height
        
        if imageAspectRatio > viewAspectRatio {
            let width = containerSize.width
            let height = width / imageAspectRatio
            return (
                CGSize(width: width, height: height),
                CGPoint(x: 0, y: (containerSize.height - height) / 2)
            )
        } else {
            let height = containerSize.height
            let width = height * imageAspectRatio
            return (
                CGSize(width: width, height: height),
                CGPoint(x: (containerSize.width - width) / 2, y: 0)
            )
        }
    }

    private func getScaledBoundingBox(
        _ boundingBox: CGRect,
        imageSize: CGSize,
        displayedImageSize: CGSize,
        imageOrigin: CGPoint
    ) -> CGRect {
        // Calculate scale factors between the original image and the displayed image
        let xScale = displayedImageSize.width
        let yScale = displayedImageSize.height

        // Adjust the bounding box coordinates
        let scaledX = boundingBox.origin.x * xScale + imageOrigin.x
        let scaledY = (1 - boundingBox.origin.y - boundingBox.height) * yScale + imageOrigin.y
        let scaledWidth = boundingBox.size.width * xScale
        let scaledHeight = boundingBox.size.height * yScale

        return CGRect(
            x: scaledX,
            y: scaledY,
            width: scaledWidth,
            height: scaledHeight
        )
    }
}

struct BoundingBoxView: View {
    let frame: CGRect
    let ingredient: DetectedIngredient

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.midX, y: frame.midY)

            Text("\(ingredient.name) (\(Int(ingredient.confidence * 100))%)")
                .font(.caption)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(5)
                .offset(x: frame.minX, y: frame.minY - 20)
        }
    }
}
