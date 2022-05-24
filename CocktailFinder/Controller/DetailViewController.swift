//
//  DetailViewController.swift
//  CocktailFinder
//
//  Created by Moritz Dallendörfer
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedCocktail = Cocktail(id: "")
    var hideButton = false
    var ingredients = [String]()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var instructionTextView: UITextView!
    @IBOutlet weak var picNotAvailable: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self

        setCocktailInformation()
        
        setAddButtonStatus()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addToMyCocktails(_ sender: Any) {
        Helper.shared.addCocktailToCoreData(cocktail: selectedCocktail)
        setAddButtonStatus()
    }
    
    func setAddButtonStatus() {
        if hideButton {
            addButton.isHidden = true
        }
        else if Helper.shared.isCocktailAlreadyAdded(cocktail: selectedCocktail) {
            addButton.isEnabled = false
        }
    }
    
    func setCocktailInformation() {
        self.activityIndicator.startAnimating()
        NetworkService.shared.searchCocktailDetails(searchId: selectedCocktail.id) { (cocktail) in
            self.activityIndicator.stopAnimating()
            self.selectedCocktail = cocktail
            
            if (self.selectedCocktail.picture.isEmpty) {
                self.picNotAvailable.isHidden = false
            }
            else {
                self.picNotAvailable.isHidden = true
                self.imageView.downloadImage(from: URL(string: self.selectedCocktail.picture)!)
            }
            
            self.nameLabel.text = self.selectedCocktail.name
            
            var information = self.selectedCocktail.category
            information.append(" · ")
            if (self.selectedCocktail.isAlcoholic) {
                information.append("alcoholic")
            }
            else {
                information.append("non alcoholic")
            }
            information.append(" · ")
            information.append(self.selectedCocktail.glass)
            self.informationLabel.text = information
            
            self.instructionTextView.text = self.selectedCocktail.instructions
            
            
            // Fill table view
            for i in 0...14 {
                var content = String()
                if (self.selectedCocktail.measures[i] != "N/A") {
                    content.append(self.selectedCocktail.measures[i])
                }
                if (self.selectedCocktail.ingredients[i] != "N/A") {
                    
                    if (self.selectedCocktail.ingredients[i].prefix(1) != " ") {
                        content.append(" ")
                    }
                    content.append(self.selectedCocktail.ingredients[i])
                    self.ingredients.append(content)
                }
                
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = ingredients[indexPath.row]
        //cell.measureField?.text = measures[indexPath.row]
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImageView {
   func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
      URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
   }
   func downloadImage(from url: URL) {
      getData(from: url) {
         data, response, error in
         guard let data = data, error == nil else {
            return
         }
         DispatchQueue.main.async() {
            self.image = UIImage(data: data)
         }
      }
   }
}
