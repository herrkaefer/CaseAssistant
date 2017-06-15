//
//  RecordButtonInputTableViewCell.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/5/7.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class RecordButtonInputTableViewCell: UITableViewCell {

    var choiceText: String? {
        didSet {
            choiceButton.setTitle(choiceText, for: UIControlState())
//            checkboxImageView.image = UIImage(named: "checkbox-blank-22")
        }
    }
    
    @IBOutlet weak var choiceButton: UIButton!
//    @IBOutlet weak var checkboxImageView: UIImageView!
}
