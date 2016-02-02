//
//  PatientViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/23.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

import QBImagePickerController

class PatientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBImagePickerControllerDelegate
{

    // MARK: - Variables
    
    var patient: Patient? {
        didSet {
            loadData()
        }
    }
    
    var records = [Record]()
    
    var currentOperatedRecord: Record? // 当前正在操作(add photo, add voice memo, delete)的record

    var imagePickerController: UIImagePickerController?
//    var qbImagePickerController: QBImagePickerController?
    
    var progressHUD: ProgressHUD!

    // MARK: - IBOutlets
    
    @IBOutlet weak var patientInfoLabel: UILabel!
    @IBOutlet weak var patientDiagnosisLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var patientTableView: UITableView!
    @IBOutlet weak var infoView: UIView! {
        didSet {
            let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTapOnInfoView:")
            infoView.addGestureRecognizer(singleFingerTap)
        }
    }
    @IBOutlet weak var starBarButtonItem: UIBarButtonItem!
    
//    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Helper Functions
 
    func loadData() {
        records.removeAll()
        records.extend(patient!.recordsSortedDescending)
    }
    
    func updateInfoView() {
        let name = patient!.g("name")
        let gender = patient!.g("gender")
        patientInfoLabel.text! = "\(name), \(gender), \(patient!.treatmentAge)岁"
        if let fd = patient!.firstDiagnosis {
            patientDiagnosisLabel.text = "\(patient!.firstDiagnosis!)"
        } else {
            patientDiagnosisLabel.text = patient!.g("diagnosis")
        }
        
        let tagNames = patient!.tagNames
        if tagNames.count > 0 {
            tagsLabel.text! = " " + " ".join(tagNames) + " "
        } else {
            tagsLabel.text! = ""
        }
        tagsLabel.layer.cornerRadius = 3.0
        tagsLabel.layer.masksToBounds = true
    }
    
    func updateStarBarButtonItemDisplay() {
        if patient?.starred == true {
            starBarButtonItem.image = UIImage(named: "star-29")
            starBarButtonItem.tintColor = CaseNoteConstants.starredColor
        } else {
            starBarButtonItem.image = UIImage(named: "star-outline-29")
            starBarButtonItem.tintColor = UIColor.whiteColor()
        }
    }
    
    func addLastPhotoInLibraryToPhotoMemo() {
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        if let lastAsset = fetchResult.lastObject as? PHAsset {
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Fast
            PHImageManager.defaultManager().requestImageForAsset(lastAsset, targetSize: PhotoMemo.imageSize, contentMode: .AspectFit, options: options, resultHandler: { (image, info) -> Void in
                let result = self.currentOperatedRecord!.addPhotoMemo(image, creationDate: lastAsset.creationDate, shouldScaleDown: false)
                if result == true {
                    self.patientTableView.reloadData()
                    // 弹出保存成功提示
                    popupPrompt("照片已添加", self.view)
                } else {
                    popupPrompt("照片添加失败，请再试一次", self.view)
                }
            })
        }
    }
    
    func takeOrImportPhotoForRecord() {
        if currentOperatedRecord == nil {
            return
        }
        
        var alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet
        )
        alert.addAction(UIAlertAction(
            title: "相册中最新一张照片",
            style: .Default,
            handler: {action in
//                self.progressHUD.show()
                self.addLastPhotoInLibraryToPhotoMemo()
//                self.progressHUD.hide()
            }
            ))
        alert.addAction(UIAlertAction(
            title: "拍摄照片",
            style: .Default,
            handler: {action in
                if self.imagePickerController != nil {
                    self.presentViewController(self.imagePickerController!, animated: true, completion: nil)
                }
            }
            ))
        alert.addAction(UIAlertAction(
            title: "从相册中选择",
            style: .Default,
            handler: {action in
                let qbImagePickerController = QBImagePickerController()
                qbImagePickerController.mediaType = .Image
                qbImagePickerController.allowsMultipleSelection = true
                qbImagePickerController.prompt = "选择照片(可多选)"
                qbImagePickerController.showsNumberOfSelectedAssets = true
                qbImagePickerController.delegate = self
                self.presentViewController(qbImagePickerController, animated: true, completion: nil)
            }
            ))
        alert.addAction(UIAlertAction(
            title: "取消",
            style: .Cancel,
            handler: nil
            ))
        
        alert.modalPresentationStyle = .Popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = starBarButtonItem
        presentViewController(alert, animated: true, completion: nil)
    }

    
    // MARK: - IBActions
    
    func handleSingleTapOnInfoView(gesture: UITapGestureRecognizer) {
        performSegueWithIdentifier("showPatientInfo", sender: self)
    }
    
    
    @IBAction func showMorePatientInfo(sender: UIButton) {
        performSegueWithIdentifier("showPatientInfo", sender: self)
    }
    
    @IBAction func starPatient(sender: UIBarButtonItem) {
        patient!.toggleStar()
        updateStarBarButtonItemDisplay()
    }

    // MARK: - QBImagePickerViewController Delegate
    // 从相册多选时使用
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        
//        activityIndicatorView.startAnimating()
        progressHUD.show()
        
        var addCnt: Int = 0
        var gotCnt: Int = 0
        
        // save images
        for asset in (assets as! [PHAsset]) {
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Fast
            PHImageManager.defaultManager().requestImageForAsset(
                asset,
                targetSize: PhotoMemo.imageSize,
                contentMode: .AspectFit,
                options: options,
                resultHandler: { (image, info) -> Void in
                    gotCnt++
                    let result = self.currentOperatedRecord!.addPhotoMemo(image, creationDate: asset.creationDate, shouldScaleDown: false)
                    if result == true {
                        addCnt++
                    }
                    if gotCnt == assets.count {
                        self.patientTableView.reloadData()
//                        self.activityIndicatorView.stopAnimating()
                        self.progressHUD.hide()
                        popupPrompt("\(addCnt)张照片已添加", self.view)
                    }
            })
        }
        
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    // 使用相机拍摄照片时使用
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var result = false
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if image != nil {
            result = currentOperatedRecord!.addPhotoMemo(image!, creationDate: NSDate(), shouldScaleDown: true)
            if result == true {
                // also save photo to camera roll
                if picker.sourceType == .Camera {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
        } else {
            result = false
        }
        
        var message: String
        if result == true {
            message = "照片已添加"
        } else {
            message = "照片添加失败，请再次尝试"
        }
        picker.dismissViewControllerAnimated(true, completion: {popupPrompt(message, self.view)})
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //  MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patientTableView.rowHeight = 58
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePickerController = UIImagePickerController()
            imagePickerController!.sourceType = .Camera
            imagePickerController!.mediaTypes = [kUTTypeImage]
            imagePickerController!.allowsEditing = false // 如果允许编辑，总是得到正方形照片
            imagePickerController!.delegate = self
        }
        
        progressHUD = ProgressHUD(text: "照片添加中")
        self.view.addSubview(progressHUD)
        progressHUD.hide()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        title = "" + patient!.g("name")
        loadData()
        updateInfoView()
        updateStarBarButtonItemDisplay()
        patientTableView.reloadData()
    }
    
    
    // MARK: - TableView Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // records + summary (行医心得)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return records.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if patient != nil {
                let cnt = records.count
                return cnt > 0 ? "\(cnt)次就诊记录" : "尚无就诊记录"
            } else {
                return ""
            }
        default:
            return ""
        }
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 && records.count > 0 {
            return "左滑可以删除记录或快速添加照片"
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { // records
            // use SWTableViewCell
            let cell = patientTableView.dequeueReusableCellWithIdentifier("recordCell", forIndexPath: indexPath) as! RecordTableViewCell
            
            let r = records[indexPath.row]
            cell.titleLabel.text = NSDateFormatter.localizedStringFromDate(r.date, dateStyle: .MediumStyle, timeStyle: .NoStyle)
            var detailText = ""
            if indexPath.row == records.count-1 {
                detailText += "首诊"
            } else {
                detailText += "首诊后\(r.daysAfterFirstTreatment)天"
            }
            if let daysAfterLastOp = r.daysAfterLastOperation {
                if daysAfterLastOp == 0 {
                    detailText += "，当天手术"
                } else {
                    detailText += "，术后\(daysAfterLastOp)天"
                }
            }
            cell.subtitleLabel.text = detailText
            
            if r.photoMemos.count > 0 {
                cell.photoMemoStatusImageView.image = UIImage(named: "image-20")
            } else {
                cell.photoMemoStatusImageView.image = nil
            }
            
            return cell
            
        } else { // summary
            let cell = patientTableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }

    // MARK: - TabelView Delegate

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }

    
    // 实现Swipe Cell的多个Control：使用Apple内置方法 (>iOS 8.0).
    // 需要实现两个delegate：commitEditingStyle和editActionsForRowAtIndexPath
    // 放弃SWTableViewCell因为显示太多layout warnings
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        if indexPath.section == 0 { // record
            
            currentOperatedRecord = records[indexPath.row]
            
            // 添加照片
            var cameraAction = UITableViewRowAction(style: .Normal, title: "添加照片") { (action, indexPath) -> Void in
                self.takeOrImportPhotoForRecord()
            }
            cameraAction.backgroundColor = UIColor.grayColor()
    //        shareAction.backgroundColor = UIColor(patternImage: UIImage(named:"star-toolbar")!)
            
            // 删除记录
            var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "删除") { (action, indexPath) -> Void in
                var alert = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .ActionSheet
                )
                alert.addAction(UIAlertAction(
                    title: "删除检查记录",
                    style: .Destructive,
                    handler: { (action) -> Void in
//                        println("deleting record with id: \(self.currentOperatedRecord!.date)")
                        self.currentOperatedRecord!.removeFromDB()
                        println("record deleted")
                        self.loadData()
                        self.patientTableView.reloadData()
                    }
                    ))
                alert.addAction(UIAlertAction(
                    title: "取消",
                    style: .Cancel,
                    handler: nil
                    ))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            deleteAction.backgroundColor = UIColor.redColor()
            
            return [deleteAction, cameraAction]
            
        } else {
            return []
        }
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            case "showRecord":
                let cell = sender as! UITableViewCell
                if let indexPath = patientTableView.indexPathForCell(cell) {
                    let recordVC = segue.destinationViewController.topViewController as! RecordTableViewController
                    recordVC.setShowRecord(records[indexPath.row])
                }
                
            case "addRecord":
                if patient != nil {
                    let recordVC = segue.destinationViewController.topViewController as! RecordTableViewController
                    recordVC.setNewRecord(patient!)
                }
                
            case "showSummary":
                if patient != nil {
                    let patientSummaryVC = segue.destinationViewController.topViewController as! PatientSummaryViewController
                    patientSummaryVC.patient = patient!
                }
       
            case "showPatientInfo":
                let patientInfoVC = segue.destinationViewController.topViewController as! PatientInfoTableViewController
                patientInfoVC.setShowPatient(patient!)
            
            case "showChart":
                let chartVC = segue.destinationViewController.topViewController as! ChartViewController
                chartVC.patient = self.patient
                
            case "showReport":
                let reportVC = segue.destinationViewController.topViewController as! ReportViewController
                reportVC.patient = self.patient
                
                
            default: break
            }
        }
    }
}
