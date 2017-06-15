//
//  Category.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    dynamic var id: String = "" // primary key
    dynamic var name = "未分组" // keep unique
    dynamic var order: Int = 0 // displaying position
    
    // ---- End of data defination ----//
    
    /* Primary key */
    override class func primaryKey() -> String {
        return "id"
    }
    
    /* indexed properties */
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    /* Computed properties */
    
    var patients: Results<Patient> {
        let realm = try! Realm()
        return realm.objects(Patient.self).filter("category == %@", self)
    }
    
    
    var numberOfPatients: Int {
        return patients.count
    }

    
    // 患者列表，按末次就诊时间降序排列
    var patientsSortedByLastTreatmentDateDescending: [Patient] {
        return patients.sorted(by: {$0.lastTreatmentDate.compare($1.lastTreatmentDate) == ComparisonResult.orderedDescending})
    }
    
    
    // 患者列表，按首诊时间升序排列
    var patientsSortedByFirstTreatmentDateAscending: [Patient] {
        return patients.sorted(by: {$0.firstTreatmentDate.compare($1.firstTreatmentDate) == ComparisonResult.orderedAscending})
    }
    
    
    /* member functions */
    
    func removeFromDB() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    
    func updateOrder(_ newOrder: Int) {
        let realm = try! Realm()
        let smallPos = min(order, newOrder)
        let bigPos = max(order, newOrder)
        //        print("smallPos: \(smallPos)")
        //        print("bigPos: \(bigPos)")
        let q = realm.objects(Category.self).filter("order >= \(smallPos) AND order <= \(bigPos) AND name != '\(name)'")
        //        print(q)
        //        print(q.count)
        let deltaPos = newOrder < order ? 1 : -1
        //        print("deltaPos: \(deltaPos)")
        
        try! realm.write {
            for c in q {
                //                print("update: \(c.name) \(c.order)->\(c.order+deltaPos)")
                c.order += deltaPos
            }
            self.order = newOrder
        }
    }
    
    
    func rename(_ newName: String) -> Bool {
        // 不允许重名
        if Category.getCategoryByName(newName) != nil {
            return false
        }
        
        let realm = try! Realm()
        try! realm.write {
            self.name = newName
        }
        return true
    }
    
    
    /* type properties */
    
    static var allCategories: [Category] {
        let realm = try! Realm()
        let cs = realm.objects(Category.self).sorted(byKeyPath: "order", ascending: true)
        return Array(cs)
    }
    
    /* Type functions */
    
    static func getNewID() -> String {
        return UUID().uuidString
    }
    
    static func addNewCategory(_ name: String, isFirst: Bool) -> Category {
        // name存在
        if let c = getCategoryByName(name) {
            return c
        }
        
        let realm = try! Realm()
        let c = Category()
        c.id = Category.getNewID()
        c.name = name
        let q = realm.objects(Category.self).sorted(byKeyPath: "order", ascending: true)
        if q.count > 0 {
            if isFirst == true {
                c.order = q.first!.order - 1 // place at first
            } else {
                c.order = q.last!.order + 1 // place at last
            }
        } else {
            c.order = 0
        }
        // save to realm
        try! realm.write {
            realm.add(c, update: true)
        }
        return c
    }
    
    static func getCategoryByName(_ name: String) -> Category? {
        let realm = try! Realm()
        let q = realm.objects(Category.self).filter("name == '\(name)'")
        return q.first
    }
    
}

