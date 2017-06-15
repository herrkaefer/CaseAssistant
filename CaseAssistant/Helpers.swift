//
//  Util.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/24.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import Foundation
import UIKit
import MMDrawerController
import KLCPopup


func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}


// 随机产生一个今天之前days天之内的日期
func generateRandomDateWithinDaysBeforeToday(_ days: UInt32) -> Date {
    let r1 = arc4random_uniform(days)
    let r2 = arc4random_uniform(23)
    let r3 = arc4random_uniform(59)
    
    let today = Date()
    let calendar = Calendar.current
  
    var offsetComponents = DateComponents()
    
    offsetComponents.setValue(-Int(r1), for: .day)
    offsetComponents.setValue(-Int(r2), for: .hour)
    offsetComponents.setValue(-Int(r3), for: .minute)
    
    let rndDate = calendar.date(byAdding: offsetComponents, to: today)
    return rndDate!
}


// 随机产生n个今天之前days天之内的日期
func generateRandomDateArrayWithinDaysBeforeToday(_ n: Int, days: UInt32) -> [Date] {
    var generatedDates = [Date]()
    for _ in 0..<n {
        generatedDates.append(generateRandomDateWithinDaysBeforeToday(days))
    }
    return generatedDates.sorted(by: {$0.compare($1) == ComparisonResult.orderedAscending})
}


// 计算两个NSDate之间的相隔天数。直接用calendar.components不满足需要。
func numberOfDaysBetweenTwoDates(_ fromDate: Date, toDate: Date) -> Int {
    let calendar = Calendar.current
    
//    var comps = calendar.components(.day | .month | .year, fromDate: fromDate)
//    let fromDateNew = calendar.dateFromComponents(comps)
//    
//    comps = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: toDate)
//    let toDateNew = calendar.dateFromComponents(comps)
    
    let comps = calendar.dateComponents([.year, .month, .day], from: fromDate, to: toDate)
    return comps.day!
    
    // > iOS 8 可用：
//    let fromDate1 = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: fromDate, options: nil)
//    let toDate1 = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: toDate, options: nil)
    
//    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
//    if fromDateNew != nil && toDateNew != nil {
//        let components = calendar.components(NSCalendar.Unit.CalendarUnitDay, fromDate: fromDateNew!, toDate: toDateNew!, options: nil)
//        return components.day
//    } else {
//        return -1
//    }
}


extension String {
    func beginsWith (_ str: String) -> Bool {
        if let range = self.range(of: str) {
            return range.lowerBound == self.startIndex
        }
        return false
    }
    
    func endsWith (_ str: String) -> Bool {
        if let range = self.range(of: str) {
            return range.upperBound == self.endIndex
        }
        return false
    }
}


func appendedStringItem(_ strToAppend: String, punctuationBefore: String, strShouldBeAppended: Bool, punctuationShouldBeAdded: Bool) -> String {
    var re = ""
    if strShouldBeAppended {
        if punctuationShouldBeAdded {
            re += punctuationBefore
        }
        re += strToAppend
    }
    return re
}


// toggle MMDrawer side view
func toggleSideMenu() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.drawer?.toggle(MMDrawerSide.left, animated: true, completion: nil)
}


func enableSideMenuGesture(_ enabled: Bool) {
    if enabled {
        // enable侧栏的手势
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.drawer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
        appDelegate.drawer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.all
    } else {
        // disable侧栏的手势识别，不然和后面的tableView的swipe手势会冲突, tableViewCell也无法move
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.drawer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode()
        appDelegate.drawer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode()
    }
}


// get the MMDrawerController
func getDrawer() -> MMDrawerController? {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    return appDelegate.drawer
}


// use KLCPopup to show a flash prompt at top
func popupPrompt(_ text: String, inView: UIView) {
    let promptLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width*0.9, height: 44.0))
    promptLabel.backgroundColor = UIColor.orange
    promptLabel.textColor = UIColor.white
    promptLabel.font = UIFont.boldSystemFont(ofSize: 18)
    promptLabel.textAlignment = NSTextAlignment.center
    promptLabel.text = text
    
    let popup = KLCPopup(contentView: promptLabel, showType: KLCPopupShowType.slideInFromTop, dismissType: KLCPopupDismissType.shrinkOut, maskType: KLCPopupMaskType.clear, dismissOnBackgroundTouch: false, dismissOnContentTouch: false)
    
    popup?.show(atCenter: CGPoint(x: inView.bounds.width/2, y: 42.0), in: inView, withDuration: 0.5)
}

// use KLCPopup to show an activity indicator popup
func popupActivityIndicator(_ text: String, inView: UIView) -> KLCPopup {
    let promptLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width*0.9, height: 44.0))
    promptLabel.backgroundColor = UIColor.orange
    promptLabel.textColor = UIColor.white
    promptLabel.font = UIFont.boldSystemFont(ofSize: 18)
    promptLabel.textAlignment = NSTextAlignment.center
    promptLabel.text = text
    
    let popup = KLCPopup(contentView: promptLabel, showType: KLCPopupShowType.slideInFromTop, dismissType: KLCPopupDismissType.shrinkOut, maskType: KLCPopupMaskType.clear, dismissOnBackgroundTouch: false, dismissOnContentTouch: false)
    
//    popup.showAtCenter(CGPointMake(inView.bounds.width/2, 42.0), inView: inView)
        popup?.show(atCenter: CGPoint(x: UIScreen.main.bounds.width/2, y: 42.0), in: inView)
    return popup!
}

// resize image to fit target size, and keep ratio. eg. for thumbnail usage
func resizeImage(_ image: UIImage, targetSize: CGSize, forDisplay: Bool) -> UIImage {
    // 如果要真实尺寸，设forDisplay为false；如果做显示用，设为true
    let scale = (forDisplay == true) ? UIScreen.main.scale : 1.0
    
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
    //    UIGraphicsBeginImageContext(newSize)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!

}


func getDocumentsUrl() -> String {
//    let fileManager = FileManager.default
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docsDir = dirPaths[0] 
    return docsDir
}

func generateUniqueString() -> String {
    return UUID().uuidString
}



/* ------ 参考 ------ */

func RBResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.main.scale)
//    UIGraphicsBeginImageContext(newSize)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

func RBSquareImageTo(_ image: UIImage, size: CGSize) -> UIImage {
    return RBResizeImage(RBSquareImage(image), targetSize: size)
}

func RBSquareImage(_ image: UIImage) -> UIImage {
    let originalWidth  = image.size.width
    let originalHeight = image.size.height
    
    var edge: CGFloat
    if originalWidth > originalHeight {
        edge = originalHeight
    } else {
        edge = originalWidth
    }
    
    let posX = (originalWidth  - edge) / 2.0
    let posY = (originalHeight - edge) / 2.0
    
    let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
    
    let imageRef = image.cgImage?.cropping(to: cropSquare)
    return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
}


class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .dark)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        super.init(coder: aDecoder)!
        self.setup()
        
    }
    
    func setup() {
        contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(activityIndictor)
        vibrancyView.contentView.addSubview(label)
        activityIndictor.startAnimating()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let superview = self.superview {
            
            let width = superview.frame.size.width / 2.3
            let height: CGFloat = 50.0
            self.frame = CGRect(x: superview.frame.size.width / 2 - width / 2,
                y: superview.frame.height / 2 - height / 2,
                width: width,
                height: height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRect(x: 5, y: height / 2 - activityIndicatorSize / 2,
                width: activityIndicatorSize,
                height: activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: activityIndicatorSize + 5, y: 0, width: width - activityIndicatorSize - 15, height: height)
            label.textColor = UIColor.gray
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func changeText(_ text: String) {
        self.text = text
    }
}



// save data to folder ".../Documents/\(folder)/" with an unique name
func saveDataToFile(_ folderInDocuments: String, data: Data, suffix: String) -> (success: Bool, filename:String, urlString: String) {
    let fileManager = FileManager.default
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docsDir = dirPaths[0]
    let dataDir = (docsDir as NSString).appendingPathComponent(folderInDocuments)
    
    // create folder if it does not exist
    if !fileManager.fileExists(atPath: dataDir) {
        do {
            try fileManager.createDirectory(atPath: dataDir, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    let unique = Date.timeIntervalSinceReferenceDate
    let urlString = (dataDir as NSString).appendingPathComponent("\(unique)"+suffix)
    return ((try? data.write(to: URL(fileURLWithPath: urlString), options: [.atomic])) != nil, "\(unique)"+suffix, urlString)
}


func deleteDataFile(_ pathString: String) -> Bool {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: pathString) {
        do {
            try fileManager.removeItem(atPath: pathString)
            return true
        } catch {
            print(error)
            return false
        }
        //        if !fileManager.removeItem(atPath: pathString) {
        //            print("Failed to delete file: \(error!.localizedDescription)")
        //        } else {
        //            success = true
        //        }
    }
    return true
}

// get URL of image file saved in .../Documents/photos
func getURLFromFilename(_ filename: String, folderInDocuments: String) -> URL? {
    let fileManager = FileManager.default
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docsDir = dirPaths[0]
    let dataDir = (docsDir as NSString).appendingPathComponent(folderInDocuments)
    let urlString = (dataDir as NSString).appendingPathComponent(filename)
    
    if !fileManager.fileExists(atPath: urlString) {
        return nil
    }
    return URL(string: urlString)?.absoluteURL
}
