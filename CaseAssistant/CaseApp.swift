//
//  CaseAssistantApp.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import UIKit


// Global constants & variables
public class CaseApp {
    
    public static let appId = "1003007080"
    public static let appName = "眼科行医手记"
    public static let appSlogan = "「做眼科医生的好朋友」"
    public static let email = "casenoteapp@163.com"
    
    // Colors
    public static let baseColor = uicolorFromHex(0x2AB467) //(0x44A3CE)
    public static let backgroundColor = uicolorFromHex(0xF8F3EC)
    public static let starredColor = uicolorFromHex(0xFFC800)
    public static let borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    
    static var deviceVersion: Float {
        return (UIDevice.current.systemVersion as NSString).floatValue
    }
    
    static var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return (v != nil) ? v! : "1.0"
    }
    
    static var build: String {
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return (b != nil) ? b! : ""
    }
    
    // 跳转到 App Store 评分
    class func rate(completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/id" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }

}
