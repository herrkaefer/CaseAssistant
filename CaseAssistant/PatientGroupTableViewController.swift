//
//  CategoryTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import iAd

class PatientGroupTableViewController: UITableViewController
{
    // MARK: - Variables

    enum ShowMode {
        case tag
        case starred
        case category
    }
    
    fileprivate var mode: ShowMode = .tag
    var tag: Tag?
    var category: Category?
    var patients = [Patient]()
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 108
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        tableView.reloadData()
    }
    
    
    // MARK: - Helper Functions
    
    func setToShowTag(_ tag: Tag) {
        mode = .tag
        self.tag = tag
    }
    
    
    func setToShowStarred() {
        mode = .starred
    }
    
    
    func setToShowCategory(_ category: Category) {
        mode = .category
        self.category = category
    }
    
    
    func loadData() {
        patients.removeAll()
        switch mode {
        case .tag:
            patients.append(contentsOf: tag!.patientsTaggedSortedByLastTreatmentDateDescending)
        case .starred:
            patients.append(contentsOf: Patient.starredPatientsSortedByLastTreatmentDateDescending)
        case .category:
            patients.append(contentsOf: category!.patientsSortedByLastTreatmentDateDescending)
        }
    }
    
    
    func setTitle() {
        switch mode {
        case .tag:
            title = "\(tag!.name)"
        case .starred:
            title = "星标病例"
        case .category:
            title = "\(category!.name)"
        }
    }
    
    
    // MARK: - TableView Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! PatientTableViewCell
        let patient = patients[indexPath.row]
        cell.nameLabel.text = patient.g("name")
        if patient.starred {
            cell.starImageView.image = UIImage(named: "star-22")
        } else {
            cell.starImageView.image = UIImage(named: "star-outline-22")            
        }

        var dateInfo = ""
        if patient.records.count > 0 {
            dateInfo += "首诊" + DateFormatter.localizedString(from: patient.firstTreatmentDate as Date, dateStyle: .short, timeStyle: .none)
            dateInfo += "，末诊" + DateFormatter.localizedString(from: patient.lastTreatmentDate as Date, dateStyle: .short, timeStyle: .none)
            dateInfo += ", 次数\(patient.records.count)"
        } else {
            dateInfo += "尚无就诊记录"
        }
        cell.dateInfoLabel.text = dateInfo
        
        cell.diagnosisLabel.text = "诊断：" + patient.g("diagnosis")
        cell.tagsLabel.text = patient.tagNames.joined(separator: " ")
        return cell
    }
    

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if patients.count > 0 {
            return "左滑可以删除患者"
        }
        else {
            return "点击右上角按钮来添加患者吧"
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
        let cell = tableView.cellForRow(at: indexPath) as! PatientTableViewCell
        
        if editingStyle == .delete {
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(
                title: "删除该患者",
                style: .destructive,
                handler: { (action) -> Void in
                    self.patients[indexPath.row].removeFromDB()
                    self.loadData()
                    self.tableView.reloadData()
                }
            ))
            alert.addAction(UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil
            ))
            
            alert.modalPresentationStyle = .popover
            let ppc = alert.popoverPresentationController
            ppc?.sourceView = cell.subviews[0] // subviews[0] is delete button
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    // change the text that is showing in the delete button
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    
    // MARK: - Navigation

    // Unwind segue
    @IBAction func goBackToPatientGroup(segue:UIStoryboardSegue) {
        print("unwind segue: back to patient group")
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                
            case "showPatient":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPath(for: cell) {
                    let patientVC = segue.destination as! PatientViewController
                    patientVC.patient = patients[indexPath.row]
                }
                
            case "addPatient":
                // 病例未达免费版上限, 或者已经购买
//                if Patient.totalNumberOfPatients < CaseProducts.maxPatientsForFreeUser ||
//                   CaseProducts.store.isProductPurchased(CaseProducts.unlimitedPatients) {
                    let patientInfoVC = segue.destination as! PatientInfoTableViewController
                    patientInfoVC.setNewPatient(category, starred: (mode == .starred), tagName: tag?.name)
//                }
//                else {
//                    let alert = UIAlertController(
//                        title: "患者个数达到上限",
//                        message: "免费版最多可以添加\(CaseProducts.maxPatientsForFreeUser)名患者。您对我们的软件还满意吗？如果想无限制添加病例，请到主页左侧菜单中升级，谢谢！",
//                        preferredStyle: .alert
//                    )
//
//                    alert.addAction(UIAlertAction(
//                        title: "完成",
//                        style: .default,
//                        handler: nil
//                        ))
//                    
//                    self.present(alert, animated: true, completion: nil)
//                }
                
            default: break
            }
        }
    }
    

}
