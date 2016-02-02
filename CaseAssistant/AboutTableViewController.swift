//
//  AboutTableViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/6/6.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        var versionString = "眼科行医手记"
        
        if let version = CaseNoteConstants.appVersion {
            versionString += " v\(version)"
//            if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
//                versionString += " (build \(build))"
//            }
        }
        versionLabel.text = versionString
    }

}
