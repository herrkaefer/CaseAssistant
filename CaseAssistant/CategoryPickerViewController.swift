//
//  categoryPickerViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/28.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController //, UITableViewDataSource, UITableViewDelegate
{
    var categories = [Category]()
    var selectedCategory: String?
    
    func loadData() {
        categories.removeAll()
        categories = Category.allCategories
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.title = "选择类别"
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToPatientInfo", sender: self)
    }
    
//    MARK: - UITableView DateSource & Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryPickerCell", for: indexPath) 
        cell.textLabel?.text = categories[indexPath.row].name
        if selectedCategory != nil {
            if categories[indexPath.row].name == selectedCategory {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row].name
        performSegue(withIdentifier: "backToPatientInfo", sender: self)
    }

}
