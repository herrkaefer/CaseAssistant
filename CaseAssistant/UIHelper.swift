//
//  UIHelper.swift
//  Copied from Cage
//
//  Created by HerrKaefer on 2017/4/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//


import Foundation
import UIKit


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    // 随机颜色, 饱和度固定
    static func random() -> UIColor {
        return UIColor(hue: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       saturation: 1.0,
                       brightness: CGFloat(arc4random()) / CGFloat(UInt32.max),
                       alpha: 1.0)
    }
}


public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}


func makePhoneCall(phoneNumber:String) {
    
    if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
        
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            //            application.open(phoneCallURL, options: [:], completionHandler: nil)
            application.openURL(phoneCallURL)
        }
    }
}


extension UITextField {
    
    // 边框设为红色作为error提示和记录
    func setError() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func setNormal() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
    }
    
    func hasError() -> Bool {
        return self.layer.borderWidth > 0
    }
}


extension UIViewController {
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}


extension UIButton {
    func setRoundShape() {
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
    }
}


//extension EasyTipView {
//    // 显示提示view, 如果已经显示则dismiss
//    func showFor(_ aView: UIView) {
//        if self.superview != nil {
//            self.dismiss()
//        }
//        else {
//            self.show(forView: aView)
//        }
//    }
//    
//    static var customGlobalPreferences: Preferences {
//        var p = EasyTipView.Preferences()
//        p.drawing.font = UIFont.systemFont(ofSize: 13)
//        p.drawing.foregroundColor = UIColor.white
//        p.drawing.backgroundColor = UIColor(rgb: 0x1C7BDC)
//        p.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
//        p.drawing.textAlignment = .justified
//        EasyTipView.globalPreferences = p
//        return p
//    }
//}

