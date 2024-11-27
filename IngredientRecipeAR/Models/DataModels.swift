import SwiftUI
import CoreGraphics

// MARK: - DetectedIngredient

struct DetectedIngredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let confidence: Float
    let boundingBox: CGRect
    var worldPosition: SIMD3<Float>?

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }

    static func == (lhs: DetectedIngredient, rhs: DetectedIngredient) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}

// MARK: - RecipeIngredient

struct RecipeIngredient: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name.lowercased())
    }

    static func == (lhs: RecipeIngredient, rhs: RecipeIngredient) -> Bool {
        lhs.name.lowercased() == rhs.name.lowercased()
    }
}

// MARK: - Recipe

struct Recipe: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let ingredients: [RecipeIngredient]
    let instructions: String
    let cuisine: String
    let prepTime: String
    let cookTime: String
    let description: String
    var matchScore: Float = 0.0

    enum CodingKeys: String, CodingKey {
        case name = "recipe_title"
        case ingredients
        case instructions
        case cuisine
        case prepTime = "prep_time"
        case cookTime = "cook_time"
        case description
    }

    // Member-wise initializer
    init(
        id: UUID = UUID(),
        name: String,
        ingredients: [RecipeIngredient],
        instructions: String,
        cuisine: String,
        prepTime: String,
        cookTime: String,
        description: String,
        matchScore: Float = 0.0
    ) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.cuisine = cuisine
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.description = description
        self.matchScore = matchScore
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID() // Generate a new UUID since it's not provided in the JSON

        self.name = try container.decode(String.self, forKey: .name)

        // Parse the ingredients from a single string separated by "|"
        let ingredientString = try container.decode(String.self, forKey: .ingredients)
        let ingredientNames = ingredientString.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
        self.ingredients = ingredientNames.map { RecipeIngredient(name: $0) }

        self.instructions = try container.decode(String.self, forKey: .instructions)
        self.cuisine = try container.decode(String.self, forKey: .cuisine)
        self.prepTime = try container.decode(String.self, forKey: .prepTime)
        self.cookTime = try container.decode(String.self, forKey: .cookTime)
        self.description = try container.decode(String.self, forKey: .description)
        self.matchScore = 0.0
    }

    // Implement Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - RecipeMatchError

enum RecipeMatchError: Error {
    case noIngredientsDetected
    case noMatchingRecipes
}
