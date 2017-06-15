//
//  CaseProducts.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//
//  内购. IAP products

import Foundation


public struct CaseProducts {
    public static let unlimitedPatients = "casenote_unlimited_patients"
    public static let maxPatientsForFreeUser = 5
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [CaseProducts.unlimitedPatients]
    
    public static let store = IAPHelper(productIds: CaseProducts.productIdentifiers)
}


func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}


//// IAP
//static let productIDs: [String] = [
//    "casenote_remove_ads",
//    "casenote_unlimited_patients"
//]
//static let IAPPatientLimitation = 5
//
//static func productIsPurchased(_ productID: String) -> Bool {
//    return UserDefaults.standard.bool(forKey: productID)
//}
//
//static var shouldRemoveADs: Bool {
//    return UserDefaults.standard.bool(forKey: CaseAssistantApp.productIDs[0])
//}
//
//static var shouldUnlockPatientLimitation: Bool {
//    return UserDefaults.standard.bool(forKey: CaseAssistantApp.productIDs[1])
//}
