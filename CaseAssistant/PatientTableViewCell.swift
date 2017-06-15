//
//  PatientTableViewCell.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/20.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class PatientTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateInfoLabel: UILabel!
    @IBOutlet weak var diagnosisLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        cardView.layer.borderWidth = 2.0
//        cardView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5.0
        
        // Add shadow
        cardView.layer.shadowColor = UIColor.darkGray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        cardView.layer.shadowOpacity = 0.3
    }
}
