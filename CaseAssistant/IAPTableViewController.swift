//
//  IAPViewController.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/6/10.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import UIKit
import StoreKit


class IAPTableViewController: UITableViewController
{
    // MARK: - Variables
    
    var products = [SKProduct]()
    
    var progressHUD: ProgressHUD!
    
    
    // MARK: - ViewController Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressHUD = ProgressHUD(text: "请稍等...")
        self.tableView.addSubview(progressHUD)
        progressHUD.show()
        
        let restoreButton = UIBarButtonItem(title: "Restore",
                                            style: .plain,
                                            target: self,
                                            action: #selector(IAPTableViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(IAPTableViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    
    func reload() {
        products = []
        
        tableView.reloadData()
        
        CaseProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                print(self.products)
                self.tableView.reloadData()
            }
            
//            self.refreshControl?.endRefreshing()
            self.progressHUD.hide()
        }
    }
    
    
    // MARK: - IBActions
    

    // Restore purchases
    func restoreTapped(_ sender: UIButton) {
        print("to restore purchases")
        CaseProducts.store.restorePurchases()
    }
    
    
    func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
    
    
    // MARK: - TableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! IAPProductCell
        let product = products[indexPath.row]
        cell.product = product
        cell.buyButtonHandler = { product in
            CaseProducts.store.buyProduct(product)
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "升级之前最多可以添加\(CaseProducts.maxPatientsForFreeUser)个病例"
    }

}
