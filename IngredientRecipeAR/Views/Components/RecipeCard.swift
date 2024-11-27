import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe
    let onSelect: (Recipe) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name)
                .font(.headline)
            
            Text("Match Score: \(Int(recipe.matchScore * 100))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Ingredients:")
                .font(.headline)
            ForEach(recipe.ingredients) { ingredient in
                Text("• \(ingredient.name)")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .onTapGesture {
            onSelect(recipe)
        }
    }
}

#Preview {
    RecipeCardView(
        recipe: Recipe(
            name: "Apple Pie",
            ingredients: [
                RecipeIngredient(name: "Apple"),
                RecipeIngredient(name: "Sugar"),
                RecipeIngredient(name: "Flour")
            ],
            instructions: "1. Mix ingredients\n2. Bake at 350°F",
            cuisine: "American",
            prepTime: "30 M",
            cookTime: "45 M",
            description: "Classic American apple pie",
            matchScore: 0.9
        ),
        onSelect: { _ in }
    )
}
