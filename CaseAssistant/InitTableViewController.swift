//
//  InitTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import MMDrawerController
//import MMDrawerVisualState

class InitTableViewController: UITableViewController
{

    // MARK: - Variables
    
    var categories = [Category]()
    
    // MARK: - Helper functions
    
    func loadData() {
        categories = Category.allCategories
    }
    
    func addNewCategory() {
        var alert = UIAlertController(title: "新增类别", message: "", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = "输入类别名称"
        })
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "完成", style: .Default, handler: {action in
            let tf = alert.textFields![0] as! UITextField
            Category.addNewCategory(tf.text.isEmpty ? "未命名类别" : tf.text, isFirst: true)
            self.loadData()
            self.tableView.reloadData()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - OBOutlets
    
    @IBOutlet weak var editingBarButtonItem: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func toggleEditing(sender: UIBarButtonItem) {
        self.tableView.editing = !self.tableView.editing
        if self.tableView.editing == true {
            editingBarButtonItem.image = nil
            editingBarButtonItem.title = "完成"
            enableSideMenuGesture(false) // 禁用MMDrawerController手势，否则干扰cell移动
//            searchBar.hidden = true
        } else {
            editingBarButtonItem.title = "编辑"
            enableSideMenuGesture(true)
//            searchBar.hidden = false
        }
        loadData()
        tableView.reloadData()
    }
    
    @IBAction func showSettingMenu(sender: UIBarButtonItem) {
        toggleSideMenu()
    }
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    override func viewWillAppear(animated: Bool) {
        title = "行医手记"
        tableView.reloadData()
        
        enableSideMenuGesture(true)
    }

    
    override func viewWillDisappear(animated: Bool) {
        enableSideMenuGesture(false)
    }

    // MARK: - TableView Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return self.tableView.editing ? (categories.count+1) : categories.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("starredCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.text = "星标病例"
                cell.detailTextLabel?.text = ""+"\(Patient.starredPatients.count)"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.text = "标签"
                cell.detailTextLabel?.text = ""+"\(Tag.numberOfTags)"
                return cell
            } else {
                break
            }
            
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! UITableViewCell
            
            if self.tableView.editing == true { // 编辑状态
                if indexPath.row == 0 { // 第一行用于增加类别
                    cell.textLabel?.text = "点此添加新类别"
                    cell.detailTextLabel?.text = ""
                } else {
                    cell.textLabel?.text = categories[indexPath.row-1].name
                    cell.detailTextLabel?.text = "\(categories[indexPath.row-1].numberOfPatients)"
                }
            } else { // 正常状态
                cell.textLabel?.text = categories[indexPath.row].name
                cell.detailTextLabel?.text = "\(categories[indexPath.row].numberOfPatients)"
            }
            return cell
            
        default:
            break
        }
        return UITableViewCell()
    }

    
    // MARK: - TableView Delegate
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 { // 星标、标签行不允许编辑
            return false
        }
        return true
    }
    
    // 使不可编辑的行不缩进
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.editing && indexPath.section == 1 {
            if indexPath.row == 0 {
                return .Insert
            } else {
                if self.categories[indexPath.row-1].numberOfPatients > 0 {
                    return .None
                } else {
                    return .Delete
                }
            }
        } else {
            return .None
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if self.tableView.editing == true && indexPath.section == 1 {
            
            if indexPath.row == 0 { // 第一行用作添加新类别
                self.addNewCategory()
                
            } else { // 点击其他行->修改类别名
                var alert = UIAlertController(
                    title: "重命名类别",
                    message: "当前名称: "+self.categories[indexPath.row-1].name,
                    preferredStyle: .Alert)
                
                alert.addTextFieldWithConfigurationHandler({ textField in
                    textField.placeholder = "输入新类别名称"
                })
                
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                
                alert.addAction(UIAlertAction(
                    title: "完成",
                    style: .Default,
                    handler: {action in
                        let tf = alert.textFields![0] as! UITextField
                        if !tf.text.isEmpty {
                            self.categories[indexPath.row-1].rename(tf.text)
                        }
                        self.tableView.reloadData()
                    }
                ))
                
                self.presentViewController(alert, animated: true, completion: nil) 
            }
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Insert {
            if indexPath.row == 0 {
                addNewCategory()
            }
        }
        if editingStyle == .Delete {
            categories[indexPath.row-1].removeFromDB()
            loadData()
            tableView.reloadData()
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        if fromIndexPath.section == 1 && toIndexPath.section == 1 && fromIndexPath.row != toIndexPath.row {
            var itemToMove = categories[fromIndexPath.row-1]
            let newOrder = categories[toIndexPath.row-1].order
            itemToMove.updateOrder(newOrder)
            loadData()
            tableView.reloadData()
        }
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if (self.tableView.editing == true && indexPath.section == 1 && indexPath.row > 0) {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - Navigation

    // 编辑状态下禁止segue
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return !(self.tableView.editing == true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showStarredPatients":
                let categoryVC = segue.destinationViewController.topViewController as! PatientGroupViewController
                categoryVC.setToShowStarred()
    
            case "showPatientsInCategory":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    let categoryVC = segue.destinationViewController.topViewController as! PatientGroupViewController
                    categoryVC.setToShowCategory(categories[indexPath.row])
                }

            default: break
            }
            self.title = "首页" // 设置title让后面的navigation bar的back button显示
        }
    }
}
