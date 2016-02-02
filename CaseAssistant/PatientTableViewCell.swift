//
//  PatientTableViewCell.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/20.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateInfoLabel: UILabel!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        contentView.layer.borderColor = UIColor.greenColor().CGColor
//        contentView.layer.borderColor = CaseNoteConstants.baseColor.CGColor
//        contentView.layer.borderColor = UIColor(red: 42.0, green: 180.0, blue: 103.0, alpha: 1.0).CGColor
//        contentView.layer.borderWidth = 2.0
        
//        contentView.layer.cornerRadius = 20.0
//        contentView.layer.masksToBounds = true
        
    }
}
