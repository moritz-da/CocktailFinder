//
//  CocktailSearchViewController.swift
//  CocktailFinder
//
//  Created by Moritz Dallendörfer
//

import UIKit

class CocktailSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var foundCocktailNames = [String]()
    var foundCocktails = [(name: String, id: String)]()
    var lastSearchedInitialChar: Character = " "
    var shoppingLists = [String : [String]]()
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return foundCocktailNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = foundCocktailNames[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showCocktailDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! DetailViewController
                
                let cocktailName = foundCocktailNames[indexPath.row]
                
                var id = String()
                foundCocktails.forEach { tuple in
                    if (cocktailName == tuple.name) {
                        id = tuple.id
                    }
                }
                controller.selectedCocktail = Cocktail.init(id: id)
            }
        }
    }
    
    
    // MARK: - SearchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (!searchText.isEmpty) {
            let searchChar = Character((searchText[searchText.index(searchText.startIndex, offsetBy: 0)]).uppercased())
            if (lastSearchedInitialChar != searchChar) {
                
                // fetch new cocktails from api
                self.loadingIndicator.startAnimating()
                NetworkService.shared.searchForCocktails(searchChar: searchChar) { (foundCocktails) in
                    self.loadingIndicator.stopAnimating()
                    self.foundCocktails = foundCocktails
                    self.foundCocktailNames = Helper.shared.extractCocktailNames(cocktailTuples: foundCocktails, searchString: searchText)
                    self.tableView.reloadData()
                }
                lastSearchedInitialChar = searchChar
            }
            else {
                // Filter only existing cocktails
                self.foundCocktailNames = Helper.shared.extractCocktailNames(cocktailTuples: foundCocktails, searchString: searchText)
                self.tableView.reloadData()
            }
        }
        else {
            // show empty list
            foundCocktailNames.removeAll()
            self.tableView.reloadData()
        }
        
    }
}
     

extension CocktailSearchViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(CocktailSearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
