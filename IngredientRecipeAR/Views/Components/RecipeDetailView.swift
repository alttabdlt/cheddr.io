import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()

                Text("Cuisine: \(recipe.cuisine)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Preparation Time: \(recipe.prepTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Cook Time: \(recipe.cookTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Description:")
                    .font(.headline)
                Text(recipe.description)
                    .font(.body)

                Text("Ingredients:")
                    .font(.headline)
                ForEach(recipe.ingredients) { ingredient in
                    Text("• \(ingredient.name)")
                        .font(.body)
                }

                Text("Instructions:")
                    .font(.headline)
                Text(recipe.instructions)
                    .font(.body)
            }
            .padding()
        }
    }
}

#Preview {
    RecipeDetailView(
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
        )
    )
}
