//
//  RecipeTableViewController.swift
//  BBQApp
//
//  Created by Jared Bruemmer on 10/29/17.
//  Copyright © 2017 Jared Bruemmer. All rights reserved.
//

import UIKit
import WebKit
import CoreData


class RecipeTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    struct Recipe {
        var title : String = ""
        var socialRank : Double = 0.0
        var image : UIImage? = nil
        var imageString : String = ""
        var url : String = ""
    }
    
    var recipes : [Recipe] = []
    
    @IBOutlet var recipeTable: UITableView!
    
    var yourSearch = "BBQ"
    var searchActive : Bool = false
    var selectedItem : Int = 0
    //var userEmail : String = ""
    var userId : String = ""
    //var userName : String = ""
    var people: [NSManagedObject] = []

  
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //if isFiltering() {
        return recipes.count
        // }
        //return self.recipeTitle1.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = recipeTable.dequeueReusableCell(withIdentifier: "recipecell", for: indexPath)
        var title : String
        guard indexPath.row >= 0 && indexPath.row < recipes.count else {return cell}
        title = recipes[indexPath.row].title
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = String(recipes[indexPath.row].socialRank)
        cell.accessoryType = .detailDisclosureButton
        //cell.imageView?.image = recipeImages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        doSomethingWithItem(index: indexPath.row)
        
    }
    
    func doSomethingWithItem(index: Int ){
    //print(recipes[index].title)
    //print(recipes[index].url)
    //print(userId)
    
        postToServerFunction(index: index)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) -> Int  {
        selectedItem = indexPath.row
        //print(selectedItem)
        return selectedItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiSearch(yourSearch)
        recipeTable.delegate = self
        recipeTable.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Recipes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.delegate = self as? UISearchControllerDelegate
        fetchUserData()
        //print(userId)
    }
 
    func fetchUserData(){
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "User")
        
        //3
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let index = people.count
        let person = people[index - 1]
        userId = (person.value(forKeyPath: "id") as? String)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("search active = true")
        searchActive = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("search active = false")
        searchActive = false
        updateSearchResults(for: searchController)
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard self.searchActive == false else {return}
        print("update search results called")
        yourSearch = searchController.searchBar.text!
        apiSearch(yourSearch)
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func apiSearch( _:String) {
        
        let url = URL (string: "http://food2fork.com/api/search?key=6fb8c103dfd7f27b64b5feaf97e65afc&q=" + yourSearch.replacingOccurrences(of: " ", with: "%20") )!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        var counter = 0
                        self.recipes.removeAll()
                        while counter < jsonResult["count"] as! Int {
                            var newRecipe : Recipe = Recipe()
                            if let title1 = ((jsonResult["recipes"] as? NSArray)?[counter] as? NSDictionary)?["title"] as? String {
                                newRecipe.title = title1
                                //self.recipes.append(title1)
                            }
                            if let rank = ((jsonResult["recipes"] as? NSArray)?[counter] as? NSDictionary)?["social_rank"] as? Double {
                                newRecipe.socialRank = rank
                                //self.socialRank.append(rank)
                            }
                            if let path = ((jsonResult["recipes"] as? NSArray)?[counter] as? NSDictionary)?["f2f_url"] as? String {
                                newRecipe.url = path
                                //self.recipeURL.append(path)
                                
                            }
                            if let image = ((jsonResult["recipes"] as? NSArray)?[counter] as? NSDictionary)?["image_url"] as? String {
                                newRecipe.image = UIImage(data: image.data(using: String.Encoding.utf8)!)
                                //self.recipeImage1.append(image)
                                /*
                                 let image = try? Data(contentsOf: url)
                                 let image1: UIImage = UIImage(data: image!)!
                                 
                                 self.recipeImages.append(image1)
                                 */
                            }
                            self.recipes.append(newRecipe)
                            
                            counter = counter + 1
                        }
                        DispatchQueue.main.async {
                            self.recipeTable.reloadData()
                        }
                    } catch {
                        print("JSON Processing Failed")
                    }
                }
            }
        }
        
        task.resume()
        self.tableView.reloadData()
    }
    
    func postToServerFunction(index: Int){
        let url: NSURL = NSURL(string: "https://mmclaughlin557.com/bbqapp.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        let bodyData = ("recipedata=" + "&id=" + userId + "&recipeurl=" + recipes[index].url)
        print(bodyData)
        request.httpMethod = "POST"
        //save(userid: users[0].userid)
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main)
        {
            (response, data, error) in
            print(response)
        }
        if let HTTPResponse = responds as? HTTPURLResponse {
            let statusCode = HTTPResponse.statusCode
            
            if statusCode == 200 {
                print("Status Code 200: connection OK")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipesegue" {
            let nextScene = segue.destination as? RecipeWebView
            if let selectedItem = tableView.indexPathForSelectedRow?.row {
                nextScene?.website = (recipes[selectedItem].url)
            }
        }
    }
    
}


