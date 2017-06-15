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
            tagsLabel.isUserInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(PatientInfoTableViewController.selectTags(_:)))
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
    
    func selectTags(_ gesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showTagPicker", sender: self)
    }
    
    // set textview height
    func setTextViewHeightConstraints(_ textView: UITextView) {
        
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
            diagnosisTextViewHeightConstraint.constant = diagnosisTextView.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.greatestFiniteMagnitude)).height
        case illDescriptionTextView:
            illDescTextViewHeightConstraint.constant = illDescriptionTextView.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.greatestFiniteMagnitude)).height
        case commentTextView:
            commentTextViewHeightConstraint.constant = commentTextView.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.greatestFiniteMagnitude)).height
        default:
            break
        }
        
        tableView.reloadData()
    }
    
    func setNewPatient(_ forCategory: Category?, starred: Bool, tagName: String?) {
        patient = Patient.addNewPatient(forCategory, starred: starred)
//        print(patient)
        if tagName != nil {
            patient!.addTagByName(tagName!)
        }
        isNewPatient = true
    }
    
    func setShowPatient(_ p: Patient) {
        patient = p
        isNewPatient = false
    }
    
    func showUIBorder(_ enabled: Bool) {
        let borderWidth = CGFloat(enabled ? 0.5 : 0.0)
        nameTextField.borderStyle = enabled ? .roundedRect : .none
        categoryButton.layer.borderWidth = borderWidth
        genderButton.layer.borderWidth = borderWidth
        birthdateButton.layer.borderWidth = borderWidth
        phoneTextField.borderStyle = enabled ? .roundedRect : .none
        documentNumberTextField.borderStyle = enabled ? .roundedRect : .none
        diagnosisTextView.layer.borderWidth = borderWidth
        illDescriptionTextView.layer.borderWidth = borderWidth
        commentTextView.layer.borderWidth = borderWidth
    }

    func enableTextViewScroll(_ enabled: Bool) {
        diagnosisTextView.isScrollEnabled = enabled
        illDescriptionTextView.isScrollEnabled = enabled
        commentTextView.isScrollEnabled = enabled
    }
    
    func updateUIWithData() {
        
        // set UI contents
        nameTextField.text = patient!.g("name")
        categoryButton.setTitle(patient!.category.name, for: UIControlState())
        tagsLabel.text = patient!.tagNames.joined(separator: " ")
        genderButton.setTitle(patient!.g("gender"), for: UIControlState())
        birthdateButton.setTitle(DateFormatter.localizedString(from: patient!.birthdate as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
        phoneTextField.text = patient!.g("phoneNo")
        documentNumberTextField.text = patient!.g("documentNo")
        diagnosisTextView.text = patient!.g("diagnosis")
        illDescriptionTextView.text = patient!.g("illDescription")
        commentTextView.text = patient!.g("comment")
    }


    // MARK: - IBActions
    
    @IBAction func chooseGender(_ sender: UIButton) {
        
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "男",
            style: .default,
            handler: {action in
                self.patient!.s("gender", value: "男")
                self.genderButton.setTitle("男", for: UIControlState())
            }
        ))
        
        alert.addAction(UIAlertAction(
            title: "女",
            style: .default,
            handler: {action in
                self.patient!.s("gender", value: "女")
                self.genderButton.setTitle("女", for: UIControlState())
            }
        ))

        alert.addAction(UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil
        ))
        
        alert.modalPresentationStyle = .popover
        let ppc = alert.popoverPresentationController
        ppc?.sourceView = genderButton
        ppc?.sourceRect = genderButton.bounds
        ppc?.permittedArrowDirections = .any
        present(alert, animated: true, completion: nil)
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIWithData()
        
        showUIBorder(false)
        
        title = isNewPatient ? "添加患者" : "患者信息"
        
        if isNewPatient { // Hide "Back" and show "Done"
            self.navigationItem.hidesBackButton = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // end editing, dismiss keyboard
        self.view.endEditing(true)
        
//        if navigationController?.visibleViewController == self {
//            if patientIsUpdated == true {
//                patient!.saveToDB()
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()

        // 设置textView高度约束值，使适合内容.
        // 此时commentTextView.contentSize.width的值不准确，约为580，是适合Any width的一个universal的值。因此要用tableView.frame.size.width来设置textView的size
        setTextViewHeightConstraints(diagnosisTextView)
        setTextViewHeightConstraints(illDescriptionTextView)
        setTextViewHeightConstraints(commentTextView)
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case nameTextField:
            if (textField.text?.isEmpty)! {
                patient!.s("name", value: "未知")
            } else {
                patient!.s("name", value: textField.text!)
            }
        case phoneTextField:
            patient!.s("phoneNo", value: textField.text!)
        case documentNumberTextField:
            patient!.s("documentNo", value: textField.text!)
        default:
            break
        }
    }
    
    // MARK: - TextView Delegate
    
    // 注意在viewWillDisappear()中加view.endEditing(true)，保证正在编辑的textField和textView都有一个endEditing调用，在其中获得更新的数据
    func textViewDidEndEditing(_ textView: UITextView) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            
            case "showCategoryPicker":
                let categoryPickerVC = (segue.destination as! UINavigationController).topViewController as! CategoryPickerViewController
                categoryPickerVC.selectedCategory = patient!.category.name
            
            case "showDatePicker":
                let datePickerVC = (segue.destination as! UINavigationController).topViewController as! DatePickerViewController
                datePickerVC.fromVC = "EditPatientVC"
                datePickerVC.selectedDate = patient!.birthdate
                
            case "showTagPicker":
                let tagPickerVC = (segue.destination as! UINavigationController).topViewController as! TagPickerViewController
                tagPickerVC.patient = patient
            default:
                break
            }
        }
    }
    
    
    // Unwind Segue
    @IBAction func goBackToEditPatientViewController(_ segue: UIStoryboardSegue) {
        
        // from CategoryPickerViewController
        if let categoryPickerVC = segue.source as? CategoryPickerViewController, segue.identifier == "backToPatientInfo" {
            if categoryPickerVC.selectedCategory != nil {
                patient!.sCategoryByName(categoryPickerVC.selectedCategory!)
                categoryButton.setTitle(categoryPickerVC.selectedCategory, for: UIControlState())
            }
        }
            
        // from DatePickerViewController
        else if let datePickerVC = segue.source as? DatePickerViewController, segue.identifier == "backToPatientInfo" {
            if datePickerVC.selectedDate != nil {
                patient!.sBirthdate(datePickerVC.selectedDate!)
                birthdateButton.setTitle(DateFormatter.localizedString(from: patient!.birthdate as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
            }
        }
        
        // from TagPickerViewController
        else if let _ = segue.source as? TagPickerViewController, segue.identifier == "backToPatientInfo" {
                tagsLabel.text = patient!.tagNames.joined(separator: " ")
            }
        
        }
    
}
