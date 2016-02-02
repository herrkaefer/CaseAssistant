//
//  ReportViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/25.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UMSocialUIDelegate, UITextFieldDelegate
{

    var patient: Patient? {
        didSet {
            resetSelectionStatusOfSharedImages()
            setReportTitleWithFirstDiagnosis()
            loadData()
        }
    }
    
    struct ReportItem {
        var type: String // "text" | "image"
        var iconImage: UIImage?
        var header: String?
        var content: String?
        var image: UIImage?
    }
    
    var reportItems = [ReportItem]()
    var selectionStatusOfPhotoMemos = [[Bool]]()
    var numberOfSharedPhotoMemos: Int = 0

    var reportTitle = ""
    var affiliationOfAuthor = ""
    var authorName = ""
    
    var isSharing = false // 页面状态：editing or preview

    let recordTextIcon = UIImage(named: "paper-22")
    let patientInfoIcon = UIImage(named: "person-22")
    let summaryIcon = UIImage(named: "bulb-22")
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addImageButton: UIButton! {
        didSet {
            addImageButton.layer.cornerRadius = 5.0//addImageButton.layer.bounds.height/2
//            addImageButton.layer.shadowColor = UIColor.blackColor().CGColor
//            addImageButton.layer.shadowOffset = CGSizeMake(-5, 5)
//            addImageButton.layer.shadowRadius = 3
//            addImageButton.layer.shadowOpacity = 0.6
            addImageButton.setTitle("添加图片 (0)", forState: .Normal)
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        didSet {
//            shareButton.layer.borderColor = UIColor.grayColor().CGColor
//            shareButton.layer.borderWidth = 1.0
            
            shareButton.layer.cornerRadius = 5.0//shareButton.layer.bounds.height/2
//            shareButton.layer.shadowColor = UIColor.blackColor().CGColor
//            shareButton.layer.shadowOffset = CGSizeMake(-5, 5)
//            shareButton.layer.shadowRadius = 3
//            shareButton.layer.shadowOpacity = 0.6
        }
    }
    
 
    // MARK: - IBAction
    
    @IBAction func reportTitleTextFieldEditingChanged(sender: UITextField) {
        switch sender.tag {
        case 1001:
            reportTitle = sender.text
        case 1002:
            affiliationOfAuthor = sender.text
        case 1003:
            authorName = sender.text
        default:
            break
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // hide keyboard
        self.resignFirstResponder()
        return true
    }
    
    // MARK: - Helper Functions
    
    func resetSelectionStatusOfSharedImages() {
        if patient != nil {
            numberOfSharedPhotoMemos = 0
            selectionStatusOfPhotoMemos.removeAll()
            for r in patient!.recordsSortedAscending {
                selectionStatusOfPhotoMemos.append([Bool]())
                for _ in r.photoMemos {
                    selectionStatusOfPhotoMemos[selectionStatusOfPhotoMemos.count-1].append(false)
                }
            }
        }
    }
    
    func setReportTitleWithFirstDiagnosis() {
        reportTitle = ""
        if patient != nil {
//            println("fd: \(patient!.firstDiagnosis)")
            if let fd = patient!.firstDiagnosis {
                reportTitle = fd + "一例"
            }
        }
    }
    
    func loadData() {
        reportItems.removeAll()
        
        if patient != nil {
            // patient info
            let reportOfBasicInfo = patient!.reportOfBasicInfo
            reportItems.append(ReportItem(
                type: "text",
                iconImage: patientInfoIcon,
                header: "患者信息",
                content: reportOfBasicInfo.isEmpty ? "无。" : reportOfBasicInfo,
                image: nil
                ))
            
            // record text and shared images
            let records = patient!.recordsSortedAscending
            for i in 0..<patient!.recordsSortedAscending.count {
                let r = records[i]
                let pms = r.photoMemosSortedByCreationDateAscending
                
                // text
                let reportForShare = r.g("reportForShare")
                reportItems.append(ReportItem(
                    type: "text",
                    iconImage: recordTextIcon,
                    header: NSDateFormatter.localizedStringFromDate(r.date, dateStyle: .LongStyle, timeStyle: .NoStyle),
                    content: reportForShare.isEmpty ? r.report : reportForShare,
                    image: nil
                    ))
                
                // shared images
                for j in 0..<selectionStatusOfPhotoMemos[i].count {
                    if selectionStatusOfPhotoMemos[i][j] == true {
                        if let pmImage = pms[j].image {
                            // resize image to fit screen width
                            let resizedImage =  resizeImage(pmImage, CGSizeMake(tableView.frame.width*0.85, CGFloat.max), true)
                            
                            reportItems.append(ReportItem(
                                type: "image",
                                iconImage: nil,
                                header: nil,
                                content: nil,
                                image: resizedImage
                                ))
                        }
                    }
                }
            }
            
            // summary
            let summary = patient!.g("summary")
            reportItems.append(ReportItem(type: "text", iconImage: summaryIcon, header: "病例分析与讨论", content: summary.isEmpty ? "无。" : summary, image: nil))
            
        }
        println("reportitems: \(reportItems.count)")
    }
    
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = "病例分享"
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.setNeedsDisplay()
        tableView.reloadData()
    }
    
    
    @IBAction func saveImage(sender: UIBarButtonItem) {
        let image = getImageForSharing()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // 弹出保存成功提示
        popupPrompt("图片已保存到手机相册", self.view)
    }
    
    // MARK: - Sharing
    
    @IBAction func shareCase(sender: UIButton) {
        self.view.endEditing(true)
        
        UMSocialData.defaultData().extConfig.wxMessageType = UMSocialWXMessageTypeImage
        
        let imageForShare = getImageForSharing()

        UMSocialSnsService.presentSnsIconSheetView(
            self,
            appKey: nil,
            shareText: "病例分享@眼科行医手记",
            shareImage: imageForShare,
            shareToSnsNames: [UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina, UMShareToEmail],
            delegate: self)
    }
    
    
    func getImageForSharing() -> UIImage {

        /*********************************************/
        isSharing = true
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
        
        // scroll down the tableview from top to bottom
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        for i in 0..<reportItems.count {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: i, inSection: 2), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 3), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)

        /*********************************************/
        
        let oldFrame = tableView.frame
        tableView.frame = CGRectMake(0, 0, tableView.contentSize.width, tableView.contentSize.height)
        
//        println("tableView.frame.height: \(tableView.frame.height)")
//        println("tableView.bounds.height: \(tableView.bounds.height)")

        UIGraphicsBeginImageContextWithOptions(tableView.contentSize, true, UIScreen.mainScreen().scale)
        if tableView.respondsToSelector("drawViewHierarchyInRect") {
            tableView.drawViewHierarchyInRect(tableView.bounds, afterScreenUpdates: true)
        } else {
            tableView.layer.renderInContext(UIGraphicsGetCurrentContext())
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set back tableView's frame
        tableView.frame = oldFrame
        isSharing = false
        tableView.reloadData()
        return image
    }
    
    // MARK: - 友盟分享 Delegate

    func isDirectShareInIconActionSheet() -> Bool {
        return false
    }

    func didFinishGetUMSocialDataInViewController(response: UMSocialResponseEntity!) {
//        if response.responseCode == UMSResponseCodeSuccess {
            println("shared to: \(response.data.keys.first)")
//        }
    }
    
    
    // MARK: - TableView DataSource & Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSharing {
            return 4 // header + title + items + footer
        } else {
            return 2 // title + reportItems
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSharing {
            switch section {
            case 0: // header
                return 1
            case 1: // titleWhenShare
                return 1
            case 2:
                return reportItems.count
            case 3: // footer
                return 1
            default:
                return 0
            }
            
        } else {
            switch section {
            case 0: // title editing
                return 1
            case 1:
                return reportItems.count
            default:
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isSharing { // 生成分享图片时
            
            switch indexPath.section {
                
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
                
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("titleWhenShareCell", forIndexPath: indexPath) as! ReportTitleWhenShareTableViewCell
                cell.titleLabel.text = reportTitle
                cell.authorLabel.text = affiliationOfAuthor + " " + authorName
                return cell
 
            case 2:
                let item = reportItems[indexPath.row]
                
                if item.type == "text" {
                    let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportItemTableViewCell
                    cell.headerImage.image = item.iconImage
                    cell.header.text = item.header
                    cell.content.text = item.content
                    // 增加下面一行，否则第一次显示时label中内容不全，需要scroll之后才显示完整
                    cell.layoutIfNeeded()
                    return cell
                    
                } else if item.type == "image" {
                    let cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ReportImageItemTableViewCell
                    cell.photoMemoImageView.image = item.image
                    // 增加下面一行，否则第一次显示时label中内容不全，需要scroll之后才显示完整
                    cell.layoutIfNeeded()
                    return cell
                    
                } else {
                    return UITableViewCell()
                }

                
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("footerCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
                
            default:
                return UITableViewCell()
            }
            
        } else { // 编辑状态下
            
            switch indexPath.section {
                
            case 0: // titleCell
                let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! ReportTitleTableViewCell
                // set background and border
                cell.titleTextField.backgroundColor = UIColor.whiteColor()
                cell.titleTextField.borderStyle = .RoundedRect
                cell.titleTextField.placeholder = "标题（如：急性视网膜坏死综合征一例）"
                cell.titleTextField.text = reportTitle
                println("title: \(reportTitle)")
                
                cell.affiliationTextField.backgroundColor = UIColor.whiteColor()
                cell.affiliationTextField.borderStyle = .RoundedRect
                cell.affiliationTextField.placeholder = "单位名称"
                cell.affiliationTextField.text = affiliationOfAuthor
                
                cell.authorNameTextField.backgroundColor = UIColor.whiteColor()
                cell.authorNameTextField.borderStyle = .RoundedRect
                cell.authorNameTextField.placeholder = "署名"
                cell.authorNameTextField.text = authorName
                return cell
  
            case 1: // items: text or shared photos
                
                let item = reportItems[indexPath.row]
                
                if item.type == "text" {
                    let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportItemTableViewCell
                    cell.headerImage.image = item.iconImage
                    cell.header.text = item.header
                    cell.content.text = item.content
                    // 增加下面一行，否则第一次显示时label中内容不全，需要scroll之后才显示完整
                    cell.layoutIfNeeded()
                    return cell
                    
                } else if item.type == "image" {
                    let cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ReportImageItemTableViewCell
                    cell.photoMemoImageView.image = item.image
                    // 增加下面一行，否则第一次显示时label中内容不全，需要scroll之后才显示完整
                    cell.layoutIfNeeded()
                    return cell
                    
                } else {
                    return UITableViewCell()
                }
                
            default:
                return UITableViewCell()
            }
        }
    }

    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImageSelecter" {
            let imageSelecterVC = segue.destinationViewController.topViewController as! ImageSelecterCollectionViewController
            imageSelecterVC.patient = patient!
            imageSelecterVC.setInitialSelectionStatus(selectionStatusOfPhotoMemos)
        }
    }
    
    // Unwind Segue
    @IBAction func goBackToReportViewController(segue: UIStoryboardSegue) {
        // from imageSelecter
        if let imageSelecterVC = segue.sourceViewController as? ImageSelecterCollectionViewController where segue.identifier == "backToReport" {
            selectionStatusOfPhotoMemos = imageSelecterVC.selectionStatusOfImages
            numberOfSharedPhotoMemos = imageSelecterVC.numberOfSelectedImages
            println("back from selection: number: \(numberOfSharedPhotoMemos)")
            loadData()
            addImageButton.setTitle("添加图片 (\(numberOfSharedPhotoMemos))", forState: .Normal)
            tableView.reloadData()
        }
    }
}
