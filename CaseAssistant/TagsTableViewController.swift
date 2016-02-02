//
//  TagsTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/18.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class TagsTableViewController: UITableViewController {

    var tags = [Tag]()
    
    func loadData() {
        tags.removeAll()
//        Tag.clearTagsWithZeroPatientsTagged() // 删除没有患者的tag
        tags = Tag.allTagsSortedByNumberOfPatientsDescending
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadData()
        title = "所有标签"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = ""+tags[indexPath.row].name
        cell.detailTextLabel?.text = ""+"\(tags[indexPath.row].numberOfPatientsTagged)"

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if tags.count > 0 {
            return "左滑可以删除标签"
        } else {
            return ""
        }
    }

    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let t = tags[indexPath.row]
            if t.numberOfPatientsTagged > 0 {
                var alert = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .ActionSheet
                )
                alert.addAction(UIAlertAction(
                    title: "删除标签，并在所有病例中移除该标签",
                    style: .Destructive,
                    handler: { (action) -> Void in
                        t.removeFromAllPatientsTagged()
                        t.removeFromDB()
                        self.loadData()
                        self.tableView.reloadData()
                    }
                    ))
                alert.addAction(UIAlertAction(
                    title: "取消",
                    style: .Cancel,
                    handler: nil
                    ))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                t.removeFromDB()
                loadData()
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier
        if identifier == "showPatientsWithTag" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                let destinationVC = segue.destinationViewController.topViewController as! PatientGroupViewController
                destinationVC.setToShowTag(tags[indexPath.row])
            }
        }
    }
    

}
