//
//  IAPProductTableViewCell.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/6/15.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import StoreKit

class IAPProductCell: UITableViewCell {

    @IBOutlet weak var productTitleLabel: UILabel!
    
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var buyButton: UIButton! {
        didSet {
            buyButton.layer.cornerRadius = 5.0
            buyButton.addTarget(self, action: #selector(IAPProductCell.buyButtonTapped(_:)), for: .touchUpInside)
        }
    }

    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    var buyButtonHandler: ((_ product: SKProduct) -> ())?
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            productTitleLabel?.text = product.localizedTitle
            productDescriptionLabel?.text = product.localizedDescription
            
            if CaseProducts.store.isProductPurchased(product.productIdentifier) {
                productPriceLabel?.text = "[已经购买]"
                buyButton.isHidden = true
            }
            else if IAPHelper.canMakePayments() {
                IAPProductCell.priceFormatter.locale = product.priceLocale
                productPriceLabel?.text = IAPProductCell.priceFormatter.string(from: product.price)
                buyButton.isHidden = false
            }
            else {
                productPriceLabel?.text = "[无法购买]"
                buyButton.isHidden = true
            }
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        productTitleLabel?.text = ""
        productPriceLabel?.text = ""
    }

    
    func buyButtonTapped(_ sender: AnyObject) {
        buyButtonHandler?(product!)
    }
}
