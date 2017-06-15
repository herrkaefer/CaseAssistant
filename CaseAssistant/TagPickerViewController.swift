//
//  TagPickerTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/6/5.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class TagPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{

    var patient: Patient? {
        didSet {
            loadData()
        }
    }
    
    var tags = [Tag]()
    var selectionStatus = [Bool]()
    var viewOriginalY: CGFloat?
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // bottom view
    @IBOutlet weak var addTagTextField: UITextField!
    @IBOutlet weak var cancelAddTagButton: UIButton! {
        didSet {
            cancelAddTagButton.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var cancelAddTabButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Helper functions
    
    func loadData() {
        tags.removeAll()
        selectionStatus.removeAll()
        tags = Tag.allTagsSortedByNumberOfPatientsDescending
        for t in tags {
            if patient!.hasTagByName(t.name) != nil {
                selectionStatus.append(true)
            } else {
                selectionStatus.append(false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelAddTabButtonWidthConstraint.constant = 0
        cancelAddTagButton.isHidden = true
        
        // register For Keyboard Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(TagPickerViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(TagPickerViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        viewOriginalY = nil // 当设备旋转，充值summaryTextViewOriginalFrame为nil，强迫在keyboardDidShow()中重新为summaryTextView计算新的frame
    }
    
    func keyboardDidShow(_ n: Notification) {
        if let userInfo = n.userInfo {
            let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size
            
            if viewOriginalY == nil { // first shown
                print("first shown")
                addTagTextField.placeholder = "输入标签，不要包含空格"
                showCancelAddTagButton()
                
                // change bottomView's y position
                viewOriginalY = bottomView.frame.origin.y
//                    if let rect = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
//                        print("keyboard y: \(rect.minY)")
//                    bottomView.frame.origin.y = rect.minY - 44
//                    }
                bottomView.frame.origin.y -= kbSize.height
                
            } else if (viewOriginalY! - bottomView.frame.origin.y) != kbSize.height { // keyboard height changed
                print("change")
                bottomView.frame.origin.y = viewOriginalY! - kbSize.height
            }
        }
    }
    
    
    func keyboardWillHide(_ n: Notification) {
        // set back summaryTextView's frame
        if viewOriginalY != nil {
            addTagTextField.placeholder = "添加标签"
            hideCancelAddTagButton()

            bottomView.frame.origin.y = viewOriginalY!
            viewOriginalY = nil
        }
    }
    
    
    func hideCancelAddTagButton() {
        cancelAddTabButtonWidthConstraint.constant = 0
        cancelAddTagButton.isHidden = true
    }
    
    func showCancelAddTagButton() {
        cancelAddTabButtonWidthConstraint.constant = 55
        cancelAddTagButton.isHidden = false
    }
    
    func commitEditing() {
        // update patient's tags
        for i in 0..<tags.count {
            if selectionStatus[i] == true {
                patient!.addTagByName(tags[i].name)
            } else {
                patient!.removeTagByName(tags[i].name)
            }
        }
    }
 
    // MARK: - IBActions
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        commitEditing()
        performSegue(withIdentifier: "backToPatientInfo", sender: self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToPatientInfo", sender: self)
    }
    

    @IBAction func cancelAddTagButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        addTagTextField.text = ""
        hideCancelAddTagButton()
    }
    
    // MARK: - TextField Delegate

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // add new tag
        let newTagName = addTagTextField.text
        if !(newTagName?.isEmpty)! {
            if Tag.tagExistsByName(newTagName!) {
                popupPrompt("标签已经存在", inView: self.view)
            } else {
                commitEditing() // 将之前的选择更新到patient
                patient!.addTagByName(newTagName!) // 无论标签存在与否，都添加到患者
                loadData()
                tableView.reloadData()
                cancelBarButtonItem.isEnabled = false // 新增标签后，disable "取消"，因意义模糊
            }
        }
        
        // update UI
        self.view.endEditing(true)
        addTagTextField.text = ""
        hideCancelAddTagButton()
        return true
    }
    
    
    // MARK: - Table view data source & delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) 

        cell.textLabel?.text = tags[indexPath.row].name
        if selectionStatus[indexPath.row] == true {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if selectionStatus[indexPath.row] == true {
            selectionStatus[indexPath.row] = false
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        } else {
            selectionStatus[indexPath.row] = true
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
    }
}
