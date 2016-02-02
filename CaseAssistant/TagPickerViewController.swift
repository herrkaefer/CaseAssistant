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
        cancelAddTagButton.hidden = true
        
        // register For Keyboard Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        viewOriginalY = nil // 当设备旋转，充值summaryTextViewOriginalFrame为nil，强迫在keyboardDidShow()中重新为summaryTextView计算新的frame
    }
    
    func keyboardDidShow(n: NSNotification) {
        if let userInfo = n.userInfo {
            if let kbSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                if viewOriginalY == nil { // first shown
                    println("first shown")
                    addTagTextField.placeholder = "输入标签，不要包含空格"
                    showCancelAddTagButton()
                    
                    // change bottomView's y position
                    viewOriginalY = bottomView.frame.origin.y
//                    if let rect = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue() {
//                        println("keyboard y: \(rect.minY)")
//                    bottomView.frame.origin.y = rect.minY - 44
//                    }
                    bottomView.frame.origin.y -= kbSize.height
                    
                } else if (viewOriginalY! - bottomView.frame.origin.y) != kbSize.height { // keyboard height changed
                    println("change")
                    bottomView.frame.origin.y = viewOriginalY! - kbSize.height
                }
                
            }
        }
    }
    
    func keyboardWillHide(n: NSNotification) {
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
        cancelAddTagButton.hidden = true
    }
    
    func showCancelAddTagButton() {
        cancelAddTabButtonWidthConstraint.constant = 55
        cancelAddTagButton.hidden = false
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
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        commitEditing()
        performSegueWithIdentifier("backToPatientInfo", sender: self)
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("backToPatientInfo", sender: self)
    }
    

    @IBAction func cancelAddTagButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        addTagTextField.text = ""
        hideCancelAddTagButton()
    }
    
    // MARK: - TextField Delegate

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // add new tag
        let newTagName = addTagTextField.text
        if !newTagName.isEmpty {
            if Tag.tagExistsByName(newTagName) {
                popupPrompt("标签已经存在", self.view)
            } else {
                commitEditing() // 将之前的选择更新到patient
                patient!.addTagByName(newTagName) // 无论标签存在与否，都添加到患者
                loadData()
                tableView.reloadData()
                cancelBarButtonItem.enabled = false // 新增标签后，disable "取消"，因意义模糊
            }
        }
        
        // update UI
        self.view.endEditing(true)
        addTagTextField.text = ""
        hideCancelAddTagButton()
        return true
    }
    
    // MARK: - Table view data source & delegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tagCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = tags[indexPath.row].name
        if selectionStatus[indexPath.row] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if selectionStatus[indexPath.row] == true {
            selectionStatus[indexPath.row] = false
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        } else {
            selectionStatus[indexPath.row] = true
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        }
    }
}
