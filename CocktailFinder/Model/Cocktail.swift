//
//  Cocktail.swift
//  CocktailFinder
//
//  Created by Moritz Dallendörfer
//

import Foundation

struct Cocktail: Codable {
    
    var id = String()
    var name = "N/A"
    var category = "N/A"
    var isAlcoholic = false
    var glass = "N/A"
    var instructions = "N/A"
    var picture = "N/A"
    var ingredients = ["N/A"]
    var measures = ["N/A"]
    
    // every cocktail must have an id
    init(id: String) {
        self.id = id
    }
    
    init(name: String, id: String, category: String, isAlcoholic: Bool, glass: String, instructions: String, picture: String, ingredients: [String], measures: [String]) {
        self.name = name
        self.id = id
        self.category = category
        self.isAlcoholic = isAlcoholic
        self.glass = glass
        self.instructions = instructions
        self.picture = picture
        self.ingredients = ingredients
        self.measures = measures
    }
}
