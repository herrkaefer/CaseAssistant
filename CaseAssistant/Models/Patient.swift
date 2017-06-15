//
//  Patient.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


class Patient: Object {
    
    dynamic var id: String          = "" // primary key
    dynamic var creationDate        = Date()
    dynamic var category: Category!
    dynamic var starred             = false
    dynamic var birthdate           = Date(timeIntervalSince1970: 1)
    let tags                        = List<Tag>()
    /* treatment records */
    let records                     = List<Record>()
    // other string:string items
    let items                       = List<FormItem>()
    
    // ---- End of data defination ----//
    
    /* primary key */
    override static func primaryKey() -> String {
        return "id"
    }
    
    /* computed properties */
    
    // 检查记录array，按检查日期升序排列
    var recordsSortedDescending: [Record] {
        return Array(records.sorted(byKeyPath: "date", ascending: false))
    }
    
    // 检查记录array，按检查日期降序排列
    var recordsSortedAscending: [Record] {
        return Array(records.sorted(byKeyPath: "date", ascending: true))
    }
    
    // 首次就诊时年龄
    var treatmentAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([Calendar.Component.year], from: birthdate, to: firstTreatmentDate)
        return ageComponents.year!
    }
    
    // 患者手术日期。因为可能有多次手术，因此返回Array，按日期升序排列
    var operationDates: [Date] {
        var opDates = [Date]()
        let rs = records.filter("operationPerformed == true").sorted(byKeyPath: "operationDate", ascending: true)
        for r in rs {
            opDates.append(r.operationDate)
        }
        return opDates
    }
    
    // 首次就诊日期
    var firstTreatmentDate: Date {
        if let r = records.sorted(byKeyPath: "date", ascending: true).first {
            return r.date
        } else {
            return creationDate
        }
    }
    
    // 末次就诊日期
    var lastTreatmentDate: Date {
        if let r = records.sorted(byKeyPath: "date", ascending: false).first {
            return r.date
        } else {
            return creationDate
        }
    }
    
    // 患者的所有标签的名称
    var tagNames: [String] {
        let ts = Array(tags)
        return ts.map({$0.name})
    }
    
    // 第一诊断：取diagnosis中第一个标点或换行之前的部分。如果为空，返回nil
    var firstDiagnosis: String? {
        let diagnosis = self.g("diagnosis")
        var firstD = diagnosis
        let punctuations = ["，", "。", " ", "\n", ",", "."]
        if !diagnosis.isEmpty {
            for p in punctuations {
                let fds = diagnosis.components(separatedBy: p)
                //                print("punctuation: \(p), \(fds.first)")
                if fds.first != nil {
                    if !fds.first!.isEmpty && fds.first!.characters.count < firstD.characters.count {
                        firstD = fds.first!
                    }
                }
            }
        }
        return firstD.isEmpty ? nil : firstD
    }
    
    // 患者基本信息的文字报告
    var reportOfBasicInfo: String {
        var re = ""
        let gender = g("gender")
        re += appendedStringItem("\(gender)", punctuationBefore: "", strShouldBeAppended: !gender.isEmpty, punctuationShouldBeAdded: false)
        let tAge = treatmentAge
        re += appendedStringItem("\(tAge)岁", punctuationBefore: "，", strShouldBeAppended: tAge>0, punctuationShouldBeAdded: !re.isEmpty)
        let illDescription = g("illDescription")
        re += appendedStringItem("\(illDescription)", punctuationBefore: "。", strShouldBeAppended: !illDescription.isEmpty, punctuationShouldBeAdded: !re.isEmpty)
        
        let diagnosis = g("diagnosis")
        re += appendedStringItem("▹ 诊断：", punctuationBefore: "\n\n", strShouldBeAppended: !diagnosis.isEmpty, punctuationShouldBeAdded: !re.isEmpty)
        re += appendedStringItem(diagnosis, punctuationBefore: "\n", strShouldBeAppended: !diagnosis.isEmpty, punctuationShouldBeAdded: true)
        
        return re
    }
    
    
    // set item
    func s(_ name: String, value: String) {
        let id = self.id + name
        let item = FormItem.addItem(id, name: name, value: value)
        if items.filter("id == '\(id)'").count == 0 {
            let realm = try! Realm()
            try! realm.write {
                self.items.append(item)
            }
        }
    }
    
    // get item
    func g(_ name: String) -> String {
        let id = self.id + name
        let v = items.filter("id == '\(id)'").first?.value
        if v != nil {
            return v!
        } else {
            return ""
        }
    }
    
    func removeFromDB() {
        
        removeSubObjectsFromDB()
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    func removeSubObjectsFromDB() {
        let realm = try! Realm()
        // remove subobjects asscociated with records
        for r in records {
            r.removeSubOjectsFromDB()
        }
        // delete records
        try! realm.write {
            realm.delete(self.records)
            realm.delete(self.items)
        }
        // remove tags associated with patient. (note: do not delete tag object)
        removeAllTags()
    }
    
    func sCategoryByName(_ categoryName: String) {
        let realm = try! Realm()
        if let c = Category.getCategoryByName(categoryName) {
            try! realm.write {
                self.category = c
            }
        } else {
            let c = Category.addNewCategory(categoryName, isFirst: true)
            try! realm.write {
                self.category = c
            }
        }
    }
    
    func sBirthdate(_ date: Date) {
        let realm = try! Realm()
        try! realm.write {
            self.birthdate = date
        }
    }
    
    func sStarred(_ starred: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.starred = starred
        }
    }
    
    func toggleStar() {
        let realm = try! Realm()
        try! realm.write {
            self.starred = !self.starred
        }
    }
    
    func addRecord() -> Record {
        return Record.addNewRecord(self)
    }
    
    func hasTagByName(_ tagName: String) -> Int? {
        let realm = try! Realm()
        if let tag = realm.object(ofType: Tag.self, forPrimaryKey: tagName) {
            return tags.index(of: tag)
        } else {
            return nil
        }
    }
    
    func addTagByName(_ tagName: String) {
        if hasTagByName(tagName) != nil {
            return
        }
        let tag = Tag.getTagByName(tagName)
        let realm = try! Realm()
        try! realm.write {
            self.tags.append(tag)
        }
    }
    
    func removeTagByName(_ tagName: String) {
        if let i = hasTagByName(tagName) {
            let realm = try! Realm()
            try! realm.write {
                self.tags.remove(objectAtIndex: i)
            }
        }
    }
    
    func removeAllTags() {
        let realm = try! Realm()
        try! realm.write {
            self.tags.removeAll()
        }
    }
    
    
    /* type properties */
    
    // 患者总数
    static var totalNumberOfPatients: Int {
        let realm = try! Realm()
        return realm.objects(Patient.self).count
    }
    
    // 所有星标患者
    static var starredPatients: [Patient] {
        let realm = try! Realm()
        let q = realm.objects(Patient.self).filter("starred == true")
        return Array(q)
    }
    
    // 所有星标患者，按末诊时间降序排列
    static var starredPatientsSortedByLastTreatmentDateDescending: [Patient] {
        let realm = try! Realm()
        let ps = Array(realm.objects(Patient.self).filter("starred == true"))
        return ps.sorted(by: {$0.lastTreatmentDate.compare($1.lastTreatmentDate) == ComparisonResult.orderedDescending})
    }
    
    // 所有星标患者，按末诊时间升序排列
    static var starredPatientsSortedByLastTreatmentDateAscending: [Patient] {
        let realm = try! Realm()
        let ps = Array(realm.objects(Patient.self).filter("starred == true"))
        return ps.sorted(by: {$0.lastTreatmentDate.compare($1.lastTreatmentDate) == ComparisonResult.orderedAscending})
    }
    
    // 所有星标患者，按首诊时间降序排列
    static var starredPatientsSortedByFirstTreatmentDateDescending: [Patient] {
        let realm = try! Realm()
        let ps = Array(realm.objects(Patient.self).filter("starred == true"))
        return ps.sorted(by: {$0.firstTreatmentDate.compare($1.firstTreatmentDate) == ComparisonResult.orderedDescending})
    }
    
    // 所有星标患者，按首诊时间升序排列
    static var starredPatientsSortedByFirstTreatmentDateAscending: [Patient] {
        let realm = try! Realm()
        let ps = Array(realm.objects(Patient.self).filter("starred == true"))
        return ps.sorted(by: {$0.firstTreatmentDate.compare($1.firstTreatmentDate) == ComparisonResult.orderedAscending})
    }
    
    /* type functions */
    
    static func getNewID() -> String {
        return UUID().uuidString
    }
    
    static func addNewPatient(_ forCategory: Category?, starred: Bool?) -> Patient {
        let realm = try! Realm()
        let p = Patient()
        p.id = Patient.getNewID()
        
        if forCategory != nil {
            p.category = forCategory
        } else if let c = Category.getCategoryByName("未分组") { //无指定分类则加到未分组
            p.category = c
        } else { // 没有未分组分类则创建未分组分类
            let c = Category.addNewCategory("未分组", isFirst: true)
            p.category = c
        }
        
        if starred != nil {
            p.starred = starred!
        }
        
        try! realm.write {
            realm.add(p, update: true)
        }
        
        // add form items
        p.s("name", value: "未知")
        p.s("gender", value: "男")
        p.s("profession", value: "")
        p.s("identityCardNo", value: "")
        p.s("phoneNo", value: "")
        p.s("address", value: "")
        p.s("email", value: "")
        p.s("documentNo", value: "")
        p.s("illHistory", value: "")
        p.s("diagnosis", value: "")
        p.s("illDescription", value: "")
        p.s("comment", value: "") // 备注
        p.s("summary", value: "") // 心得
        
        return p
    }
    
}
