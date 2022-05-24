//
//  NetworkService.swift
//  CocktailFinder
//
//  Created by Moritz Dallendörfer
//

import Foundation
import UIKit

class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
    
    // TODO: Check if a network connection is available
    
    /// Gets all cocktails from cocktail-api that start with a specific letter
    ///
    /// - Parameter searchChar: First letter of cocktails
    /// - Returns: Array of tuples containing the name and api-id of the cocktail
    func searchForCocktails(searchChar: Character, completion: @escaping (([(name: String, id: String)]) -> Void)) {
    
        var foundCocktails = [(name: String, id: String)]()
        
        var domain = "https://www.thecocktaildb.com/api/json/v1/1/search.php?f="
        domain.append(searchChar)
        
        guard let url = URL(string: domain) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                print("Error with fetching cocktails: \(error)")
                return
            }
                  
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }

            if let data = data {
            do {
                guard let drinks = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }

                if let drinkList = drinks["drinks"] as? NSArray {
                    
                    // Clear old list
                    foundCocktails.removeAll()
                    
                    drinkList.forEach( { drink in
                        if let dict = drink as? NSDictionary {
                            
                            // Get name and id of drink
                            if let name = (dict["strDrink"] as? String) {
                                if let id = (dict["idDrink"] as? String)
                                {
                                    // Save them in a tuple
                                    let cocktail = (name: name, id: id)
                                    foundCocktails.append(cocktail)
                                }
                            }
                        }
                    })
                }
                // Return filled foundCocktail array
                DispatchQueue.main.async {
                    completion(foundCocktails)
                }
            } catch  {
                print("Error trying to convert data to JSON")
                return
            }
            }
        })
        task.resume()
    }
    
    /// Gets a specific cocktail with their detail information from a cocktail api
    ///
    /// - Parameter searchId: Cocktail-api id of the searched cocktail
    /// - Returns: Cocktail object
    func searchCocktailDetails(searchId: String, completion: @escaping ((Cocktail) -> Void)) {
        
        var lastSearchedCocktail = Cocktail(id: searchId)
        
        var domain = "https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i="
        domain.append(String(searchId))
        
        guard let url = URL(string: domain) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if let error = error {
                print("Error with fetching cocktails: \(error)")
                return
            }
                  
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data {
            do {
                guard let drinks = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Error trying to convert data to JSON")
                    return
                }
                
                if let drinkList = drinks["drinks"] as? NSArray {
                    drinkList.forEach( { drink in
                        if let dict = drink as? NSDictionary {
                            
                            // Get information of drink
                            if let name = (dict["strDrink"] as? String) {
                                lastSearchedCocktail.name = name
                            }
                            
                            if let category = (dict["strCategory"] as? String) {
                                lastSearchedCocktail.category = category
                            }
                            
                            if let strAlcoholic = (dict["strAlcoholic"] as? String) {
                                if (strAlcoholic == "Alcoholic") {
                                    lastSearchedCocktail.isAlcoholic = true
                                }
                                else {
                                    lastSearchedCocktail.isAlcoholic = false
                                }
                            }
                            
                            if let glass = (dict["strGlass"] as? String) {
                                lastSearchedCocktail.glass = glass
                            }
                            
                            if let instructions = (dict["strInstructions"] as? String) {
                                lastSearchedCocktail.instructions = instructions
                            }
                            
                            if let picture = (dict["strDrinkThumb"] as? String) {
                                lastSearchedCocktail.picture = picture
                            }
                            
                            var ingredients = [String]()
                            for i in 1...15 {
                                let searchString = "strIngredient\(String(i))"
                                if let ingredient = (dict[searchString] as? String)
                                {
                                    ingredients.append(ingredient)
                                }
                                else {
                                    ingredients.append("N/A")
                                }
                            }
                            lastSearchedCocktail.ingredients = ingredients
                                    
                            var measures = [String]()
                            for i in 1...15 {
                                let searchString = "strMeasure\(String(i))"
                                if let measure = (dict[searchString] as? String)
                                {
                                    measures.append(measure)
                                }
                                else {
                                    measures.append("N/A")
                                }
                            }
                            lastSearchedCocktail.measures = measures
                                    
                            // Return filled cocktail object
                            DispatchQueue.main.async {
                                completion(lastSearchedCocktail)
                            }
                        }
                    })
                }
            }
            catch  {
                print("Error trying to convert data to JSON")
                return
            }
            }
        })
        task.resume()
    }
}
