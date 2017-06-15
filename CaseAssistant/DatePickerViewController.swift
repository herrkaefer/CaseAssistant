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
    var selectedDate: Date?
    
    // ViewController from: unwind segue identifier
    let NavigationItems = [
        "EditPatientVC": "backToPatientInfo",
        "RecordTVCRecordDate": "backToRecordDate",
        "RecordTVCOperationDate": "backToOperationDate"
    ]
    
    var fromVC = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func pickDate(_ sender: UIDatePicker) {
        selectedDate = sender.date
        dateLabel.text = DateFormatter.localizedString(from: selectedDate!, dateStyle: .long, timeStyle: .none)
    }
    
    @IBAction func doneDatePick(_ sender: UIBarButtonItem) {
        assert(NavigationItems.keys.contains(fromVC), "error: fromVC not valid")
        performSegue(withIdentifier: NavigationItems[fromVC]!, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.datePickerMode = .date
        if selectedDate != nil {
            datePicker.setDate(selectedDate!, animated: true)
            dateLabel.text = DateFormatter.localizedString(from: selectedDate!, dateStyle: .long, timeStyle: .none)
        }
    }
}
