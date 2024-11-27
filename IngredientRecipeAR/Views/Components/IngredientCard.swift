import SwiftUI

struct IngredientCardView: View {
    let ingredient: DetectedIngredient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(ingredient.name.capitalized)
                    .font(.headline)
                Text("Confidence: \(Int(ingredient.confidence * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .opacity(ingredient.confidence > 0.7 ? 1 : 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    IngredientCardView(
        ingredient: DetectedIngredient(
            name: "Apple",
            confidence: 0.95,
            boundingBox: .zero
        )
    )
}
