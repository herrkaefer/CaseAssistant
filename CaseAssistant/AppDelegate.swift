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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        println(getDocumentsUrl())
        
        // initialize data models
        initData()
        
        // create MMDrawer for side menu
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let settingStoryboard = UIStoryboard(name: "Setting", bundle: nil)
        
        let centerNav = mainStoryboard.instantiateViewControllerWithIdentifier("initNav") as! UINavigationController
        let menuNav = settingStoryboard.instantiateViewControllerWithIdentifier("settingNav") as! UINavigationController
        
        drawer = MMDrawerController(centerViewController: centerNav, leftDrawerViewController: menuNav)
        if drawer != nil {
            // open和close的手势识别在首页的willAppear()和willDisappear()中进行开关设置。这里不设置。
//            drawer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
//            drawer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All
            drawer!.setMaximumLeftDrawerWidth(240.0, animated: true, completion: nil)
            drawer!.setDrawerVisualStateBlock({ (drawerController: MMDrawerController!, drawerSide: MMDrawerSide, percentVisible: CGFloat) -> Void in
                let block = MMDrawerVisualState.slideAndScaleVisualStateBlock()
                block(drawerController, drawerSide, percentVisible)
            })
            
            window!.rootViewController = drawer
            window!.makeKeyAndVisible()
        }


        // change navigation bar appearance
        var navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = uicolorFromHex(0xffffff)
        navigationBarAppearace.barTintColor = CaseNoteConstants.baseColor
        navigationBarAppearace.translucent = false
        
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        // change status bar style
        // first edit info.plist: set View controller-based status bar appearance = NO
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        
        
        
        // 设置友盟分享AppKey
        UMSocialData.setAppKey(CaseNoteConstants.umengAppKey)
        
        // 分享时隐藏未安装的应用
        UMSocialConfig.hiddenNotInstallPlatforms([UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline])
        
        // 新浪微博SSO授权开关
        UMSocialSinaSSOHandler.openNewSinaSSOWithRedirectURL(nil) //"http://sns.whalecloud.com/sina2/callback"
        
        //设置微信AppId、appSecret，分享url
        UMSocialWechatHandler.setWXAppId(CaseNoteConstants.wechatAppID, appSecret: CaseNoteConstants.wechatAppSecret, url: "http://weibo.com/casenote")
        
        // 友盟用户反馈集成
        UMFeedback.setAppkey(CaseNoteConstants.umengAppKey)
        
        // 友盟统计分析集成
        MobClick.startWithAppkey(CaseNoteConstants.umengAppKey, reportPolicy: BATCH, channelId: nil)

//        // 友盟消息推送集成
//        if CaseNoteConstants.deviceVersion >= 8.0 {
//            //register remoteNotification types
//            let action1 = UIMutableUserNotificationAction() //第一按钮
//            action1.identifier = "action1_identifier"
//            action1.title = "Accept"
//            action1.activationMode = UIUserNotificationActivationMode.Foreground//当点击的时候启动程序
//            
//            let action2 = UIMutableUserNotificationAction() //第二按钮
//            action2.identifier = "action2_identifier"
//            action2.title = "Reject"
//            action2.activationMode = UIUserNotificationActivationMode.Background//当点击的时候不启动程序，在后台处理
//
//            action2.authenticationRequired = true //需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
//            action2.destructive = true
//            
//            let categories = UIMutableUserNotificationCategory()
//            categories.identifier = "category1" //这组动作的唯一标示
//            categories.setActions([action1, action2], forContext: UIUserNotificationActionContext.Default)
//
//            let userSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert, categories: NSSet(object: categories) as Set<NSObject>)
//            
//            UMessage.registerRemoteNotificationAndUserNotificationSettings(userSettings)
//            
//        } else // deviceVersion < 8.0
//        {
//            UMessage.registerForRemoteNotificationTypes(UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
//        }
//        
//        UMessage.setLogEnabled(false) // 打开可以查看device token
//        
//        //关闭状态时点击反馈消息进入反馈页
//        if let options = launchOptions {
//            if let notificationDict = options[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
//                UMFeedback.didReceiveRemoteNotification(notificationDict as [NSObject : AnyObject])
//            }
//        }

        return true
    }

    
    
    // 友盟分享系统回调
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return UMSocialSnsService.handleOpenURL(url)
    }
    
    // 友盟分享系统回调
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return UMSocialSnsService.handleOpenURL(url)
    }
    
//    // 设置umeng_feedback alias（注意这里的alias参数和type参数都需要从UMFeedback获取，不能自行更改）
//    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        UMessage.registerDeviceToken(deviceToken)
//        println("umeng message alias is: \(UMFeedback.uuid())")
//        UMessage.addAlias(UMFeedback.uuid(), type: UMFeedback.messageType()) { (responseObject, error) -> Void in
//            if error != nil {
//                println("\(error)")
//                println("\(responseObject)")
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
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

