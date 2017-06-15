//
//  Tag.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift

class Tag: Object {
    dynamic var name = "" // primary key
    let patientsTagged = LinkingObjects(fromType: Patient.self, property: "tags")
    
    // ---- End of data defination ----//
    
    /* primary key */
    override class func primaryKey() -> String {
        return "name"
    }
    
    
//    var patientsTagged: [Patient] {
//        return Array(LinkingObjects(fromType: Patient.self, property: "tags"))
//    }
    
    // 带有tag的患者列表，按末次就诊时间降序排列
    var patientsTaggedSortedByLastTreatmentDateDescending: [Patient] {
        let sortedPatients = patientsTagged.sorted(by: {$0.lastTreatmentDate.compare($1.lastTreatmentDate) == ComparisonResult.orderedDescending})
        return sortedPatients
//        return Array(sortedPatients)
    }
    
    
    // 带有tag的患者列表，按末次就诊时间升序排列
    var patientsTaggedSortedByLastTreatmentDateAscending: [Patient] {
        let sortedPPatients = patientsTagged.sorted(by: {$0.lastTreatmentDate.compare($1.lastTreatmentDate) == ComparisonResult.orderedAscending})
        return sortedPPatients
    }
    
    
    var numberOfPatientsTagged: Int {
        return patientsTagged.count
    }
    
    
    static var numberOfTags: Int {
        let realm = try! Realm()
        return realm.objects(Tag.self).count
    }
    
    
    static var allTagsSortedByNameAscending: [Tag] {
        let realm = try! Realm()
        let ps = realm.objects(Tag.self).sorted(byKeyPath: "name", ascending: true)
        return Array(ps)
    }
    
    
    static var allTagsSortedByNumberOfPatientsDescending: [Tag] {
        let realm = try! Realm()
        let ts = Array(realm.objects(Tag.self))
        return ts.sorted(by: {$0.numberOfPatientsTagged > $1.numberOfPatientsTagged})
    }
    
    
    func removeFromAllPatientsTagged() {
        for p in patientsTagged {
            p.removeTagByName(name)
        }
    }
    
    
    func removeFromDB() {
        if patientsTagged.count > 0 {
            return
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    /* Type functions */
    
    static func addNewTag(_ name: String) -> Tag {
        let tag = Tag()
        tag.name = name
        let realm = try! Realm()
        try! realm.write {
            realm.add(tag, update: true)
        }
        return tag
    }
    
    static func getTagByName(_ name: String) -> Tag {
        let realm = try! Realm()
        if let tag = realm.object(ofType: Tag.self, forPrimaryKey: name) {
            return tag
        } else {
            return Tag.addNewTag(name)
        }
    }
    
    static func tagExistsByName(_ name: String) -> Bool {
        let realm = try! Realm()
        if realm.object(ofType: Tag.self, forPrimaryKey: name) != nil {
            return true
        } else {
            return false
        }
    }
    
    // 删除所有没有被任何患者tag的tag
    static func clearTagsWithZeroPatientsTagged() {
        let realm = try! Realm()
        let ts = realm.objects(Tag.self)
        //        print("clear")
        for t in ts {
            if t.numberOfPatientsTagged == 0 {
                t.removeFromDB()
            }
        }
    }
}
