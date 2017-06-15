//
//  Data.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


////////////////////////////////////////////////////////

struct RecordItem {
    var name: String
    var displayName: String
    var tag: Int
    var basicChoices: [String]
    var hasCustomText: Bool
    var prefix: String
    var suffix: String
    var dataFormat: String
}


//// MARK: - Helper functions for Default Data
//
func initData() {

//    //    let realmPath = Realm.defaultPath
//    let realmPath = Realm.Configuration.defaultConfiguration.fileURL
//    // 如果Documents中有default.realm文件，执行migration
//    if FileManager.default.fileExists(atPath: (realmPath?.absoluteString)!) {
//        print("Realm file exists. No need to load default data")
//        performMigration()
//    } else { // 否则从Bundle中copy default.realm文件到Documents中
//        print("Load default data")
//        if loadDefaultDataFromBundle() == true {
//            performMigration()
//        } else {
//            generateDemoData() // copy失败则程序生成
//        }
//    }
//    
    let _ = Spy.addNewSpy() // this will record the lastest installation version to the spy object

    Record.generateHelperDictionaries()
}
//
//
//func performMigration() {
//    
//    let _: MigrationBlock = { migration, oldSchemaVersion in
//        print("migration begin")
//        if oldSchemaVersion < 1 {
//        }
//        print("Migration complete.")
//    }
//    
////    setDefaultRealmSchemaVersion(1, migrationBlock)
//}
//
//
//// return true only if default.realm is successfully copied
//func loadDefaultDataFromBundle() -> Bool {
//    let result = true
//    
//    // copy over data files from bundle
////    let realmPath = Realm.defaultPath
//    let realmPath = Realm.Configuration.defaultConfiguration.fileURL
//    let defaultParentPath = realmPath?.deletingLastPathComponent()
//    let pmPath = defaultParentPath?.appendingPathComponent("photomemos")
//    print("Realm default path: \(realmPath!)")
//    print("photomemos folder path: \(pmPath!)")
//    
//    // copy default.realm
//    if let dataPath = bundlePath("default.realm") {
//        print("dataPath in bundle: \(dataPath)")
//        
//        if FileManager.default.fileExists(atPath: (realmPath?.absoluteString)!) {
//            let realm = try! Realm()
//            print("target exists. to remove it. spy count: \(realm.objects(Spy.self).count)")
//            try! FileManager.default.removeItem(atPath: (realmPath?.absoluteString)!)
//            //            if (error != nil) {
////                print("remove error!")
////                print(error!.description)
////            }
//        }
//        
//        do {
//            try FileManager.default.copyItem(atPath: dataPath, toPath: (realmPath?.absoluteString)!)
//        } catch {
//            print("copy default.realm error!")
//            print(error)
//            return false
//        }
//        
//    }
//    
//    // copy photomemos folder
//    if let dataPath = bundlePath("photomemos") {
//        print("dataPath in bundle: \(dataPath)")
//        
//        if FileManager.default.fileExists(atPath: (pmPath?.absoluteString)!) {
//            let realm = try! Realm()
//            print("target exists. to remove it. spy count: \(realm.objects(Spy.self).count)")
//            do {
//                try FileManager.default.removeItem(atPath: (pmPath?.absoluteString)!)
//            } catch {
//                print("remove photomemos folder error!")
//                print(error)
//            }
//        }
//        
//        do {
//            try FileManager.default.copyItem(atPath: dataPath, toPath: (pmPath?.absoluteString)!)
//        } catch {
//            print("failed to copy photomemos from bundle")
//            print(error)
//            return false
//        }
//    }
//    
//    return result
//}
//
//
//func bundlePath(_ path: String) -> String? {
//    return Bundle.main.resourcePath?.appending(path)
//}
//
//
//func generateDemoData() {
//    // add some demo categories
//    //        let defaultCategoryNames = ["未分组", "角膜及眼表疾病", "晶体病", "青光眼", "免疫/葡萄膜炎", "玻璃体视网膜疾病", "斜弱视与小儿眼病", "视光", "眼外伤", "眼整形", "眼眶病", "神经眼科", "眼肿瘤", "与眼部相关的全身疾病"]
////    let defaultCategoryNames = ["未分组", "结膜炎", "结膜增生", "角膜炎", "角膜变性", "结膜及角膜肿物"]
//    let defaultCategoryNames = ["未分组"]
//    let defaultPatientNames = ["张某"]
//    
//    var categories = [Category]()
//    for i in 0..<defaultCategoryNames.count {
//        let c = Category.addNewCategory(defaultCategoryNames[i], isFirst: false)
//        categories.append(c)
//    }
//    
//    // add demo patients
//    for i in 0..<defaultPatientNames.count {
//        let p = Patient.addNewPatient(categories[i], starred: true)
//        p.s("name", value: defaultPatientNames[i])
//        p.s("diagnosis", value: "角膜变性")
//        p.addTagByName("角膜变性")
//        p.addTagByName("基因")
//        
//        let rDates = generateRandomDateArrayWithinDaysBeforeToday(6, days: 60)
//        // add some demo records to patient
//        for ri in 0..<6 {
//            let r = p.addRecord()
//            r.sDate(rDates[ri])
//            r.s("rShili", value: "\(Float(arc4random_uniform(15))/10.0)")
//            r.s("lShili", value: "\(Float(arc4random_uniform(15))/10.0)")
//            r.s("rJiaozhengshili", value: "\(Float(arc4random_uniform(15))/10.0)")
//            r.s("lJiaozhengshili", value: "\(Float(arc4random_uniform(15))/10.0)")
//            r.s("rYanya", value: "\((Float(arc4random_uniform(80))+20.0)/10.0)")
//            r.s("lYanya", value: "\((Float(arc4random_uniform(80))+20.0)/10.0)")
//            if ri == 2 {
//                r.sOperationPerformed(true)
//                r.sOperationDate(r.date)
//            }
//        }
//    }
//    print("default data generated.")
//}

