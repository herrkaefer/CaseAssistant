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
        let alert = UIAlertController(title: "新增类别", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "输入类别名称"
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "完成", style: .default, handler: {action in
            let tf = alert.textFields![0] 
            let _ = Category.addNewCategory((tf.text?.isEmpty)! ? "未命名类别" : tf.text!, isFirst: true)
            self.loadData()
            self.tableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - OBOutlets
    
    @IBOutlet weak var editingBarButtonItem: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        self.tableView.isEditing = !self.tableView.isEditing
        if self.tableView.isEditing == true {
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
    
    @IBAction func showSettingMenu(_ sender: UIBarButtonItem) {
        toggleSideMenu()
    }
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        title = "行医手记"
        tableView.reloadData()
        
        enableSideMenuGesture(true)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        enableSideMenuGesture(false)
    }

    // MARK: - TableView Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return self.tableView.isEditing ? (categories.count+1) : categories.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "starredCell", for: indexPath) 
                cell.textLabel?.text = "星标病例"
                cell.detailTextLabel?.text = ""+"\(Patient.starredPatients.count)"
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) 
                cell.textLabel?.text = "标签"
                cell.detailTextLabel?.text = ""+"\(Tag.numberOfTags)"
                return cell
            } else {
                break
            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) 
            
            if self.tableView.isEditing == true { // 编辑状态
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

    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && tableView.isEditing {
            return "无法删除非空类别"
        }
        else {
            return ""
        }
        
    }
    
    // MARK: - TableView Delegate
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 { // 星标、标签行不允许编辑
            return false
        }
        return true
    }
    
    // 使不可编辑的行不缩进
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.isEditing && indexPath.section == 1 {
            if indexPath.row == 0 {
                return .insert
            } else {
                if self.categories[indexPath.row-1].numberOfPatients > 0 {
                    return .none
                } else {
                    return .delete
                }
            }
        } else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.tableView.isEditing == true && indexPath.section == 1 {
            
            if indexPath.row == 0 { // 第一行用作添加新类别
                self.addNewCategory()
                
            } else { // 点击其他行->修改类别名
                let alert = UIAlertController(
                    title: "重命名类别",
                    message: "当前名称: "+self.categories[indexPath.row-1].name,
                    preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: { textField in
                    textField.placeholder = "输入新类别名称"
                })
                
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                
                alert.addAction(UIAlertAction(
                    title: "完成",
                    style: .default,
                    handler: {action in
                        let tf = alert.textFields![0] 
                        if !(tf.text?.isEmpty)! {
                            let _ = self.categories[indexPath.row-1].rename(tf.text!)
                        }
                        self.tableView.reloadData()
                    }
                ))
                
                self.present(alert, animated: true, completion: nil) 
            }
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            if indexPath.row == 0 {
                addNewCategory()
            }
        }
        if editingStyle == .delete {
            categories[indexPath.row-1].removeFromDB()
            loadData()
            tableView.reloadData()
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        if fromIndexPath.section == 1 && toIndexPath.section == 1 && fromIndexPath.row != toIndexPath.row {
            let itemToMove = categories[fromIndexPath.row-1]
            let newOrder = categories[toIndexPath.row-1].order
            itemToMove.updateOrder(newOrder)
            loadData()
            tableView.reloadData()
        }
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if (self.tableView.isEditing == true && indexPath.section == 1 && indexPath.row > 0) {
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - Navigation

    // 编辑状态下禁止segue
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        return !(self.tableView.isEditing == true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showStarredPatients":
                let categoryVC = segue.destination as! PatientGroupTableViewController
                categoryVC.setToShowStarred()
    
            case "showPatientsInCategory":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPath(for: cell) {
                    let categoryVC = segue.destination as! PatientGroupTableViewController
                    categoryVC.setToShowCategory(categories[indexPath.row])
                }

            default: break
            }
            self.title = "首页" // 设置title让后面的navigation bar的back button显示
        }
    }
}
