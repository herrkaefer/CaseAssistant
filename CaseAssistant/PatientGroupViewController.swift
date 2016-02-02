//
//  CategoryTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import iAd

class PatientGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate
{
    
    // MARK: - Variables

    enum ShowMode {
        case Tag
        case Starred
        case Category
    }
    
    private var mode: ShowMode = .Tag
    var tag: Tag?
    var category: Category?
    var patients = [Patient]()
    
    // MARK: - IBOutlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var adBannerView: ADBannerView?
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        
        if CaseNoteConstants.shouldRemoveADs {
            println("patient group: no ad")
            canDisplayBannerAds = false
            adBannerView?.removeFromSuperview()
            adBannerView?.delegate = nil
            adBannerView = nil
        } else {
            println("patient group: show ad")
            canDisplayBannerAds = true
            adBannerView?.delegate = self
            adBannerView?.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
        tableView.reloadData()
    }
    
    // MARK: - Helper Functions
    
    func setToShowTag(tag: Tag) {
        mode = .Tag
        self.tag = tag
    }
    
    func setToShowStarred() {
        mode = .Starred
    }
    
    func setToShowCategory(category: Category) {
        mode = .Category
        self.category = category
    }
    
    func loadData() {
        patients.removeAll()
        switch mode {
        case .Tag:
            patients.extend(tag!.patientsTaggedSortedByLastTreatmentDateDescending)
        case .Starred:
            patients.extend(Patient.starredPatientsSortedByLastTreatmentDateDescending)
        case .Category:
            patients.extend(category!.patientsSortedByLastTreatmentDateDescending)
        default:
            break
        }
//        println(mode)
//        println(patients)
    }
    
    func setTitle() {
        switch mode {
        case .Tag:
            title = "\(tag!.name)"
        case .Starred:
            title = "星标病例"
        case .Category:
            title = "\(category!.name)"
        }
    }
    
   // ADBannerView Delegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        println("bannerViewDidLoadAd")
        if CaseNoteConstants.shouldRemoveADs == false {
            adBannerView?.hidden = false
        } else {
            adBannerView?.hidden = true
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView?.hidden = true
    }
    
    // MARK: - TableView Data Source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath) as! PatientTableViewCell
        let patient = patients[indexPath.row]
        cell.nameLabel.text = patient.g("name")
        if patient.starred {
            cell.starImageView.image = UIImage(named: "star-22")
        } else {
            cell.starImageView.image = UIImage(named: "star-outline-22")            
        }

        var dateInfo = ""
        if patient.records.count > 0 {
            dateInfo += "首诊" + NSDateFormatter.localizedStringFromDate(patient.firstTreatmentDate, dateStyle: .ShortStyle, timeStyle: .NoStyle)
            dateInfo += "，末诊" + NSDateFormatter.localizedStringFromDate(patient.lastTreatmentDate, dateStyle: .ShortStyle, timeStyle: .NoStyle)
            dateInfo += ", 次数\(patient.records.count)"
        } else {
            dateInfo += "尚无就诊记录"
        }
        cell.dateInfoLabel.text = dateInfo
        
        cell.diagnosisLabel.text = "诊断：" + patient.g("diagnosis")
        cell.tagsLabel.text = " ".join(patient.tagNames)
        return cell
    }
    

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if patients.count > 0 {
            return "左滑可以删除患者"
        } else if CaseNoteConstants.shouldUnlockPatientLimitation == false {
                return "免费版最多可以添加\(CaseNoteConstants.IAPPatientLimitation)个患者，您还可以添加\(CaseNoteConstants.IAPPatientLimitation - Patient.totalNumberOfPatients)个"
        } else {
            return "点击右上角按钮可以添加患者"
        }
    }
    
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! PatientTableViewCell
        
        if editingStyle == .Delete {
            var alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .ActionSheet
            )
            alert.addAction(UIAlertAction(
                title: "删除该患者",
                style: .Destructive,
                handler: { (action) -> Void in
                    self.patients[indexPath.row].removeFromDB()
                    self.loadData()
                    self.tableView.reloadData()
                }
            ))
            alert.addAction(UIAlertAction(
                title: "取消",
                style: .Cancel,
                handler: nil
            ))
            
            alert.modalPresentationStyle = .Popover
            let ppc = alert.popoverPresentationController
            ppc?.sourceView = cell.subviews[0] as! UIView // subviews[0] is delete button
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // change the text that is showing in the delete button
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showPatient":
                let cell = sender as! UITableViewCell
                if let indexPath = tableView.indexPathForCell(cell) {
                    let patientVC = segue.destinationViewController.topViewController as! PatientViewController
                    patientVC.patient = patients[indexPath.row]
                }
            case "addPatient":
                if Patient.totalNumberOfPatients < CaseNoteConstants.IAPPatientLimitation ||
                    CaseNoteConstants.shouldUnlockPatientLimitation {
                    let patientInfoVC = segue.destinationViewController.topViewController as! PatientInfoTableViewController
                    patientInfoVC.setNewPatient(category, starred: mode == .Starred, tagName: tag?.name)
                } else {
                    var alert = UIAlertController(
                        title: "患者个数达到上限",
                        message: "免费版最多可以添加\(CaseNoteConstants.IAPPatientLimitation)名患者。您对我们的软件还满意吗？如果想无限制添加病例，请到主页左侧菜单中升级，谢谢！",
                        preferredStyle: .Alert
                    )

                    alert.addAction(UIAlertAction(
                        title: "完成",
                        style: .Default,
                        handler: nil
                        ))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            default: break
            }
        }
    }
    

}
