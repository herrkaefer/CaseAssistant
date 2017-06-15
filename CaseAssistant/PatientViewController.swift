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
            let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(PatientViewController.handleSingleTapOnInfoView(_:)))
            infoView.addGestureRecognizer(singleFingerTap)
        }
    }
    @IBOutlet weak var starBarButtonItem: UIBarButtonItem!
    
//    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Helper Functions
 
    func loadData() {
        records.removeAll()
        records.append(contentsOf: patient!.recordsSortedDescending)
    }
    
    
    func updateInfoView() {
        let name = patient!.g("name")
        let gender = patient!.g("gender")
        patientInfoLabel.text! = "\(name), \(gender), \(patient!.treatmentAge)岁"
        if patient!.firstDiagnosis != nil {
            patientDiagnosisLabel.text = "\(patient!.firstDiagnosis!)"
        } else {
            patientDiagnosisLabel.text = patient!.g("diagnosis")
        }
        
        let tagNames = patient!.tagNames
        if tagNames.count > 0 {
            tagsLabel.text! = " " + tagNames.joined(separator: " ") + " "
        } else {
            tagsLabel.text! = ""
        }
        tagsLabel.layer.cornerRadius = 3.0
        tagsLabel.layer.masksToBounds = true
    }
    
    
    func updateStarBarButtonItemDisplay() {
        if patient?.starred == true {
            starBarButtonItem.image = UIImage(named: "star-29")
            starBarButtonItem.tintColor = CaseApp.starredColor
        } else {
            starBarButtonItem.image = UIImage(named: "star-outline-29")
            starBarButtonItem.tintColor = UIColor.white
        }
    }
    
    
    func addLastPhotoInLibraryToPhotoMemo() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let lastAsset = fetchResult.lastObject {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            PHImageManager.default().requestImage(for: lastAsset, targetSize: PhotoMemo.imageSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) -> Void in
                let result = self.currentOperatedRecord!.addPhotoMemo(image!, creationDate: lastAsset.creationDate!, shouldScaleDown: false)
                if result == true {
                    self.patientTableView.reloadData()
                    // 弹出保存成功提示
                    popupPrompt("照片已添加", inView: self.view)
                } else {
                    popupPrompt("照片添加失败，请再试一次", inView: self.view)
                }
            })
        }
    }
    
    func takeOrImportPhotoForRecord() {
        if currentOperatedRecord == nil {
            return
        }
        
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: "相册中最新一张照片",
            style: .default,
            handler: {action in
//                self.progressHUD.show()
                self.addLastPhotoInLibraryToPhotoMemo()
//                self.progressHUD.hide()
            }
            ))
        alert.addAction(UIAlertAction(
            title: "拍摄照片",
            style: .default,
            handler: {action in
                if self.imagePickerController != nil {
                    self.present(self.imagePickerController!, animated: true, completion: nil)
                }
            }
            ))
        alert.addAction(UIAlertAction(
            title: "从相册中选择",
            style: .default,
            handler: {action in
                let qbImagePickerController = QBImagePickerController()
                qbImagePickerController.mediaType = .image
                qbImagePickerController.allowsMultipleSelection = true
                qbImagePickerController.prompt = "选择照片(可多选)"
                qbImagePickerController.showsNumberOfSelectedAssets = true
                qbImagePickerController.delegate = self
                self.present(qbImagePickerController, animated: true, completion: nil)
            }
            ))
        alert.addAction(UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil
            ))
        
        alert.modalPresentationStyle = .popover
        let ppc = alert.popoverPresentationController
        ppc?.barButtonItem = starBarButtonItem
        present(alert, animated: true, completion: nil)
    }

    
    // MARK: - IBActions
    
    func handleSingleTapOnInfoView(_ gesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showPatientInfo", sender: self)
    }
    
    
    @IBAction func showMorePatientInfo(_ sender: UIButton) {
        performSegue(withIdentifier: "showPatientInfo", sender: self)
    }
    
    @IBAction func starPatient(_ sender: UIBarButtonItem) {
        patient!.toggleStar()
        updateStarBarButtonItemDisplay()
    }

    // MARK: - QBImagePickerViewController Delegate
    // 从相册多选时使用
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
//        activityIndicatorView.startAnimating()
        progressHUD.show()
        
        var addCnt: Int = 0
        var gotCnt: Int = 0
        
        // save images
        for asset in (assets as! [PHAsset]) {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PhotoMemo.imageSize,
                contentMode: .aspectFit,
                options: options,
                resultHandler: { (image, info) -> Void in
                    gotCnt += 1
                    let result = self.currentOperatedRecord!.addPhotoMemo(image!, creationDate: asset.creationDate!, shouldScaleDown: false)
                    if result == true {
                        addCnt += 1
                    }
                    if gotCnt == assets.count {
                        self.patientTableView.reloadData()
//                        self.activityIndicatorView.stopAnimating()
                        self.progressHUD.hide()
                        popupPrompt("\(addCnt)张照片已添加", inView: self.view)
                    }
            })
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    // 使用相机拍摄照片时使用
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var result = false
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if image != nil {
            result = currentOperatedRecord!.addPhotoMemo(image!, creationDate: Date(), shouldScaleDown: true)
            if result == true {
                // also save photo to camera roll
                if picker.sourceType == .camera {
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
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
        picker.dismiss(animated: true, completion: {popupPrompt(message, inView: self.view)})
    }
 
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //  MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patientTableView.rowHeight = 58
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController = UIImagePickerController()
            imagePickerController!.sourceType = .camera
            imagePickerController!.mediaTypes = [kUTTypeImage as String]
            imagePickerController!.allowsEditing = false // 如果允许编辑，总是得到正方形照片
            imagePickerController!.delegate = self
        }
        
        progressHUD = ProgressHUD(text: "照片添加中")
        self.view.addSubview(progressHUD)
        progressHUD.hide()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        title = "" + patient!.g("name")
        loadData()
        updateInfoView()
        updateStarBarButtonItemDisplay()
        patientTableView.reloadData()
    }
    
    
    // MARK: - TableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // records + summary (行医心得)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return records.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 && records.count > 0 {
            return "左滑可以删除记录或快速添加照片"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 { // records
            // use SWTableViewCell
            let cell = patientTableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordTableViewCell
            
            let r = records[indexPath.row]
            cell.titleLabel.text = DateFormatter.localizedString(from: r.date as Date, dateStyle: .medium, timeStyle: .none)
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
            let cell = patientTableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) 
            return cell
        }
    }

    // MARK: - TabelView Delegate

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }

    
    // 实现Swipe Cell的多个Control：使用Apple内置方法 (>iOS 8.0).
    // 需要实现两个delegate：commitEditingStyle和editActionsForRowAtIndexPath
    // 放弃SWTableViewCell因为显示太多layout warnings
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 { // record
            
            currentOperatedRecord = records[indexPath.row]
            
            // 添加照片
            let cameraAction = UITableViewRowAction(style: .normal, title: "添加照片") { (action, indexPath) -> Void in
                self.takeOrImportPhotoForRecord()
            }
            cameraAction.backgroundColor = UIColor.gray
            //        shareAction.backgroundColor = UIColor(patternImage: UIImage(named:"star-toolbar")!)
            
            // 删除记录
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "删除") { (action, indexPath) -> Void in
                let alert = UIAlertController(
                    title: nil,
                    message: nil,
                    preferredStyle: .actionSheet
                )
                alert.addAction(UIAlertAction(
                    title: "删除检查记录",
                    style: .destructive,
                    handler: { (action) -> Void in
                        //                        print("deleting record with id: \(self.currentOperatedRecord!.date)")
                        self.currentOperatedRecord!.removeFromDB()
                        print("record deleted")
                        self.loadData()
                        self.patientTableView.reloadData()
                }
                ))
                alert.addAction(UIAlertAction(
                    title: "取消",
                    style: .cancel,
                    handler: nil
                ))
                self.present(alert, animated: true, completion: nil)
            }
            deleteAction.backgroundColor = UIColor.red
            
            return [deleteAction, cameraAction]
            
        } else {
            return []
        }
    }
    
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            case "showRecord":
                let cell = sender as! UITableViewCell
                if let indexPath = patientTableView.indexPath(for: cell) {
                    let recordVC = segue.destination as! RecordTableViewController
                    recordVC.setShowRecord(records[indexPath.row])
                }
                
            case "addRecord":
                if patient != nil {
                    let recordVC = segue.destination as! RecordTableViewController
                    recordVC.setNewRecord(patient!)
                }
                
            case "showSummary":
                if patient != nil {
                    let patientSummaryVC = segue.destination as! PatientSummaryViewController
                    patientSummaryVC.patient = patient!
                }
       
            case "showPatientInfo":
                let patientInfoVC = segue.destination as! PatientInfoTableViewController
                patientInfoVC.setShowPatient(patient!)
            
            case "showChart":
                let chartVC = segue.destination as! ChartViewController
                chartVC.patient = self.patient
                
            case "showReport":
                let reportVC = segue.destination as! ReportViewController
                reportVC.patient = self.patient
                
                
            default: break
            }
        }
    }
}
