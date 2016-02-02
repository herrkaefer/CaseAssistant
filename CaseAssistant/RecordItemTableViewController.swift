//
//  RecordItemTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/7.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class RecordItemTableViewController: UITableViewController, UITableViewDelegate, UITextViewDelegate
{

    // MARK: - Variables
    
    var senderTag: Int?
    var basicChoices: [String]?
    var hasCustomText = false
    var isNumeric = false
    var unit = ""
    
    var operationState = "cancel"
    var resultText: String?
    var selectedRow: Int?
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if basicChoices != nil && resultText != nil {
            if let ind = find(basicChoices!, resultText!) {
                selectedRow = ind
            }
        }
        tableView.estimatedRowHeight = tableView.rowHeight
//        tableView.rowHeight = UITableViewAutomaticDimension
    }

 
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        operationState = "cancel"
        performSegueWithIdentifier("backToRecord", sender: self)
    }

    @IBAction func done(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        operationState = "done"
        performSegueWithIdentifier("backToRecord", sender: self)
    }
    
    // button press
    @IBAction func chooseIt(sender: UIButton) {
//        println("choose: \(sender.titleLabel?.text)")
        let choice = sender.titleLabel?.text
        if let currentSelectedRow = find(basicChoices!, choice!) {
            if selectedRow != nil {
                let lastCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow!, inSection: 0)) as! RecordButtonInputTableViewCell
                lastCell.accessoryType = UITableViewCellAccessoryType.None
            }
            selectedRow = currentSelectedRow
            resultText = choice
            let currentCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow!, inSection: 0)) as! RecordButtonInputTableViewCell
            currentCell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }

    // MARK: - TextView Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        if selectedRow != nil {
            let lastCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRow!, inSection: 0)) as! RecordButtonInputTableViewCell
            lastCell.accessoryType = UITableViewCellAccessoryType.None
        }
    
        selectedRow = nil
        resultText = textView.text
        
        if isNumeric == true {
            textView.keyboardType = UIKeyboardType.NumbersAndPunctuation
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        resultText = textView.text
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var result = true
        
        if isNumeric == true {
            let prospectiveText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
            
            if count(text) > 0 {
                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789.-+").invertedSet
                let replacementStringIsLegal = text.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
                
                let resultingStringLengthIsLegal = count(prospectiveText) <= 6
                
                let scanner = NSScanner(string: prospectiveText)
                let resultingTextIsNumeric = scanner.scanDecimal(nil) && scanner.atEnd
                
                result = replacementStringIsLegal &&
                    resultingStringLengthIsLegal &&
                resultingTextIsNumeric
            }
        }
        return result
    }
    
    
    // MARK: - TableView Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if hasCustomText == true {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return basicChoices!.count
        case 1:
            return 1
        default: break
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
//            println("buttonInputCell: \(basicChoices)")
            let cell = tableView.dequeueReusableCellWithIdentifier("buttonInputCell", forIndexPath: indexPath) as! RecordButtonInputTableViewCell
            cell.choiceText = basicChoices![indexPath.row]
            if indexPath.row == selectedRow {
//                cell.checkboxImageView.image = UIImage(named: "checkbox-22")
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
//                cell.checkboxImageView.image = UIImage(named: "checkbox-blank-22")
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            return cell
            
        case 1:
//            println("textInputCell")
            let cell = tableView.dequeueReusableCellWithIdentifier("textInputCell", forIndexPath: indexPath) as! RecordTextInputTableViewCell

            if selectedRow == nil && resultText != nil {
                cell.customText = resultText
            } else {
                cell.customText = ""
            }
            
            if isNumeric == true {
                cell.customTextView.keyboardType = UIKeyboardType.NumbersAndPunctuation
            }
            
            if basicChoices?.isEmpty == true {
                cell.evokeKeyboard()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 94//min(94, UITableViewAutomaticDimension)
        } else {
            return UITableViewAutomaticDimension
        }
    }
//
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 44
//    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            var t = "自填"
            if isNumeric == true {
                t += "数值"
                if !unit.isEmpty {
                    t += "，单位" + unit
                }
            } else {
                t += "内容"
            }
            return t
        } else {
            return ""
        }
    }

}
