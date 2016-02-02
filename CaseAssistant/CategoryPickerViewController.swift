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

    @IBAction func cancel(sender: UIBarButtonItem) {
        performSegueWithIdentifier("backToPatientInfo", sender: self)
    }
    
//    MARK: - UITableView DateSource & Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryPickerCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = categories[indexPath.row].name
        if selectedCategory != nil {
            if categories[indexPath.row].name == selectedCategory {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCategory = categories[indexPath.row].name
        performSegueWithIdentifier("backToPatientInfo", sender: self)
    }

}
