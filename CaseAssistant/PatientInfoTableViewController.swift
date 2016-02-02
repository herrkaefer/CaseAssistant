//
//  PatientInfoTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/27.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class PatientInfoTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate
{
    // MARK: - Variables
    
    var patient: Patient?
    var isNewPatient = false
    let textViewDefaultHeight: CGFloat = 88
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var tagsLabel: UILabel! {
        didSet {
            tagsLabel.userInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: "selectTags:")
            recognizer.numberOfTapsRequired = 1
            tagsLabel.addGestureRecognizer(recognizer)
        }
    }
    
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var birthdateButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField! {
        didSet {
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet weak var documentNumberTextField: UITextField! {
        didSet {
            documentNumberTextField.delegate = self
        }
    }
    
    @IBOutlet weak var diagnosisTextView: UITextView! {
        didSet {
            // add a accessory view to keyboard (没采用)
            // 后来采用的方案是：设置tableview的keyboardDismissMode为dismisssOnDrag，这样拖动的时候自动释放键盘。
            // 而且，键盘上面加一个toolbar很占空间
//            let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 36))
//            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//            let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewKeyboardAccessoryDoneButtonPressed")
//            keyboardToolbar.setItems([flexibleSpace, doneButton], animated: true)
//            diagnosisTextView.inputAccessoryView = keyboardToolbar
            
            diagnosisTextView.delegate = self
        }
    }
    
    @IBOutlet weak var illDescriptionTextView: UITextView! {
        didSet {
//            let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 36))
//            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//            let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewKeyboardAccessoryDoneButtonPressed")
//            keyboardToolbar.setItems([flexibleSpace, doneButton], animated: true)
//            illDescriptionTextView.inputAccessoryView = keyboardToolbar
            
            illDescriptionTextView.delegate = self
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView! {
        didSet {
//            let keyboardToolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 36))
//            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//            let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewKeyboardAccessoryDoneButtonPressed")
//            keyboardToolbar.setItems([flexibleSpace, doneButton], animated: true)
//            commentTextView.inputAccessoryView = keyboardToolbar
            
            commentTextView.delegate = self
        }
    }
    
    // 在Storyboard中为每个textView设置一个高度约束，在程序中调整约束的constant值，可以让AutoLayout调整对应textView的高度
    @IBOutlet weak var diagnosisTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var illDescTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Helper functions
    
//    func textViewKeyboardAccessoryDoneButtonPressed() {
//        self.view.endEditing(true)
//    }
    
    func selectTags(gesture: UITapGestureRecognizer) {
        performSegueWithIdentifier("showTagPicker", sender: self)
    }
    
    // set textview height
    func setTextViewHeightConstraints(textView: UITextView) {
        
        let textViewWidth = tableView.frame.size.width - 16
//        println("textViewWidth: \(textViewWidth)")
//        var size = diagnosisTextView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max))
//        println("size width: \(size.width)")
//        size = illDescriptionTextView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max))
//        println("size width: \(size.width)")
//        size = commentTextView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max))
//        println("size width: \(size.width)")
        
        switch textView {
            
        case diagnosisTextView:
            diagnosisTextViewHeightConstraint.constant = diagnosisTextView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max)).height
        case illDescriptionTextView:
            illDescTextViewHeightConstraint.constant = illDescriptionTextView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max)).height
        case commentTextView:
            commentTextViewHeightConstraint.constant = commentTextView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max)).height
        default:
            break
        }
        
        tableView.reloadData()
    }
    
    func setNewPatient(forCategory: Category?, starred: Bool, tagName: String?) {
        patient = Patient.addNewPatient(forCategory, starred: starred)
        if tagName != nil {
            patient!.addTagByName(tagName!)
        }
        isNewPatient = true
    }
    
    func setShowPatient(p: Patient) {
        patient = p
        isNewPatient = false
    }
    
    func showUIBorder(enabled: Bool) {
        let borderWidth = CGFloat(enabled ? 0.5 : 0.0)
        nameTextField.borderStyle = enabled ? .RoundedRect : .None
        categoryButton.layer.borderWidth = borderWidth
        genderButton.layer.borderWidth = borderWidth
        birthdateButton.layer.borderWidth = borderWidth
        phoneTextField.borderStyle = enabled ? .RoundedRect : .None
        documentNumberTextField.borderStyle = enabled ? .RoundedRect : .None
        diagnosisTextView.layer.borderWidth = borderWidth
        illDescriptionTextView.layer.borderWidth = borderWidth
        commentTextView.layer.borderWidth = borderWidth
    }

    func enableTextViewScroll(enabled: Bool) {
        diagnosisTextView.scrollEnabled = enabled
        illDescriptionTextView.scrollEnabled = enabled
        commentTextView.scrollEnabled = enabled
    }
    
    func updateUIWithData() {
        
        // set UI contents
        nameTextField.text = patient!.g("name")
        categoryButton.setTitle(patient!.category.name, forState: .Normal)
        tagsLabel.text = " ".join(patient!.tagNames)
        genderButton.setTitle(patient!.g("gender"), forState: .Normal)
        birthdateButton.setTitle(NSDateFormatter.localizedStringFromDate(patient!.birthdate, dateStyle: .LongStyle, timeStyle: .NoStyle), forState: .Normal)
        phoneTextField.text = patient!.g("phoneNo")
        documentNumberTextField.text = patient!.g("documentNo")
        diagnosisTextView.text = patient!.g("diagnosis")
        illDescriptionTextView.text = patient!.g("illDescription")
        commentTextView.text = patient!.g("comment")
    }


    // MARK: - IBActions
    
    @IBAction func chooseGender(sender: UIButton) {
        
        var alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "男",
            style: .Default,
            handler: {action in
                self.patient!.s("gender", value: "男")
                self.genderButton.setTitle("男", forState: .Normal)
            }
        ))
        
        alert.addAction(UIAlertAction(
            title: "女",
            style: .Default,
            handler: {action in
                self.patient!.s("gender", value: "女")
                self.genderButton.setTitle("女", forState: .Normal)
            }
        ))

        alert.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel,
            handler: nil
        ))
        
        alert.modalPresentationStyle = .Popover
        let ppc = alert.popoverPresentationController
        ppc?.sourceView = genderButton
        ppc?.sourceRect = genderButton.bounds
        ppc?.permittedArrowDirections = .Any
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIWithData()
        
        showUIBorder(false)
        
        title = isNewPatient ? "添加患者" : "患者信息"
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        // end editing, dismiss keyboard
        view.endEditing(true)
//        if navigationController?.visibleViewController == self {
//            if patientIsUpdated == true {
//                patient!.saveToDB()
//            }
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()

        // 设置textView高度约束值，使适合内容.
        // 此时commentTextView.contentSize.width的值不准确，约为580，是适合Any width的一个universal的值。因此要用tableView.frame.size.width来设置textView的size
        setTextViewHeightConstraints(diagnosisTextView)
        setTextViewHeightConstraints(illDescriptionTextView)
        setTextViewHeightConstraints(commentTextView)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
         // diagnosis cell
        if indexPath.row == 7 {
            return max(diagnosisTextViewHeightConstraint.constant, 44) + 53 // 上面有一个高度为20的label，再加上间距8*3 和 margin 1
        }
        // illDescription cell
        else if indexPath.row == 8 {
            return max(illDescTextViewHeightConstraint.constant, 44) + 53
        }

        // comment cell
        else if indexPath.row == 9 {
            return max(commentTextViewHeightConstraint.constant, 44) + 53
        }
        
        else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    
    // MARK: - TextField Delegate
    
    // Responder Chain 设置textField的键盘的完成键行为：dismiss keyboard 或转移firstResponder到其它control
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameTextField {
            nameTextField.resignFirstResponder()
        }
        else if textField == phoneTextField {
            documentNumberTextField.becomeFirstResponder()
        }
        else if textField == documentNumberTextField {
            diagnosisTextView.becomeFirstResponder()
        }
        return true
    }
    
    // 注意在viewWillDisappear()中加view.endEditing(true)，保证正在编辑的textField和textView都有一个endEditing调用，在其中获得更新的数据
    func textFieldDidEndEditing(textField: UITextField) {
        
        switch textField {
        case nameTextField:
            if textField.text.isEmpty {
                patient!.s("name", value: "未知")
            } else {
                patient!.s("name", value: textField.text)
            }
        case phoneTextField:
            patient!.s("phoneNo", value: textField.text)
        case documentNumberTextField:
            patient!.s("documentNo", value: textField.text)
        default:
            break
        }
    }
    
    // MARK: - TextView Delegate
    
    // 注意在viewWillDisappear()中加view.endEditing(true)，保证正在编辑的textField和textView都有一个endEditing调用，在其中获得更新的数据
    func textViewDidEndEditing(textView: UITextView) {
        switch textView {
        case diagnosisTextView:
            patient!.s("diagnosis", value: textView.text)
        case illDescriptionTextView:
            patient!.s("illDescription", value: textView.text)
        case commentTextView:
            patient!.s("comment", value: textView.text)
        default:
            break
        }

        // 重新设置textView的height constraint，使得textView的高度适合内容
        setTextViewHeightConstraints(textView)
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showCategoryPicker":
                let categoryPickerVC = segue.destinationViewController.topViewController as! CategoryPickerViewController
                categoryPickerVC.selectedCategory = patient!.category.name
            case "showDatePicker":
                let datePickerVC = segue.destinationViewController.topViewController as! DatePickerViewController
                datePickerVC.fromVC = "EditPatientVC"
                datePickerVC.selectedDate = patient!.birthdate
            case "showTagPicker":
                let tagPickerVC = segue.destinationViewController.topViewController as! TagPickerViewController
                tagPickerVC.patient = patient
            default:
                break
            }
        }
    }
    
    
    // Unwind Segue
    @IBAction func goBackToEditPatientViewController(segue: UIStoryboardSegue) {
        
        // from CategoryPickerViewController
        if let categoryPickerVC = segue.sourceViewController as? CategoryPickerViewController where segue.identifier == "backToPatientInfo" {
            if categoryPickerVC.selectedCategory != nil {
                patient!.sCategoryByName(categoryPickerVC.selectedCategory!)
                categoryButton.setTitle(categoryPickerVC.selectedCategory, forState: .Normal)
            }
        }
            
        // from DatePickerViewController
        else if let datePickerVC = segue.sourceViewController as? DatePickerViewController where segue.identifier == "backToPatientInfo" {
            if datePickerVC.selectedDate != nil {
                patient!.sBirthdate(datePickerVC.selectedDate!)
                birthdateButton.setTitle(NSDateFormatter.localizedStringFromDate(patient!.birthdate, dateStyle: .LongStyle, timeStyle: .NoStyle), forState: .Normal)
            }
        }
        
        // from TagPickerViewController
        else if let tagPickerVC = segue.sourceViewController as? TagPickerViewController where segue.identifier == "backToPatientInfo" {
                tagsLabel.text = " ".join(patient!.tagNames)
            }
        
        }
    
}
