//
//  AppDelegate.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import MMDrawerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var drawer: MMDrawerController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        print(getDocumentsUrl())
        
        // initialize data models
        initData()
        
        // create MMDrawer for side menu
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingStoryboard = UIStoryboard(name: "Setting", bundle: nil)
        
        let centerNav = mainStoryboard.instantiateViewController(withIdentifier: "initNav") as! UINavigationController
        let menuNav = settingStoryboard.instantiateViewController(withIdentifier: "settingNav") as! UINavigationController
        
        drawer = MMDrawerController(center: centerNav, leftDrawerViewController: menuNav)
        if drawer != nil {
            // open和close的手势识别在首页的willAppear()和willDisappear()中进行开关设置。这里不设置。
//            drawer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
//            drawer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All
            drawer!.setMaximumLeftDrawerWidth(UIScreen.main.bounds.width*3.0/4.0, animated: true, completion: nil)
            drawer!.setDrawerVisualStateBlock({ (drawerController: MMDrawerController!, drawerSide: MMDrawerSide, percentVisible: CGFloat) -> Void in
                let block = MMDrawerVisualState.slideAndScaleBlock()
                block!(drawerController, drawerSide, percentVisible)
            })
            
            window!.rootViewController = drawer
            window!.makeKeyAndVisible()
        }


        // change navigation bar appearance
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = uicolorFromHex(0xffffff)
        navigationBarAppearace.barTintColor = CaseApp.baseColor
        navigationBarAppearace.isTranslucent = false
        
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        // change status bar style
        // first edit info.plist: set View controller-based status bar appearance = NO
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        return true
    }

    
    
    // 友盟分享系统回调
//    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
//        return UMSocialSnsService.handleOpen(url)
//    }
    
    // 友盟分享系统回调
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        return UMSocialSnsService.handleOpen(url)
//    }
    
//    // 设置umeng_feedback alias（注意这里的alias参数和type参数都需要从UMFeedback获取，不能自行更改）
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        UMessage.registerDeviceToken(deviceToken)
//        print("umeng message alias is: \(UMFeedback.uuid())")
//        UMessage.addAlias(UMFeedback.uuid(), type: UMFeedback.messageType()) { (responseObject, error) -> Void in
//            if error != nil {
//                print("\(error)")
//                print("\(responseObject)")
//            }
//        }
//    }
//    
//    // 处理消息（默认动作：点击进入消息详情页）
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        UMFeedback.didReceiveRemoteNotification(userInfo)
//        
//        // 下面这行不确定是否加在这里
//        UMFeedback.sharedInstance().setFeedbackViewController(nil, shouldPush: false)
//    }
    
    
    

}

