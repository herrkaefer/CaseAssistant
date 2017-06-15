//
//  SettingViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/28.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import MessageUI


class SettingTableViewController: UITableViewController, MFMailComposeViewControllerDelegate
{

    let tableViewCellTitle = [
        "告诉我们你的想法",
        "去 App Store 鼓励我们",
//        "升级到 Pro 版本",
        "关于"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCellTitle.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) 
        cell.textLabel?.text = tableViewCellTitle[indexPath.row]
        return cell
    }
    
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            
        // Feedback
        case 0:
            if MFMailComposeViewController.canSendMail() {
                //注意这个实例要写在if block里，否则无法发送邮件时会出现两次提示弹窗（一次是系统的）
                let mailComposeViewController = configuredMailComposeViewController()
                getDrawer()!.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
//            getDrawer()!.present(UMFeedback.feedbackModalViewController(), animated: true, completion: nil)
            
        // Rate
        case 1:
            CaseApp.rate(completion: { (success) in
                print(success)
            })
            
        // IAP
//        case 2:
//            performSegue(withIdentifier: "showIAP", sender: self)

        // About
        case 2:
            performSegue(withIdentifier: "showAbout", sender: self)
            
        default:
            break
        }
    }
    
    
    // MARK: Mail delegate
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        // 获取系统版本号
        let systemVersion = UIDevice.current.systemVersion
        // 设备型号
        let modelName = UIDevice.current.modelName
        
        //设置邮件地址、主题及正文
        mailComposeVC.setToRecipients([CaseApp.email])
        mailComposeVC.setSubject("眼科行医手记App意见反馈")
        mailComposeVC.setMessageBody("\n\n------------------------\n设备型号：\(modelName)\n系统版本：\(systemVersion)", isHTML: false)
        
        return mailComposeVC
    }
    
    
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title: "无法发送邮件", message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "确定", style: .default) { _ in })
        getDrawer()!.present(sendMailErrorAlert, animated: true){}
        
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("取消发送")
        case MFMailComposeResult.sent.rawValue:
            print("发送成功")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    @IBAction func goBackToSettingViewController(_ segue: UIStoryboardSegue) {
        
    }

}
