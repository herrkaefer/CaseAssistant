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


func uicolorFromHex(rgbValue:UInt32)->UIColor{
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

// 随机产生一个今天之前days天之内的日期
func generateRandomDateWithinDaysBeforeToday(days: UInt32) -> NSDate {
    let r1 = arc4random_uniform(days)
    let r2 = arc4random_uniform(23)
    let r3 = arc4random_uniform(59)
    
    let today = NSDate()
    let calendar = NSCalendar.currentCalendar()
  
    let offsetComponents = NSDateComponents()
    
    offsetComponents.setValue(-Int(r1), forComponent: NSCalendarUnit.CalendarUnitDay)
    offsetComponents.setValue(-Int(r2), forComponent: NSCalendarUnit.CalendarUnitHour)
    offsetComponents.setValue(-Int(r3), forComponent: NSCalendarUnit.CalendarUnitMinute)
    
    let rndDate = calendar.dateByAddingComponents(offsetComponents, toDate: today, options: nil)
    
    return rndDate!;
}

// 随机产生n个今天之前days天之内的日期
func generateRandomDateArrayWithinDaysBeforeToday(n: Int, days: UInt32) -> [NSDate] {
    var generatedDates = [NSDate]()
    for i in 0..<n {
        generatedDates.append(generateRandomDateWithinDaysBeforeToday(days))
    }
    return generatedDates.sorted({$0.compare($1) == NSComparisonResult.OrderedAscending})
}

// 计算两个NSDate之间的相隔天数。直接用calendar.components不满足需要。
func numberOfDaysBetweenTwoDates(fromDate: NSDate, toDate: NSDate) -> Int {
    let calendar = NSCalendar.currentCalendar()
    
    var comps = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: fromDate)
    let fromDateNew = calendar.dateFromComponents(comps)
    
    comps = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: toDate)
    let toDateNew = calendar.dateFromComponents(comps)
    
    // > iOS 8 可用：
//    let fromDate1 = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: fromDate, options: nil)
//    let toDate1 = calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: toDate, options: nil)
    
//    let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    if fromDateNew != nil && toDateNew != nil {
        let components = calendar.components(NSCalendarUnit.CalendarUnitDay, fromDate: fromDateNew!, toDate: toDateNew!, options: nil)
        return components.day
    } else {
        return -1
    }
}

extension String {
    func beginsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str) {
            return range.startIndex == self.startIndex
        }
        return false
    }
    
    func endsWith (str: String) -> Bool {
        if let range = self.rangeOfString(str) {
            return range.endIndex == self.endIndex
        }
        return false
    }
}

func appendedStringItem(strToAppend: String, punctuationBefore: String, strShouldBeAppended: Bool, punctuationShouldBeAdded: Bool) -> String {
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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    appDelegate.drawer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
}

func enableSideMenuGesture(enabled: Bool) {
    if enabled {
        // enable侧栏的手势
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        appDelegate.drawer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All
    } else {
        // disable侧栏的手势识别，不然和后面的tableView的swipe手势会冲突, tableViewCell也无法move
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.drawer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        appDelegate.drawer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.None
    }
}


// get the MMDrawerController
func getDrawer() -> MMDrawerController? {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    return appDelegate.drawer
}

// use KLCPopup to show a flash prompt at top
func popupPrompt(text: String, inView: UIView) {
    let promptLabel = UILabel(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width*0.9, 44.0))
    promptLabel.backgroundColor = UIColor.orangeColor()
    promptLabel.textColor = UIColor.whiteColor()
    promptLabel.font = UIFont.boldSystemFontOfSize(18)
    promptLabel.textAlignment = NSTextAlignment.Center
    promptLabel.text = text
    
    let popup = KLCPopup(contentView: promptLabel, showType: KLCPopupShowType.SlideInFromTop, dismissType: KLCPopupDismissType.ShrinkOut, maskType: KLCPopupMaskType.Clear, dismissOnBackgroundTouch: false, dismissOnContentTouch: false)
    
    popup.showAtCenter(CGPointMake(inView.bounds.width/2, 42.0), inView: inView, withDuration: 0.5)
}

// use KLCPopup to show an activity indicator popup
func popupActivityIndicator(text: String, inView: UIView) -> KLCPopup {
    let promptLabel = UILabel(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width*0.9, 44.0))
    promptLabel.backgroundColor = UIColor.orangeColor()
    promptLabel.textColor = UIColor.whiteColor()
    promptLabel.font = UIFont.boldSystemFontOfSize(18)
    promptLabel.textAlignment = NSTextAlignment.Center
    promptLabel.text = text
    
    let popup = KLCPopup(contentView: promptLabel, showType: KLCPopupShowType.SlideInFromTop, dismissType: KLCPopupDismissType.ShrinkOut, maskType: KLCPopupMaskType.Clear, dismissOnBackgroundTouch: false, dismissOnContentTouch: false)
    
//    popup.showAtCenter(CGPointMake(inView.bounds.width/2, 42.0), inView: inView)
        popup.showAtCenter(CGPointMake(UIScreen.mainScreen().bounds.width/2, 42.0), inView: inView)
    return popup
}

// resize image to fit target size, and keep ratio. eg. for thumbnail usage
func resizeImage(image: UIImage, targetSize: CGSize, forDisplay: Bool) -> UIImage {
    // 如果要真实尺寸，设forDisplay为false；如果做显示用，设为true
    let scale = (forDisplay == true) ? UIScreen.mainScreen().scale : 1.0
    
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
    //    UIGraphicsBeginImageContext(newSize)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage

}


func getDocumentsUrl() -> String {
    let fileManager = NSFileManager.defaultManager()
    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let docsDir = dirPaths[0] as! String
    return docsDir
}

func generateUniqueString() -> String {
    return NSUUID().UUIDString
}



/* ------ 参考 ------ */

func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.mainScreen().scale)
//    UIGraphicsBeginImageContext(newSize)
    image.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}

func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage {
    return RBResizeImage(RBSquareImage(image), size)
}

func RBSquareImage(image: UIImage) -> UIImage {
    var originalWidth  = image.size.width
    var originalHeight = image.size.height
    
    var edge: CGFloat
    if originalWidth > originalHeight {
        edge = originalHeight
    } else {
        edge = originalWidth
    }
    
    var posX = (originalWidth  - edge) / 2.0
    var posY = (originalHeight - edge) / 2.0
    
    var cropSquare = CGRectMake(posX, posY, edge, edge)
    
    var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
    return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)!
}


class ProgressHUD: UIVisualEffectView {
    
    var text: String? {
        didSet {
            label.text = text
        }
    }
    let activityIndictor: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    let label: UILabel = UILabel()
    let blurEffect = UIBlurEffect(style: .Dark)
    let vibrancyView: UIVisualEffectView
    
    init(text: String) {
        self.text = text
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        super.init(effect: blurEffect)
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        self.text = ""
        self.vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: blurEffect))
        super.init(coder: aDecoder)
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
            self.frame = CGRectMake(superview.frame.size.width / 2 - width / 2,
                superview.frame.height / 2 - height / 2,
                width,
                height)
            vibrancyView.frame = self.bounds
            
            let activityIndicatorSize: CGFloat = 40
            activityIndictor.frame = CGRectMake(5, height / 2 - activityIndicatorSize / 2,
                activityIndicatorSize,
                activityIndicatorSize)
            
            layer.cornerRadius = 8.0
            layer.masksToBounds = true
            label.text = text
            label.textAlignment = NSTextAlignment.Center
            label.frame = CGRectMake(activityIndicatorSize + 5, 0, width - activityIndicatorSize - 15, height)
            label.textColor = UIColor.grayColor()
            label.font = UIFont.boldSystemFontOfSize(16)
        }
    }
    
    func show() {
        self.hidden = false
    }
    
    func hide() {
        self.hidden = true
    }
    
    func changeText(text: String) {
        self.text = text
    }
}
