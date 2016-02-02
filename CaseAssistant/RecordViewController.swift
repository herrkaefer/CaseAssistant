//
//  RecordViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/9.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {

    var record: Record?
    var patient: Patient?
    var isNewRecord = false
    
    func setShowRecord(recordToShow: Record) {
        record = recordToShow
        patient = recordToShow.owner
        isNewRecord = false
    }

    func setNewRecord(ofPatient: Patient) {
        patient = ofPatient
        isNewRecord = true        
    }
    
    func addRightNavItemOnView()
    {
        let buttonAddPhotoMemo: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonAddPhotoMemo.frame = CGRectMake(0, 0, 40, 40)
        buttonAddPhotoMemo.setImage(UIImage(named:"camera-22"), forState: UIControlState.Normal)
        buttonAddPhotoMemo.addTarget(self, action: "buttonAddPhotoMemoClick:", forControlEvents: UIControlEvents.TouchUpInside)
        var rightBarButtonItemAddPhotoMemo: UIBarButtonItem = UIBarButtonItem(customView: buttonAddPhotoMemo)
        
        let buttonAddVoiceMemo: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        buttonAddVoiceMemo.frame = CGRectMake(0, 0, 40, 40)
        buttonAddVoiceMemo.setImage(UIImage(named:"mic-22"), forState: UIControlState.Normal)
        buttonAddVoiceMemo.addTarget(self, action: "buttonAddVoiceMemoClick:", forControlEvents: UIControlEvents.TouchUpInside)
        var rightBarButtonItemAddVoiceMemo: UIBarButtonItem = UIBarButtonItem(customView: buttonAddVoiceMemo)
        
        // add multiple right bar button items
        self.navigationItem.setRightBarButtonItems([rightBarButtonItemAddVoiceMemo, rightBarButtonItemAddPhotoMemo], animated: true)
        
        // uncomment to add single right bar button item
        // self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
    }
    
    
    func buttonAddPhotoMemoClick(sender:UIButton!)
    {
        println("rightNavItemEditClick")
    }
    
    func buttonAddVoiceMemoClick(sender:UIButton!)
    {
        println("rightNavItemDeleteClick")
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNewRecord {
            title = "新增记录"
        } else if record != nil {
            title = NSDateFormatter.localizedStringFromDate(record!.date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
        }
        // add multiple bar buttons on NavigationItem
        self.addRightNavItemOnView()
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let identifier = segue.identifier
        if identifier == "embedRecord" {
            let recordTVC = segue.destinationViewController as! RecordTableViewController
            if isNewRecord == true {
                recordTVC.setNewRecord(patient!)
            } else {
                recordTVC.setShowRecord(record!)
            }
        }
    }
    

}
