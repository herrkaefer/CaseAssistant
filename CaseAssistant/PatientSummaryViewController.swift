//
//  PatientSummaryViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/5.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class PatientSummaryViewController: UIViewController, UITextViewDelegate
{

    // MARK: - Variables
    
    var patient: Patient?
    var summaryChanged = false
    var summaryTextViewOriginalFrame: CGRect? // 当keyboard出现时，保存summaryTextView原来的frame；在keyboard撤消后用于恢复
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var summaryTextView: UITextView!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summaryTextView.layer.borderColor = CaseNoteConstants.borderColor.CGColor
        summaryTextView.layer.cornerRadius = 5.0
        summaryTextView.layer.borderWidth = 0.5
        
        summaryTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false // 如果不设置，则textview的内容上方有空白，不顶头
        
        if patient != nil {
            let summary = patient!.g("summary")
            if summary.isEmpty {
                // put some placeholder text
                summaryTextView.text = "在此处写下对于该病例的分析、思考或疑问。这些内容会在分享病例时一起被分享。"
                summaryTextView.textColor = UIColor.lightGrayColor()
            } else {
                summaryTextView.text = summary
                summaryTextView.textColor = UIColor.blackColor()
            }
        }
        
        // register For Keyboard Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: self.view.window)
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        if summaryChanged == true {
            patient!.s("summary", value: summaryTextView.text)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        summaryTextViewOriginalFrame = nil // 当设备旋转，充值summaryTextViewOriginalFrame为nil，强迫在keyboardDidShow()中重新为summaryTextView计算新的frame
    }
    
    func keyboardDidShow(n: NSNotification) {
        if let userInfo = n.userInfo {
            if let kbSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
                if summaryTextViewOriginalFrame == nil { // first shown
//                    println("first shown")
                    summaryTextViewOriginalFrame = summaryTextView.frame
                    var newFrame = summaryTextViewOriginalFrame!
                    newFrame.size.height -= kbSize.height
                    summaryTextView.frame = newFrame
                } else if (summaryTextViewOriginalFrame!.height - summaryTextView.frame.height) != kbSize.height { // keyboard height changed
//                    println("update frame")
                    var newFrame = summaryTextViewOriginalFrame!
                    newFrame.size.height -= kbSize.height
                    summaryTextView.frame = newFrame
                }
            }
        }
    }
    
    func keyboardWillHide(n: NSNotification) {
        // set back summaryTextView's frame
        if summaryTextViewOriginalFrame != nil {
            summaryTextView.frame = summaryTextViewOriginalFrame!
            summaryTextViewOriginalFrame = nil
        }
    }
    
    
    // MARK: - TextView Delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        let summary = patient!.g("summary")
        if summary.isEmpty {
            summaryTextView.text = "" // 清空placeholder text
            summaryTextView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        summaryChanged = true
    }
    
}
