//
//  IAPProductTableViewCell.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/6/15.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit

class IAPProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productTitleLabel: UILabel!
    
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton! {
        didSet {
            buyButton.layer.cornerRadius = 5.0
        }
    }

}
