//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    var items = [Item]()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        searchBar.backgroundImage = UIImage()
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(docPath)
    }
    
    //MARK: - Tableview Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let currentItem = items[indexPath.row]
//        cell.textLabel?.text = currentItem.title
//        cell.accessoryType = currentItem.done ? .checkmark : .none
//        let attributedText = NSMutableAttributedString(string: currentItem.title!)
//        if currentItem.done {
//            attributedText.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedText.length))
//            cell.accessoryType = .checkmark
//            cell.isHighlighted = true
//        } else {
//            cell.accessoryType = .none
//        }
//        cell.textLabel?.attributedText = attributedText
//        cell.textLabel?.text = attributedText.string
        
        let attributedText = NSMutableAttributedString(string: currentItem.title!)
        if currentItem.done {
            attributedText.addAttribute(.strikethroughStyle, value: 0.5, range: NSMakeRange(0, attributedText.length))
            cell.checkmarkButton.tintColor = .green
        } else {
            cell.checkmarkButton.tintColor = .black
        }
        cell.label.attributedText = attributedText
        
        return cell
    }
    
    // Swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(items[indexPath.row])
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveData()
        }
    }
    
    //MARK: - Tableview Delegate methods
    
    func update(for cell: UITableViewCell, with item: Item) {
        let attributedText = NSMutableAttributedString(string: item.title!)
        if item.done {
            cell.accessoryType = .checkmark
            attributedText.addAttribute(.strikethroughStyle, value: 1, range: NSMakeRange(0, attributedText.length))
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.attributedText = attributedText
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentItem = items[indexPath.row]
//        currentItem.done = !currentItem.done
//        saveData()
//        tableView.deselectRow(at: indexPath, animated: true)
        
//        let currentCell = tableView.cellForRow(at: indexPath)!
        if currentItem.done {
            currentItem.done = false
//            update(for: currentCell, with: currentItem)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            items.insert(currentItem, at: 0)
            items.remove(at: indexPath.row+1)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
//            tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
            
            for item in items {
                print("\(item.title!) - \(item.done)")
                
            }
            print("-----------------------------")

        } else {
            currentItem.done = true
//            update(for: currentCell, with: currentItem)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            items.append(currentItem)
            items.remove(at: indexPath.row)
            tableView.moveRow(at: indexPath, to: IndexPath(row: self.items.count-1, section: 0))
//            tableView.deselectRow(at: IndexPath(row: self.items.count-1, section: 0), animated: true)
            
            
            for item in items {
                print("\(item.title!) - \(item.done)")
            }
            print("-----------------------------")

        }

    }
    
    
    
    //MARK: - The "Add new item" button method
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("haha")
        // Create an alert with title: "Add New Todoey Item"
        let alert = UIAlertController(title: "Add New Todoey Item", message: nil, preferredStyle: .alert)
        
        // Create a text field and add it to the alert
        var alertTextField = UITextField()
        alert.addTextField { (newTextField) in
            // New text field is created and has placeholder = "Create new item"
            newTextField.placeholder = "Create new item"
            // Assign this new text field to the "alertTextField" variable
            alertTextField = newTextField
        }
        
        // Create an action - a button has title: "Add Item", with action function
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Action fuction - When the user press the add item button
            if let newItemName = alertTextField.text {
                if newItemName != "" {
                    // Create a new item object in the current context
                    let newItem = Item(context: self.context)
                    newItem.title = newItemName
                    newItem.done = false
                    newItem.parentCategory = self.selectedCategory
                    // Add it to the items array and save the context
                    self.items.append(newItem)
                    self.saveData()
                }
            }
        }
        alert.addAction(addAction)
        
        // Create an action - a button has title: "Cancel"
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Perform it
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Saving errors: \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        let basePredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let customPredicate = request.predicate {
            let compoudPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, customPredicate])
            request.predicate = compoudPredicate
        } else {
            request.predicate = basePredicate
        }
        
        do {
            self.items = try context.fetch(request)
        } catch {
            print("Loading errors: \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func searchData(contain stringText: String) {
        // Split the string to tokens
        let tokens = stringText.components(separatedBy: " ")
        
        // Create a compound predicate and for each token create a subpredicate and add it to the compound prediate
        var predicates = [NSPredicate]()
        for token in tokens {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@", token))
        }
        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: predicates)
        
        // Create a new request with the compound predicate and the sortDescriptor
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        // The predicate is like WHERE clause in SQL - "WHERE title CONTAINS token1 OR ... title CONTAINS tokenN"
        request.predicate = compoundPredicate
        // The sortDescriptor is like ORDER BY in SQL - "ORDER BY title ASC"
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadData(with: request)
    }
}

//MARK: - SearchBarDelegate Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
            searchData(contain: searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadData()
            // Deselect the keyboard & the UIsearchBar
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchData(contain: searchText)
        }
    }
}

