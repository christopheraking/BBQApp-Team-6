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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private func setupSegmentedControl(){
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Search", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Favorites", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    var recipes : [Recipe] = []
    
    @IBOutlet var recipeTable: UITableView!
    
    var yourSearch = "BBQ"
    var searchActive : Bool = false
    var selectedItem : Int = 0
    var userId : String = ""
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
    
    private func setupView(){
        setupSegmentedControl()
        updateView()
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        doSomethingWithItem(index: indexPath.row)
        
    }
    
    func doSomethingWithItem(index: Int ){
        postToServerFunction(index: index)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) -> Int  {
        selectedItem = indexPath.row
        //print(selectedItem)
        return selectedItem
    }
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            updateSearchResults(for: searchController)
            
        } else {
            //print("Favorite recipes clicked")
            recipes.removeAll()
            self.tableView.reloadData()
            fetchUsersFavorites()
        
        }
    }
    
    func fetchUsersFavorites(){
        
        let URL_GET_FAVORITES:String = "https://mmclaughlin557.com/getRecipes.php"
        //created NSURL
        let requestURL = NSURL(string: URL_GET_FAVORITES)
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        //setting the method to post
        request.httpMethod = "POST"
        let bodyData = "data=&userid=" + userId
        //print(bodyData)
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //creating a task to send the post request
        //NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main)
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            //exiting if there is some error
            if error != nil{
                print("error is \(error)")
                return;
            }
            //parsing the response
            do {
                //converting resonse to NSDictionary
                var RecipeJSON: NSDictionary!
                RecipeJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
             
                //getting the JSON array teams from the response
                let favoriteRecipes: NSArray = RecipeJSON["recipes"] as! NSArray
                //print(favoriteRecipes.description)
                print("Recipes returned ", favoriteRecipes.count)
                self.recipes.removeAll()
                var counter = 0
                while counter < favoriteRecipes.count{
                    var newRecipe : Recipe = Recipe()
                    
                    //looping through all the json objects in the array teams
                //for i in 0 ..< favoriteRecipes.count{
                    print(counter)
                
                    //getting the data at each index
                    if let RecipeUrl = ((RecipeJSON["recipes"] as? NSArray)?[counter] as? NSDictionary)?["RecipeURL"] as? String
                    {
                    newRecipe.url = RecipeUrl
                    //displaying the data
                    print("recipeURL -> ", RecipeUrl)
                    //print("userId -> ", self.userId)
                    //print("member -> ", teamMember)
                    print("===================")
                    print("")
                        
                    }
                    self.recipes.append(newRecipe)
                    counter = counter + 1
                }
                DispatchQueue.main.async {
                    self.recipeTable.reloadData()
                }
            } catch {
                print(error)
            }
        }
        //executing the task
        task.resume()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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


