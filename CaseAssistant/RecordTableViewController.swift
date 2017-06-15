//
//  RecordTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import MobileCoreServices
import QBImagePickerController
import IDMPhotoBrowser


class RecordTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QBImagePickerControllerDelegate, IDMPhotoBrowserDelegate
{

    // MARK: - Variables
    
    var record: Record? {
        didSet {
            patient = record?.owner
//            generateHelperDictionaries()
        }
    }
    
    var patient: Patient? // owner of record
    var isNewRecord = false

    var photoMemos = [PhotoMemo]()
//    var voiceMemos = [VoiceMemo]()

    var currentOperatedLabel: UILabel?
    
    var imagePickerController: UIImagePickerController?
//    var qbImagePickerController: QBImagePickerController?
    
    var progressHUD: ProgressHUD!
    
    // MARK: - Helper Functions

    func loadPhotoMemos() {
        photoMemos.removeAll()
        photoMemos.append(contentsOf: record!.photoMemosSortedByCreationDateAscending)
    }
    
    func setNewRecord(_ ofPatient: Patient) {
        record = ofPatient.addRecord()
        isNewRecord = true
    }
    
    func setShowRecord(_ ofRecord: Record) {
        record = ofRecord
        loadPhotoMemos()
        isNewRecord = false
    }
    
    func setLabel(_ label: UILabel, itemName: String) {
//        print("set label for \(itemName)")
        label.layer.cornerRadius = 5.0
        label.layer.masksToBounds = true
        label.text = record!.g(itemName) + Record.nameToItems[itemName]!.suffix
        label.tag = Record.nameToItems[itemName]!.tag
        label.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(RecordTableViewController.tapOnItem(_:)))
        recognizer.numberOfTapsRequired = 1
        label.addGestureRecognizer(recognizer)
    }

    func updateDataAndUIWithTag(_ tag: Int, text: String, isCustomText: Bool) {
        if currentOperatedLabel != nil {
            if isCustomText == true {
                currentOperatedLabel!.text = Record.tagToItems[tag]!.prefix + text + Record.tagToItems[tag]!.suffix
            } else {
                currentOperatedLabel!.text = text
            }
            record!.s(Record.tagToItems[tag]!.name, value: text)
            currentOperatedLabel = nil
        }
        tableView.reloadData()
    }
    
    func setTitle() {
        if isNewRecord {
            title = "新增记录"
        } else {
            title = DateFormatter.localizedString(from: record!.date as Date, dateStyle: .medium, timeStyle: .none)
        }
    }

    // 输入方式：基本选项 + textView
    func tapOnItem(_ gesture: UITapGestureRecognizer) {
//        print("tap \(gesture.view?.tag)")
        if let tag = gesture.view?.tag {
            print(Record.tagToItems[tag]!.basicChoices)
        }
        performSegue(withIdentifier: "showChoices", sender: gesture.view)
    }
    
    func addLastPhotoInLibraryToPhotoMemo() {
        // get last photo
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let lastAsset = fetchResult.lastObject {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .fast
            PHImageManager.default().requestImage(
                for: lastAsset,
                targetSize: PhotoMemo.imageSize,
                contentMode: .aspectFit,
                options: options,
                resultHandler: { (image, info) -> Void in
                    let result = self.record!.addPhotoMemo(image!, creationDate: lastAsset.creationDate!, shouldScaleDown: false)
                    if result == true {
                        // reload collectionView
                        self.loadPhotoMemos()
                        self.photoMemosCollectionView.reloadData()
                        // prompt for success
                        popupPrompt("照片已添加", inView: self.view)
                    }
                })
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var addPhotoMemoBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var photoMemosCollectionView: UICollectionView!
    
    @IBOutlet weak var dateButton: UIButton! {
        didSet {
            dateButton.setTitle(DateFormatter.localizedString(from: record!.date as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
        }
    }
    
    @IBOutlet weak var rShiliLabel: UILabel! {
        didSet {
            setLabel(rShiliLabel, itemName: "rShili")
        }
    }
    
    @IBOutlet weak var lShiliLabel: UILabel! {
        didSet {
            setLabel(lShiliLabel, itemName: "lShili")
        }
    }
    
    @IBOutlet weak var rJiaozhengshiliLabel: UILabel! {
        didSet {
            setLabel(rJiaozhengshiliLabel, itemName: "rJiaozhengshili")
        }
    }

    @IBOutlet weak var lJiaozhengshiliLabel: UILabel! {
        didSet {
            setLabel(lJiaozhengshiliLabel, itemName: "lJiaozhengshili")
        }
    }
    
    // r DS
    @IBOutlet weak var rJiaozhengshilizhujingLabel: UILabel! {
        didSet {
            setLabel(rJiaozhengshilizhujingLabel, itemName: "rJiaozhengshilizhujing")
        }
    }
    
    // r DC
    @IBOutlet weak var rJiaozhengshililengjingLabel: UILabel! {
        didSet {
            setLabel(rJiaozhengshililengjingLabel, itemName: "rJiaozhengshililengjing")
        }
    }

    @IBOutlet weak var rJiaozhengshilizhouweiLabel: UILabel! {
        didSet {
            setLabel(rJiaozhengshilizhouweiLabel, itemName: "rJiaozhengshilizhouwei")
        }
    }
    
    @IBOutlet weak var lJiaozhengshilizhouweiLabel: UILabel! {
        didSet {
            setLabel(lJiaozhengshilizhouweiLabel, itemName: "lJiaozhengshilizhouwei")
        }
    }

    // l DS
    @IBOutlet weak var lJiaozhengshilizhujingLabel: UILabel! {
        didSet {
            setLabel(lJiaozhengshilizhujingLabel, itemName: "lJiaozhengshilizhujing")
        }
    }

    // l DC
    @IBOutlet weak var lJiaozhengshililengjingLabel: UILabel! {
        didSet {
            setLabel(lJiaozhengshililengjingLabel, itemName: "lJiaozhengshililengjing")
        }
    }

    @IBOutlet weak var rYanyaLabel: UILabel! {
        didSet {
//            setLabelAsTextField(rYanyaLabel, itemName: "rYanya")
            setLabel(rYanyaLabel, itemName: "rYanya")
        }
    }
    
    @IBOutlet weak var lYanyaLabel: UILabel! {
        didSet {
//            setLabelAsTextField(lYanyaLabel, itemName: "lYanya")
            setLabel(lYanyaLabel, itemName: "lYanya")
        }
    }
    
    @IBOutlet weak var rYanjianLabel: UILabel! {
        didSet {
            setLabel(rYanjianLabel, itemName: "rYanjian")
        }
    }
    
    @IBOutlet weak var lYanjianLabel: UILabel! {
        didSet {
            setLabel(lYanjianLabel, itemName: "lYanjian")
        }
    }
    
    @IBOutlet weak var rJiemoLabel: UILabel! {
        didSet {
            setLabel(rJiemoLabel, itemName: "rJiemo")
        }
    }
    
    @IBOutlet weak var lJiemoLabel: UILabel! {
        didSet {
            setLabel(lJiemoLabel, itemName: "lJiemo")
        }
    }
    
    @IBOutlet weak var rJiaomoLabel: UILabel! {
        didSet {
            setLabel(rJiaomoLabel, itemName: "rJiaomo")
        }
    }
    
    @IBOutlet weak var lJiaomoLabel: UILabel! {
        didSet {
            setLabel(lJiaomoLabel, itemName: "lJiaomo")
        }
    }
    
    @IBOutlet weak var rZhoubianshenduLabel: UILabel! {
        didSet {
            setLabel(rZhoubianshenduLabel, itemName: "rZhoubianshendu")
        }
    }

    @IBOutlet weak var lZhoubianshenduLabel: UILabel! {
        didSet {
            setLabel(lZhoubianshenduLabel, itemName: "lZhoubianshendu")
        }
    }

    @IBOutlet weak var rFangshanLabel: UILabel! {
        didSet {
            setLabel(rFangshanLabel, itemName: "rFangshan")
        }
    }
    
    @IBOutlet weak var lFangshanLabel: UILabel! {
        didSet {
            setLabel(lFangshanLabel, itemName: "lFangshan")
        }
    }

    @IBOutlet weak var rFangshuixibaoLabel: UILabel! {
        didSet {
            setLabel(rFangshuixibaoLabel, itemName: "rFangshuixibao")
        }
    }

    @IBOutlet weak var lFangshuixibaoLabel: UILabel! {
        didSet {
            setLabel(lFangshuixibaoLabel, itemName: "lFangshuixibao")
        }
    }

    @IBOutlet weak var rHongmoLabel: UILabel! {
        didSet {
            setLabel(rHongmoLabel, itemName: "rHongmo")
        }
    }
    
    @IBOutlet weak var lHongmoLabel: UILabel! {
        didSet {
            setLabel(lHongmoLabel, itemName: "lHongmo")
        }
    }
    
    @IBOutlet weak var rTongkongLabel: UILabel! {
        didSet {
            setLabel(rTongkongLabel, itemName: "rTongkong")
        }
    }
    
    @IBOutlet weak var lTongkongLabel: UILabel! {
        didSet {
            setLabel(lTongkongLabel, itemName: "lTongkong")
        }
    }
    
    @IBOutlet weak var rTongkongzhijingLabel: UILabel! {
        didSet {
//            setLabelAsTextField(rTongkongzhijingLabel, itemName: "rTongkongzhijing")
            setLabel(rTongkongzhijingLabel, itemName: "rTongkongzhijing")
        }
    }
    
    @IBOutlet weak var lTongkongzhijingLabel: UILabel! {
        didSet {
//            setLabelAsTextField(lTongkongzhijingLabel, itemName: "lTongkongzhijing")/
            setLabel(lTongkongzhijingLabel, itemName: "lTongkongzhijing")
        }
    }
 
    @IBOutlet weak var rDuiguangfansheLabel: UILabel! {
        didSet {
            setLabel(rDuiguangfansheLabel, itemName: "rDuiguangfanshe")
        }
    }
    
    @IBOutlet weak var lDuiguangfansheLabel: UILabel! {
        didSet {
            setLabel(lDuiguangfansheLabel, itemName: "lDuiguangfanshe")
        }
    }
    
    @IBOutlet weak var rJingzhuangtiLabel: UILabel! {
        didSet {
            setLabel(rJingzhuangtiLabel, itemName: "rJingzhuangti")
        }
    }

    @IBOutlet weak var lJingzhuangtiLabel: UILabel! {
        didSet {
            setLabel(lJingzhuangtiLabel, itemName: "lJingzhuangti")
        }
    }

    @IBOutlet weak var rJingzhuangtiheLabel: UILabel! {
        didSet {
            setLabel(rJingzhuangtiheLabel, itemName: "rJingzhuangtihe")
        }
    }
    
    @IBOutlet weak var lJingzhuangtiheLabel: UILabel! {
        didSet {
            setLabel(lJingzhuangtiheLabel, itemName: "lJingzhuangtihe")
        }
    }

    @IBOutlet weak var rHounangxiaLabel: UILabel! {
        didSet {
            setLabel(rHounangxiaLabel, itemName: "rHounangxia")
        }
    }

    @IBOutlet weak var lHounangxiaLabel: UILabel! {
        didSet {
            setLabel(lHounangxiaLabel, itemName: "lHounangxia")
        }
    }

    @IBOutlet weak var rBolitiLabel: UILabel! {
        didSet {
            setLabel(rBolitiLabel, itemName: "rBoliti")
        }
    }
    
    @IBOutlet weak var lBolitiLabel: UILabel! {
        didSet {
            setLabel(lBolitiLabel, itemName: "lBoliti")
        }
    }

    @IBOutlet weak var rSantongLabel: UILabel! {
        didSet {
            setLabel(rSantongLabel, itemName: "rSantong")
        }
    }
    
    @IBOutlet weak var lSantongLabel: UILabel! {
        didSet {
            setLabel(lSantongLabel, itemName: "lSantong")
        }
    }
    
    @IBOutlet weak var rShiwangmoLabel: UILabel! {
        didSet {
            setLabel(rShiwangmoLabel, itemName: "rShiwangmo")
        }
    }

    @IBOutlet weak var lShiwangmoLabel: UILabel! {
        didSet {
            setLabel(lShiwangmoLabel, itemName: "lShiwangmo")
        }
    }

    
    @IBOutlet weak var rYanweiLabel: UILabel! {
        didSet {
            setLabel(rYanweiLabel, itemName: "rYanwei")
        }
    }

    @IBOutlet weak var lYanweiLabel: UILabel! {
        didSet {
            setLabel(lYanweiLabel, itemName: "lYanwei")
        }
    }
    
    @IBOutlet weak var rYanjijianchaLabel: UILabel! {
        didSet {
            setLabel(rYanjijianchaLabel, itemName: "rYanjijiancha")
        }
    }
    
    @IBOutlet weak var lYanjijianchaLabel: UILabel! {
        didSet {
            setLabel(lYanjijianchaLabel, itemName: "lYanjijiancha")
        }
    }
    
    @IBOutlet weak var rYanqiudaxiaoLabel: UILabel! {
        didSet {
            setLabel(rYanqiudaxiaoLabel, itemName: "rYanqiudaxiao")
        }
    }

    
    @IBOutlet weak var lYanqiudaxiaoLabel: UILabel! {
        didSet {
            setLabel(lYanqiudaxiaoLabel, itemName: "lYanqiudaxiao")
        }
    }

    
    @IBOutlet weak var rYanqiutuchuLabel: UILabel! {
        didSet {
            setLabel(rYanqiutuchuLabel, itemName: "rYanqiutuchu")
        }
    }

    
    @IBOutlet weak var lYanqiutuchuLabel: UILabel! {
        didSet {
            setLabel(lYanqiutuchuLabel, itemName: "lYanqiutuchu")
        }
    }

    
    @IBOutlet weak var rYanqiuaoxianLabel: UILabel! {
        didSet {
            setLabel(rYanqiuaoxianLabel, itemName: "rYanqiuaoxian")
        }
    }

    
    @IBOutlet weak var lYanqiuaoxianLabel: UILabel! {
        didSet {
            setLabel(lYanqiuaoxianLabel, itemName: "lYanqiuaoxian")
        }
    }

    @IBOutlet weak var conditionDescriptionTextView: UITextView! {
        didSet {
            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            conditionDescriptionTextView.layer.borderColor = borderColor.cgColor
            conditionDescriptionTextView.layer.cornerRadius = 5.0
            conditionDescriptionTextView.layer.borderWidth = 0.5
            conditionDescriptionTextView.text = record!.g("conditionDescription")
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView! {
        didSet {
            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            commentTextView.layer.borderColor = borderColor.cgColor
            commentTextView.layer.cornerRadius = 5.0
            commentTextView.layer.borderWidth = 0.5
            commentTextView.text = record!.g("comment")
        }
    }

    @IBOutlet weak var preliminaryDiagnosisTextView: UITextView! {
        didSet {
            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            preliminaryDiagnosisTextView.layer.borderColor = borderColor.cgColor
            preliminaryDiagnosisTextView.layer.cornerRadius = 5.0
            preliminaryDiagnosisTextView.layer.borderWidth = 0.5
            preliminaryDiagnosisTextView.text = record!.g("preliminaryDiagnosis")
        }
    }

    @IBOutlet weak var dosageTextView: UITextView! {
        didSet {
            let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            dosageTextView.layer.borderColor = borderColor.cgColor
            dosageTextView.layer.cornerRadius = 5.0
            dosageTextView.layer.borderWidth = 0.5
            dosageTextView.text = record!.g("dosage")
        }
    }
    
    @IBOutlet weak var operationPerfomedSwitch: UISwitch! {
        didSet {
            operationPerfomedSwitch.setOn(record!.operationPerformed, animated: true)
            operationNameTextField.isHidden = !(record!.operationPerformed)
            operationDateButton.isHidden = !(record!.operationPerformed)
        }
    }
    

    @IBOutlet weak var operationNameTextField: UITextField! {
        didSet {
            operationNameTextField.text = record!.g("operationName")
            operationNameTextField.delegate = self
        }
    }
    
    @IBOutlet weak var operationDateButton: UIButton! {
        didSet {
            if record != nil {
                operationDateButton.setTitle(DateFormatter.localizedString(from: record!.operationDate as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
            }
        }
    }
    
    @IBOutlet weak var generateReportForShareButton: UIButton! {
        didSet {
            generateReportForShareButton.layer.cornerRadius = 5.0
        }
    }
    
    @IBOutlet weak var reportForShareTextView: UITextView! {
        didSet {
            reportForShareTextView.layer.borderColor = CaseApp.borderColor.cgColor
            reportForShareTextView.layer.cornerRadius = 5.0
            reportForShareTextView.layer.borderWidth = 0.5
            reportForShareTextView.text = record!.g("reportForShare")
        }
    }
    
    @IBOutlet weak var reportForShareTextViewHeightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Actions
    
    @IBAction func generateReportForShareButtonPressed(_ sender: UIButton) {
        if reportForShareTextView.text.isEmpty {
            self.reportForShareTextView.text = self.record!.report
        } else { // 非空弹出警示
            let alert = UIAlertController(
                title: "将使用模板自动生成的分享内容覆盖现有内容，确定？",
                message: nil,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: "取消",
                style: .cancel,
                handler: nil
                ))
            
            alert.addAction(UIAlertAction(
                title: "确定", style: .default, handler: { (action) -> Void in
                    self.reportForShareTextView.text = self.record!.report
                    self.record!.s("reportForShare", value: self.reportForShareTextView.text)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func operationPerformedSwitch(_ sender: UISwitch) {
        if sender.isOn { // 打开时重置手术日期为检查日期
            record!.sOperationDate(record!.date)
            operationDateButton.setTitle(DateFormatter.localizedString(from: record!.operationDate as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
        }
        record!.sOperationPerformed(sender.isOn)
        operationNameTextField.isHidden = !(sender.isOn)
        operationDateButton.isHidden = !(sender.isOn)
    }
    
    
    
    // MARK: - Add photomemo
    
    @IBAction func addPhotoMemo(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(
            title: "相册中最新一张照片",
            style: .default,
            handler: {action in
                self.addLastPhotoInLibraryToPhotoMemo()
            }
            ))
        
        alert.addAction(UIAlertAction(
            title: "拍摄照片",
            style: .default,
            handler: {action in
                if self.imagePickerController != nil {
                    print("here")
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
        ppc?.barButtonItem = addPhotoMemoBarButtonItem
        present(alert, animated: true, completion: nil)
    }

    // QBImagePickerViewController Delegate
    // 从相册多选时使用
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        
        progressHUD.show()
        var addCnt: Int = 0 // number of photo successfully added
        var gotCnt: Int = 0 // number of photo got from requested
        
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
//                    print("got \(gotCnt)")
                    let result = self.record!.addPhotoMemo(image!, creationDate: asset.creationDate!, shouldScaleDown: false)
                    if result == true {
                        addCnt += 1
                    }
                    if gotCnt == assets.count { // all photo got
//                        print("reload collectionView")
                        // reload collectionView
                        self.loadPhotoMemos()
                        self.photoMemosCollectionView.reloadData()
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
    
    
    // UIImagePickerControllerDelegate
    // 使用相机拍摄照片时使用
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var result = false
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        if image != nil {
            result = record!.addPhotoMemo(image!, creationDate: Date(), shouldScaleDown: true)
            if result == true {
                // also save photo to camera roll
                if picker.sourceType == .camera {
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                }
                // reload collectionView
                self.loadPhotoMemos()
                self.photoMemosCollectionView.reloadData()
            }
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
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - CollectionView DataSource & Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoMemos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == photoMemosCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoMemoCollectionViewCell
            // display thumbnail image here
            cell.thumbnailImageView.image = photoMemos[indexPath.row].thumbnailImage
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("selected: \(indexPath.row)")
//        print("file: \(photoMemos[indexPath.row].urlString)")
        var photos = [IDMPhoto]()
        for pm in photoMemos {
            if let filePath = pm.urlString {
                let p = IDMPhoto(filePath: filePath)
                p?.caption = pm.caption
                photos.append(p!)
            }
        }
        let browser = IDMPhotoBrowser(photos: photos)
        browser?.delegate = self
        browser?.displayArrowButton = true
        browser?.displayDoneButton = true
        browser?.usePopAnimation = true

        browser?.actionButtonTitles = ["删除"]
        browser?.setInitialPageIndex(UInt(indexPath.row))
        present(browser!, animated: true, completion: nil)
    }
    
    // MARK: - IDMPhotoBrowser Delegate
    func photoBrowser(_ photoBrowser: IDMPhotoBrowser!, didDismissActionSheetWithButtonIndex buttonIndex: UInt, photoIndex: UInt) {
        if buttonIndex == 0 { // delete photo
            dismiss(animated: true, completion: nil)
            // delete photomemo
            let pm = photoMemos[Int(photoIndex)]
            pm.removeFromDB()
            // reload data for collectionView
            self.photoMemos.remove(at: Int(photoIndex))
            self.photoMemosCollectionView.reloadData()

        }
    }
    

    // MARK: - TextFiled Delegate
    
    // 仅允许输入合法数值，长度小于等于6
    // from: http://www.globalnerdy.com/2015/01/03/how-to-program-an-ios-text-field-that-takes-only-numeric-input-with-a-maximum-length/
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        var result = true
//        let prospectiveText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
//        
//        if textField.tag == 101 {
//            if count(string) > 0 {
//                let disallowedCharacterSet = NSCharacterSet(charactersInString: "0123456789.-").invertedSet
//                let replacementStringIsLegal = string.rangeOfCharacterFromSet(disallowedCharacterSet) == nil
//                
//                let resultingStringLengthIsLegal = count(prospectiveText) <= 6
//                
//                let scanner = NSScanner(string: prospectiveText)
//                let resultingTextIsNumeric = scanner.scanDecimal(nil) && scanner.atEnd
//                
//                result = replacementStringIsLegal &&
//                    resultingStringLengthIsLegal &&
//                resultingTextIsNumeric
//            }
//            
//        }
//        return result
//    }
    
    // 按完成后撤销键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == operationNameTextField {
            record!.s("operationName", value: textField.text!)
        }
    }

    // MARK: - TextView Delegate

    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case commentTextView:
            record!.s("comment", value: textView.text)
        case preliminaryDiagnosisTextView:
            record!.s("preliminaryDiagnosis", value: textView.text)
        case dosageTextView:
            record!.s("dosage", value: textView.text)
        case conditionDescriptionTextView:
            record!.s("conditionDescription", value: textView.text)
        case reportForShareTextView:
            record!.s("reportForShare", value: textView.text)
        default:
            break
        }
    }

    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
        
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
//        setReportForShareTextViewHeight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 结束编辑状态，导致如有在编辑中的textField或textView，对应的endEditing()会被调用，从而可以在其中获得更新的数据
        view.endEditing(true)
        
        // 仅当此View被销毁(unload)时才save更改的record. 然而当弹出modal view输入选项时，willDisappear()也会被调用，因此需要判断。SO上提供的方法都无效，这里找到的解决方案是：see if self is visibleViewController, if it is, the back button is pressed and self is popped form the stack. otherwise, self is not visible, it means another view is popped on it and the record should not been saved
        // 另：unload()似乎已经不能用了
//        if self.navigationController?.visibleViewController == self {
//            print("Go back")
//            if recordIsUpdated == true {
//                record!.saveToDB()
//                print("record updated")
//            }
//        }
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 80.0
        case 1: fallthrough
        case 3: fallthrough
        case 4: fallthrough
        case 6:
            return 105
        case 7:
            return 250
        case 2:
            return 55
        case 5:
            return 47
        default:
            return 47
        }
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showChoices" {
            if let senderLabel = sender as? UILabel {
                currentOperatedLabel = senderLabel
                let tag = senderLabel.tag
                print("segue with tag: \(tag)")
                let nav = segue.destination as! UINavigationController
                let itemVC = nav.topViewController as! RecordItemTableViewController
                itemVC.senderTag = tag
                itemVC.basicChoices = Record.tagToItems[tag]!.basicChoices
                itemVC.hasCustomText = Record.tagToItems[tag]!.hasCustomText
                itemVC.resultText = record!.g(Record.tagToItems[tag]!.name)
                itemVC.title = Record.tagToItems[tag]!.displayName
                if Record.tagToItems[tag]!.dataFormat == "Float" {
                    itemVC.isNumeric = true
                    itemVC.unit = Record.tagToItems[tag]!.suffix
                } else {
                    itemVC.isNumeric = false
                    itemVC.unit = ""
                }                
            }
        }
        
        else if segue.identifier == "showRecordDatePicker" {
            let datePickerVC = (segue.destination as! UINavigationController).topViewController as! DatePickerViewController
            if record != nil {
                datePickerVC.fromVC = "RecordTVCRecordDate"
                datePickerVC.selectedDate = record!.date
            }
        }
        
        else if segue.identifier == "showOperationDatePicker" {
            let datePickerVC = (segue.destination as! UINavigationController).topViewController as! DatePickerViewController
            if record != nil {
                datePickerVC.fromVC = "RecordTVCOperationDate"
                datePickerVC.selectedDate = record!.operationDate
            }
        }
    }
    
    // Unwind segue
    @IBAction func goBackToRecordViewController(_ segue: UIStoryboardSegue) {
        
        // from RecordItemTableViewController
        if let itemVC = segue.source as? RecordItemTableViewController, segue.identifier == "backToRecord" {

            switch itemVC.operationState {
            case "done":
                print("back from tag: \(itemVC.senderTag!) with done, text: \(itemVC.resultText!)")
                // update record and UI
                if itemVC.senderTag != nil && itemVC.resultText != nil {
                    let isCustomText = itemVC.selectedRow == nil
                    updateDataAndUIWithTag(itemVC.senderTag!, text: itemVC.resultText!, isCustomText: isCustomText)
                }
                
            case "cancel":
                print("back from tag: \(itemVC.senderTag!) with cancel")
                
            default: break
            }
        }
        
        // from DatePickerViewController
        else if let datePickerVC = segue.source as? DatePickerViewController {
            if segue.identifier == "backToRecordDate" {
                if datePickerVC.selectedDate != nil {
                    record!.sDate(datePickerVC.selectedDate!)
                    dateButton.setTitle(DateFormatter.localizedString(from: datePickerVC.selectedDate! as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
                    if !isNewRecord {
                        setTitle()
                    }
                }
            } else if segue.identifier == "backToOperationDate" {
                if datePickerVC.selectedDate != nil {
                    record!.sOperationDate(datePickerVC.selectedDate!)
                    operationDateButton.setTitle(DateFormatter.localizedString(from: datePickerVC.selectedDate! as Date, dateStyle: .long, timeStyle: .none), for: UIControlState())
                }
            }
            
        }
    }

}
