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
        versionLabel.text = CaseApp.appName + " v" + CaseApp.version
    }

}
