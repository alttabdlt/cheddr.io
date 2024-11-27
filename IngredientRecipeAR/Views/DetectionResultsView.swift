import SwiftUI

struct DetectionResultsView: View {
    let detectedIngredients: [DetectedIngredient]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var recipeManager = RecipeManager()
    @Environment(AppModel.self) private var appModel
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationStack {
            List {
                if detectedIngredients.isEmpty {
                    Text("No ingredients detected")
                        .foregroundColor(.secondary)
                } else {
                    Section("Detected Ingredients") {
                        ForEach(Array(Set(detectedIngredients)), id: \.id) { ingredient in
                            IngredientCardView(ingredient: ingredient)
                        }
                    }
                    
                    if !appModel.topRecipes.isEmpty {
                        Section("Suggested Recipes") {
                            ForEach(appModel.topRecipes) { recipe in
                                Button(action: { selectedRecipe = recipe }) {
                                    HStack {
                                        Text(recipe.name)
                                        Spacer()
                                        Text("Match: \(Int(recipe.matchScore * 100))%")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Results")
            .navigationDestination(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
                    .navigationBarTitleDisplayMode(.inline)
            }
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
            .onAppear {
                let matchedRecipes = recipeManager.findMatchingRecipes(for: detectedIngredients)
                appModel.topRecipes = Array(matchedRecipes.prefix(3))
            }
        }
    }
} 