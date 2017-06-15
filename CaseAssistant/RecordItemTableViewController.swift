//
//  RecordItemTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/7.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class RecordItemTableViewController: UITableViewController, UITextViewDelegate
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
            if let ind = basicChoices!.index(where: { $0 == resultText! }) {
//            if let ind = find(basicChoices!, resultText!) {
                selectedRow = ind
            }
        }
        tableView.estimatedRowHeight = tableView.rowHeight
//        tableView.rowHeight = UITableViewAutomaticDimension
    }

 
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        operationState = "cancel"
        performSegue(withIdentifier: "backToRecord", sender: self)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        operationState = "done"
        performSegue(withIdentifier: "backToRecord", sender: self)
    }
    
    // button press
    @IBAction func chooseIt(_ sender: UIButton) {
//        println("choose: \(sender.titleLabel?.text)")
        let choice = sender.titleLabel?.text
        if let currentSelectedRow = basicChoices!.index(where: { $0 == choice! }) {
//        if let currentSelectedRow = find(basicChoices!, choice!) {
            if selectedRow != nil {
                let lastCell = tableView.cellForRow(at: IndexPath(row: selectedRow!, section: 0)) as! RecordButtonInputTableViewCell
                lastCell.accessoryType = UITableViewCellAccessoryType.none
            }
            selectedRow = currentSelectedRow
            resultText = choice
            let currentCell = tableView.cellForRow(at: IndexPath(row: selectedRow!, section: 0)) as! RecordButtonInputTableViewCell
            currentCell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
    }

    // MARK: - TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if selectedRow != nil {
            let lastCell = tableView.cellForRow(at: IndexPath(row: selectedRow!, section: 0)) as! RecordButtonInputTableViewCell
            lastCell.accessoryType = UITableViewCellAccessoryType.none
        }
    
        selectedRow = nil
        resultText = textView.text
        
        if isNumeric == true {
            textView.keyboardType = UIKeyboardType.numbersAndPunctuation
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        resultText = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var result = true
        
        if isNumeric == true {
            let prospectiveText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            
            if text.characters.count > 0 {
                let disallowedCharacterSet = CharacterSet(charactersIn: "0123456789.-+").inverted
                let replacementStringIsLegal = text.rangeOfCharacter(from: disallowedCharacterSet) == nil
                
                let resultingStringLengthIsLegal = (prospectiveText.characters.count <= 6)
                
                let scanner = Scanner(string: prospectiveText)
                let resultingTextIsNumeric = scanner.scanDecimal(nil) && scanner.isAtEnd
                
                result = replacementStringIsLegal &&
                    resultingStringLengthIsLegal &&
                resultingTextIsNumeric
            }
        }
        return result
    }
    
    
    // MARK: - TableView Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if hasCustomText == true {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return basicChoices!.count
        case 1:
            return 1
        default: break
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
//            println("buttonInputCell: \(basicChoices)")
            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonInputCell", for: indexPath) as! RecordButtonInputTableViewCell
            cell.choiceText = basicChoices![indexPath.row]
            if indexPath.row == selectedRow {
//                cell.checkboxImageView.image = UIImage(named: "checkbox-22")
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
//                cell.checkboxImageView.image = UIImage(named: "checkbox-blank-22")
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            return cell
            
        case 1:
//            println("textInputCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "textInputCell", for: indexPath) as! RecordTextInputTableViewCell

            if selectedRow == nil && resultText != nil {
                cell.customText = resultText
            } else {
                cell.customText = ""
            }
            
            if isNumeric == true {
                cell.customTextView.keyboardType = UIKeyboardType.numbersAndPunctuation
            }
            
            if basicChoices?.isEmpty == true {
                cell.evokeKeyboard()
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
