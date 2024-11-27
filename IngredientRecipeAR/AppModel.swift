//
//  AppModel.swift
//  IngredientRecipeAR
//
//  Created by AXEL on 24/11/24.
//

import SwiftUI
import Observation

@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var topRecipes: [Recipe] = []
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
}
