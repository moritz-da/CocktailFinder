//
//  Helper.swift
//  CocktailFinder
//
//  Created by Moritz Dallendörfer
//

import Foundation
import UIKit
import CoreData

class Helper {
    
    static let shared = Helper()
    private init() {}
    
    // MARK: - Filter objects
    
    /// Filters given cocktail tuples using a searchString
    ///
    /// - Parameter cocktailTuples: Array of cocktail tuples
    /// - Parameter searchString: String that is searched for
    /// - Returns: Array with cocktail names matching the searchString
    func extractCocktailNames(cocktailTuples: [(name: String, id: String)], searchString: String) -> [String] {
        var cocktailNames = [String]()
        
        cocktailTuples.forEach { cocktailTuple in
            cocktailNames.append(cocktailTuple.name)
        }
        
        cocktailNames = cocktailNames.filter( { (names: String) -> Bool in
          return names.lowercased().range(of: searchString.lowercased()) != nil
        })
        
        return cocktailNames
    }
    
    /// Extract only the names of a cocktail array
    ///
    /// - Parameter cocktails: Array of cocktail objects
    /// - Returns: Array with cocktail names
    func extractCocktailNames(cocktails: [Cocktail]) -> [String] {
        var cocktailNames = [String]()
        
        cocktails.forEach { cocktail in
            cocktailNames.append(cocktail.name)
        }
        
        // TODO: Eventually filter by search String
        
        return cocktailNames
    }
    
    /// Gets the id of a cocktail by its name
    ///
    /// - Parameter cocktailTuples: Array of cocktail tuples
    /// - Parameter searchName: Cocktail that is searched for
    /// - Returns: Cocktail api-id matching the searched Cocktail
    func findCocktailId(cocktailTuples: [(name: String, id: String)], searchName: String) -> String? {
        var cocktailId = String()
        
        cocktailTuples.forEach { cocktailTuple in
            if (searchName == cocktailTuple.name) {
                cocktailId = cocktailTuple.id
            }
        }
        
        if !cocktailId.isEmpty {
            return cocktailId
        }
        return nil
    }
    
    // MARK: - Convert objects
    
    /// Converts a CoktailDbObj array in a Cocktail array
    ///
    /// - Parameter cocktailDbObjs: Array of CocktailDbObj objects
    /// - Returns: Array of Cocktail objects
    func cocktailDbObjs2cocktailObjs(cocktailDbObjs: [CocktailDbObj]) -> [Cocktail] {
        var cocktailObjs = [Cocktail]()
        
        cocktailDbObjs.forEach { cocktail in
            let tmpCocktailObj = Cocktail.init(name: cocktail.name ?? "N/A", id: cocktail.id ?? "N/A", category: cocktail.category ?? "N/A", isAlcoholic: cocktail.isAlcoholic, glass: cocktail.glass ?? "N/A", instructions: cocktail.instructions ?? "N/A", picture: cocktail.picture ?? "N/A", ingredients: cocktail.ingredients ?? ["N/A"], measures: cocktail.measures ?? ["N/A"])
            cocktailObjs.append(tmpCocktailObj)
        }
        
        return cocktailObjs
    }
    
    /// Converts a Cocktail object in a CoktailDbObj object
    ///
    /// - Parameter cocktailObj: Cocktail object
    /// - Returns: CocktailDbObj object
    func cocktailObj2cocktailDbObj(cocktailObj: Cocktail) -> CocktailDbObj {
        // Access AppDelegate and NSManagedObjectContext
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let cocktailDbObj = CocktailDbObj(context: context)
        
        cocktailDbObj.id = cocktailObj.id
        cocktailDbObj.name = cocktailObj.name
        cocktailDbObj.category = cocktailObj.category
        cocktailDbObj.isAlcoholic = cocktailObj.isAlcoholic
        cocktailDbObj.glass = cocktailObj.glass
        cocktailDbObj.instructions = cocktailObj.instructions
        cocktailDbObj.picture = cocktailObj.picture
        cocktailDbObj.ingredients = cocktailObj.ingredients
        cocktailDbObj.measures = cocktailObj.measures
        
        return cocktailDbObj
    }
    
    // MARK: - Core Data
    
    /// Adds a Cocktail object to core data
    ///
    /// - Parameter cocktail: Cocktail object to be added
    func addCocktailToCoreData(cocktail: Cocktail) {
        // Access AppDelegate and NSManagedObjectContext
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let cocktailDbObj = CocktailDbObj(context: context)
        
        // TODO: Use method above
        cocktailDbObj.id = cocktail.id
        cocktailDbObj.name = cocktail.name
        cocktailDbObj.category = cocktail.category
        cocktailDbObj.isAlcoholic = cocktail.isAlcoholic
        cocktailDbObj.glass = cocktail.glass
        cocktailDbObj.instructions = cocktail.instructions
        cocktailDbObj.picture = cocktail.picture
        cocktailDbObj.ingredients = cocktail.ingredients
        cocktailDbObj.measures = cocktail.measures
        
        // Save movieObj in core data
        appDelegate.saveContext()
    }
    
    /// Gets all Cocktail objects from core data
    ///
    /// - Returns: Cocktail object array
    func getCocktailsFromCoreData() -> [Cocktail] {
        // Access AppDelegate and NSManagedObjectContext
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var cocktailDbObjs = [CocktailDbObj]()
        var cocktails = [Cocktail]()
        
        do {
            let result = try context.fetch(CocktailDbObj.fetchRequest())
            for cocktail in result {
                cocktailDbObjs.append(cocktail)
            }
            
            cocktails = cocktailDbObjs2cocktailObjs(cocktailDbObjs: cocktailDbObjs)
        }
        catch let error {
           print(error)
        }
        
        return cocktails
    }
    
    /// Deletes a Cocktail object from core data
    ///
    /// - Parameter cocktail: Cocktail object to be removed
    func deleteCocktailFromCoreData(cocktail2delete: Cocktail) {
        // Access AppDelegate and NSManagedObjectContext
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let result = try context.fetch(CocktailDbObj.fetchRequest())
            for cocktail in result {
                if (cocktail.id == cocktail2delete.id) {
                    context.delete(cocktail)
                }
            }
            try context.save()
        }
        catch let error {
           print(error)
        }
    }

    /// Checks if a Cocktail object is already in core data
    ///
    /// - Parameter cocktail: Cocktail object to be checked
    /// - Returns: Bool of already in core data
    func isCocktailAlreadyAdded(cocktail: Cocktail) -> Bool {
        let addedCocktails = getCocktailsFromCoreData()
        var isAlreadyAdded = false
        
        addedCocktails.forEach { addedCocktail in
            if (addedCocktail.id == cocktail.id) {
                isAlreadyAdded = true
            }
        }
        return isAlreadyAdded
    }
    
    /*
     
    /// Saves a Cocktail object in user defaults
    ///
    /// - Parameter cocktail: Cocktail object to be saved
    /// - Parameter key: Key for user defaults
    func saveCocktailInUserDefaults(cocktail: Cocktail, key: String) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(cocktail)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: key)

        } catch {
            print("Unable to Encode Cocktail (\(error))")
        }
    }
    
    /// Loads a Cocktail object from user defaults
    ///
    /// - Parameter key: Key for user defaults
    /// - Returns: Cocktail object or nil when not found
    func loadCocktailFromUserdefaults(key: String) -> Cocktail? {
        
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let cocktail = try decoder.decode(Cocktail.self, from: data)
                return cocktail
            } catch {
                print("Unable to Decode Cocktail (\(error))")
            }
        }
        return nil
    }
     
     */
}
