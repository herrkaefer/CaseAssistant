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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) 
        cell.textLabel?.text = ""+tags[indexPath.row].name
        cell.detailTextLabel?.text = ""+"\(tags[indexPath.row].numberOfPatientsTagged)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if tags.count > 0 {
            return "左滑可以删除标签"
        } else {
            return ""
        }
    }

    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let t = tags[indexPath.row]
            if t.numberOfPatientsTagged > 0 {
                let alert = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .actionSheet
                )
                alert.addAction(UIAlertAction(
                    title: "删除标签，并在所有病例中移除该标签",
                    style: .destructive,
                    handler: { (action) -> Void in
                        t.removeFromAllPatientsTagged()
                        t.removeFromDB()
                        self.loadData()
                        self.tableView.reloadData()
                    }
                    ))
                alert.addAction(UIAlertAction(
                    title: "取消",
                    style: .cancel,
                    handler: nil
                    ))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                t.removeFromDB()
                loadData()
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        if identifier == "showPatientsWithTag" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                let destinationVC = segue.destination as! PatientGroupTableViewController
                destinationVC.setToShowTag(tags[indexPath.row])
            }
        }
    }
    

}
