//
//  SettingViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/28.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import iAd

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate
{

    let tableViewCellTitle = [
        "告诉我们如何改进",
        "去App Store鼓励我们",
        "升级到Pro版本",
        "关于"
    ]
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var adBannerView: ADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CaseNoteConstants.shouldRemoveADs {
            canDisplayBannerAds = false
            adBannerView?.removeFromSuperview()
            adBannerView?.delegate = nil
            adBannerView = nil
        } else {
            canDisplayBannerAds = true
            adBannerView?.delegate = self
            adBannerView?.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if CaseNoteConstants.shouldRemoveADs {
            adBannerView?.hidden = true
        }
    }

    // MARK: - ADBannerView Delegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        if CaseNoteConstants.shouldRemoveADs == false {
            println("setting load ad: show ADs")
            adBannerView?.hidden = false
        } else {
            println("setting load ad: no ADs")
        }
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView?.hidden = true
    }
    
    // MARK: - TableView DataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewCellTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("settingCell", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = tableViewCellTitle[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0: // feedback，考虑不用友盟或者自定义界面，自带界面太丑
            
            getDrawer()!.presentViewController(UMFeedback.feedbackModalViewController(), animated: true, completion: nil)
            
        case 1: // rate，以后考虑实现不离开app评分
            UIApplication.sharedApplication().openURL(CaseNoteConstants.rateURL!)
            
        case 2:
            performSegueWithIdentifier("showIAP", sender: self)
            
        case 3:
            performSegueWithIdentifier("showAbout", sender: self)
            
        default:
            break
        }
    }
    
    
    // MARK: - Navigation

    @IBAction func goBackToSettingViewController(segue: UIStoryboardSegue) {
        
    }

}
