//
//  RecordTextInputTableViewCell.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/7.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class RecordTextInputTableViewCell: UITableViewCell {

    var customText: String? {
        didSet {
            customTextView.text = customText
        }
    }
    
    func evokeKeyboard() {
        customTextView.becomeFirstResponder()
    }
    
//    func textViewKeyboardAccessoryDoneButtonPressed() {
//        customTextView.resignFirstResponder()
//    }

    @IBOutlet weak var customTextView: UITextView! {
        didSet {
            customTextView.layer.borderColor = CaseApp.borderColor.cgColor
            customTextView.layer.cornerRadius = 5.0
            customTextView.layer.borderWidth = 0.5
            
            // set accessory view to show with keyboard, with a "done" button (dismiss keyboard)
//            let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 36))
//            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//            let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewKeyboardAccessoryDoneButtonPressed")
//            keyboardToolbar.setItems([flexibleSpace, doneButton], animated: true)
//            customTextView.inputAccessoryView = keyboardToolbar

        }
    }

}
