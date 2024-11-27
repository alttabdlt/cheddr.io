import Foundation
import SwiftUI

@MainActor
class RecipeManager: ObservableObject {
    @Published var recipes: [Recipe] = []
    private let threshold: Float = 0.7
    
    init() {
        loadRecipes()
    }
    
    private func loadRecipes() {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load recipes.json")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            self.recipes = try decoder.decode([Recipe].self, from: data)
            print("✅ Successfully loaded recipes: \(recipes.count) recipes")
        } catch {
            print("Failed to decode recipes: \(error)")
        }
    }
    
    func findMatchingRecipes(for ingredients: [DetectedIngredient]) -> [Recipe] {
        let detectedIngredientNames: Set<String> = Set(
            ingredients
                .filter { $0.confidence > threshold }
                .map { $0.name.lowercased() }
        )
        
        var matchedRecipes: [Recipe] = []
        
        for recipe in recipes {
            var matchedRecipe = recipe
            let recipeIngredientNames: Set<String> = Set(
                recipe.ingredients.map { $0.name.lowercased() }
            )
            
            // Calculate exact matches
            let exactMatches = recipeIngredientNames.intersection(detectedIngredientNames)
            
            // Calculate partial matches
            let partialMatches = recipeIngredientNames.filter { recipeIngredient in
                detectedIngredientNames.contains { detectedIngredient in
                    detectedIngredient.contains(recipeIngredient) ||
                    recipeIngredient.contains(detectedIngredient)
                }
            }
            
            let totalIngredients = Float(recipeIngredientNames.count)
            let partialMatchesCount = Float(partialMatches.count - exactMatches.count)
            let matchScore = (
                Float(exactMatches.count) * 1.0 +
                partialMatchesCount * 0.5
            ) / totalIngredients
            
            matchedRecipe.matchScore = matchScore
            
            if matchedRecipe.matchScore > 0.1 {
                matchedRecipes.append(matchedRecipe)
            }
        }
        
        // Sort matched recipes by match score in descending order
        let sortedMatchedRecipes = matchedRecipes.sorted { $0.matchScore > $1.matchScore }
        
        // Return top 3 recipes
        return Array(sortedMatchedRecipes.prefix(3))
    }
}
