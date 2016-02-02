//
//  BirthdatePickerViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/28.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController
{
    var selectedDate: NSDate?
    
    // ViewController from: unwind segue identifier
    let NavigationItems = [
        "EditPatientVC": "backToPatientInfo",
        "RecordTVCRecordDate": "backToRecordDate",
        "RecordTVCOperationDate": "backToOperationDate"
    ]
    
    var fromVC = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func pickDate(sender: UIDatePicker) {
        selectedDate = sender.date
        dateLabel.text = NSDateFormatter.localizedStringFromDate(selectedDate!, dateStyle: .LongStyle, timeStyle: .NoStyle)
    }
    
    @IBAction func doneDatePick(sender: UIBarButtonItem) {
        assert(contains(NavigationItems.keys, fromVC), "error: fromVC not valid")
        performSegueWithIdentifier(NavigationItems[fromVC], sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = .Date
        if selectedDate != nil {
            datePicker.setDate(selectedDate!, animated: true)
            dateLabel.text = NSDateFormatter.localizedStringFromDate(selectedDate!, dateStyle: .LongStyle, timeStyle: .NoStyle)
        }
    }
}
