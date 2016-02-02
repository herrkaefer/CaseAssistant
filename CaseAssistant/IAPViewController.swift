//
//  IAPViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/6/10.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import StoreKit

//protocol IAPurchaceViewControllerDelegate {
//    
//    func didBuyUnlimitedPatients()
//    
//}

class IAPViewController: UIViewController, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
    // MARK: - Variables
    
    var availableProducts = [SKProduct]()
    var operatedProductID: String?
    
    var progressHUD: ProgressHUD!
    
//    var transactionInProgress = false
//    var delegate: IAPurchaceViewControllerDelegate!
    
    // MARK: - Outlets
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restorePurchasesButton: UIButton! {
        didSet {
            restorePurchasesButton.layer.cornerRadius = 5.0
        }
    }
    
    // MARK: - ViewController Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressHUD = ProgressHUD(text: "请稍等...")
        self.view.addSubview(progressHUD)
        progressHUD.show()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        fetchProductInformationForIds(CaseNoteConstants.productIDs)
        infoLabel.text = ""
        restorePurchasesButton.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }

    
    // MARK: - IBActions
    
    // Requesting payment of selected product
    @IBAction func buyProductButtonPressed(sender: UIButton) {
        var productToBuy = availableProducts[sender.tag]
        println("Sending the Payment Request of product \(productToBuy.localizedTitle)")
        
        if SKPaymentQueue.canMakePayments() {
            operatedProductID = productToBuy.productIdentifier
            var payment = SKPayment(product: productToBuy)
            SKPaymentQueue.defaultQueue().addPayment(payment)
            updateUIForTransactionBegin("购买中...")
        } else {
            println("Cannot perform In App Purchases.")
            updateUIForTransactionEnd("抱歉，无法购买")
        }
    }

    // Restore purchases
    @IBAction func restorePurchasesButtonPressed(sender: UIButton) {
        println("to restore purchases")
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
            updateUIForTransactionBegin("恢复中...")
        } else {
            println("Cannot perform In App Purchases.")
            updateUIForTransactionEnd("抱歉，恢复购买无法操作")
        }
    }
    
    // MARK: - Helpers
    
    // retrieving product information
    func fetchProductInformationForIds(productIDs: [String]) {
        println("Retrieving product information")
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<NSObject>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            println("Cannot perform In App Purchases.")
        }
    }
    
    // save purchased product to NSUserDefaults
    func setProductPurchased(productID: String) {
        println("saving product \(productID)")
        let storage = NSUserDefaults.standardUserDefaults()
        storage.setBool(true, forKey: productID)
        storage.synchronize()
        // test
        println("product \(productID) saved. test: ")
        switch productID {
        case CaseNoteConstants.productIDs[0]:
            println("\(CaseNoteConstants.shouldRemoveADs)")
        case CaseNoteConstants.productIDs[1]:
            println("\(CaseNoteConstants.shouldUnlockPatientLimitation)")
        default:
            break
        }
    }
    
    func updateUIForTransactionBegin(progressText: String) {
        infoLabel.text = ""
        progressHUD.changeText(progressText)
        progressHUD.show()
        view.userInteractionEnabled = false
    }
    
    func updateUIForTransactionEnd(info: String) {
        infoLabel.text = info
        progressHUD.hide()
        view.userInteractionEnabled = true
    }
    
    // MARK: - Delegates
    
    // SKProductsRequestDelegate
    // 得到内购产品信息
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("got response for product request from Apple")
        if response.products.count > 0 {
            availableProducts.removeAll()
            availableProducts.extend(response.products as! [SKProduct])
            tableView.reloadData()
            updateUIForTransactionEnd("")
            restorePurchasesButton.hidden = false
        } else {
            println("There are no products in response.")
            updateUIForTransactionBegin("不好意思，目前没有可购买的产品")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            println("ERROR: Invalid Products: "+response.invalidProductIdentifiers.description)
        }
    }
    
    // SKPaymentTransactionObserver
    // 得到购买结果
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("Received Payment Transaction Response from Apple")

        for transaction in transactions as! [SKPaymentTransaction] {
            
            println("processing transaction of product: \(transaction.payment.productIdentifier)")
            
            switch transaction.transactionState {
            case .Purchased:
                println("Transaction completed successfully.")
                
                // save purchase to NSUserDefaults
                if operatedProductID != nil {
                    setProductPurchased(operatedProductID!)
                    operatedProductID = nil
                }
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                updateUIForTransactionEnd("购买成功，谢谢！")
                
            case .Restored:
                
                let productID = transaction.originalTransaction.payment.productIdentifier
                println("Transaction restored for product id: \(productID)")
                
                // save purchase
                setProductPurchased(productID)
                operatedProductID = nil
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                updateUIForTransactionEnd("购买已恢复")
                
                
            case .Failed:
                println("Transaction Failed.");
                
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                updateUIForTransactionEnd("购买失败了:-(")
                operatedProductID = nil
                
            default:
                updateUIForTransactionEnd("")
                println(transaction.transactionState.rawValue)
            }
        }
        tableView.reloadData()
    }
    
    // observer for restore purchases
//    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
//        println("paymentQueueRestoreCompletedTransactionsFinished: transaction restored")
//        
//        var purchasedItemsIDS = []
//        for transaction in queue.transactions {
//            var t = transaction as! SKPaymentTransaction
//            let productID = t.payment.productIdentifier
//            println("product id: \(productID)")
//            switch productID {
//            case productIDs[0]:
//                println("remove ads")
////                removeAds()
//            case productIDs[1]:
//                println("unlock patient limitation")
//                // ...
//            default:
//                println("IAP not setup")
//            }
//        }
//    }
    
    
    // MARK: - TableView Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return availableProducts.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as! IAPProductTableViewCell
        let product = availableProducts[indexPath.section]
        
        cell.productTitleLabel.text = product.localizedTitle
        cell.productDescriptionLabel.text = product.localizedDescription
        
        cell.buyButton.tag = indexPath.section
        if CaseNoteConstants.productIsPurchased(product.productIdentifier) {
            cell.productPriceLabel.text = ""
            cell.buyButton.setTitle("已购买", forState: .Normal)
            cell.buyButton.backgroundColor = UIColor.darkGrayColor()
            cell.buyButton.enabled = false
        } else {
            cell.productPriceLabel.text = " ¥\(product.price) "
            cell.buyButton.setTitle("购买", forState: .Normal)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "升级之前您最多可以添加\(CaseNoteConstants.IAPPatientLimitation)个患者"
        } else {
            return ""
        }
    }

}
