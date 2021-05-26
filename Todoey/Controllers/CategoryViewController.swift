//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Lan Chu on 4/25/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        backButton.tintColor = .white
        navigationItem.backBarButtonItem = backButton
        loadData()
    }
    
    //MARK: - Add New Category Button Method
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Create an alert object with title = Add New Category, message = nil, style = alert
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        
        // Create a text field -> add it to the alert
        var addCatTextField = UITextField()
        alert.addTextField { (newTextField) in
            newTextField.placeholder = "Create new name"
            addCatTextField = newTextField
        }
        
        // Create an add button in the alert and an action for it -> add the action to the alert
        let addCatAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // The fuction that can be triggerd by the input "action" parameter
            let newCatName = addCatTextField.text ?? ""
            if newCatName != "" {
                // Create a new Category object and add it to the context
                let newCategory = Category(context: self.context)
                newCategory.name = newCatName
                // Add the new category to the categories array
                self.categories.append(newCategory)
                // Save the data
                self.saveData()
            }
        }
        alert.addAction(addCatAction)
        
        // Create an cancel button in the alert and an action for it -> add the action to the alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        // Present the new alert
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Data Manipulating Methods
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Saving data error: \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Fetching data error: \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: - Table View Data Source Methods

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let currentCate = categories[indexPath.row]
        cell.textLabel?.text = currentCate.name
        return cell
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            saveData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

//MARK: - Table View Delegate Methods

extension CategoryViewController: UITableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? TodoListViewController {
            if let index = tableView.indexPathForSelectedRow?.row {
                destVC.selectedCategory = categories[index]
            }
        } else {
            print("Downcating to TodoListViewController fail")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)

    }
    
    
}
