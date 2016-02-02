//
//  Data.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 15/4/22.
//  Copyright (c) 2015年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift

// Global constants & variables
struct CaseNoteConstants {
    // App ID
    static let appID =
    // 友盟
    static let umengAppKey =
    static let umengAppSecret =
    // 微博
    static let weiboAppKey =
    static let weiboAppSecret =
    // 微信
    static let wechatAppID =
    static let wechatAppSecret =
    
    // colors
    static let baseColor = uicolorFromHex(0x2AB467) //(0x44A3CE)
    static let backgroundColor = uicolorFromHex(0xF8F3EC)
    static let starredColor = uicolorFromHex(0xFFC800)
    static let borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    
    // IAP
    static let productIDs: [String] = [
        "casenote_remove_ads",
        "casenote_unlimited_patients"
    ]
    static let IAPPatientLimitation = 59
    
    static func productIsPurchased(productID: String) -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(productID)
    }
    
    static var shouldRemoveADs: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(CaseNoteConstants.productIDs[0])
    }
    
    static var shouldUnlockPatientLimitation: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(CaseNoteConstants.productIDs[1])
    }

    // rate URL in App Store
    static var rateURL: NSURL? {
        return NSURL(string: "itms-apps://itunes.apple.com/app/id" + CaseNoteConstants.appID)
    }
    
    static var deviceVersion: Float {
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue
    }
    
    static var appVersion: String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var appBuild: String? {
        return NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String
    }
}


// save (name: String, value: String) pair. Note: name is not unique, id is.
class FormItem: Object {
    dynamic var id: String = ""
    dynamic var name = ""
    dynamic var value = "" // empty means nil
//    dynamic var isNil = false
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    static func addItem(id: String, name: String, value: String) -> FormItem {
        let item = FormItem()
        item.id = id
        item.name = name
        item.value = value
        
        // save
        let realm = Realm()
        realm.write {
            realm.add(item, update: true)
        }
        return item
    }
    
    static func getValueById(id: String) -> String? {
        if let q = Realm().objectForPrimaryKey(FormItem.self, key: id) {
            return q.value
        } else {
            return nil
        }
    }
}


class Patient: Object {
    
    dynamic var id: String          = "" // primary key
    dynamic var creationDate        = NSDate()
    dynamic var category: Category!
    dynamic var starred             = false
    dynamic var birthdate           = NSDate(timeIntervalSince1970: 1)
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
            return Array(records.sorted("date", ascending: false))
    }
    
    // 检查记录array，按检查日期降序排列
    var recordsSortedAscending: [Record] {
        return Array(records.sorted("date", ascending: true))
    }
    
    // 首次就诊时年龄
    var treatmentAge: Int {
        let ageComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: birthdate, toDate: firstTreatmentDate, options: nil)
        return ageComponents.year
    }
    
    // 患者手术日期。因为可能有多次手术，因此返回Array，按日期升序排列
    var operationDates: [NSDate] {
        var opDates = [NSDate]()
        let rs = records.filter("operationPerformed == true").sorted("operationDate", ascending: true)
        for r in rs {
            opDates.append(r.operationDate)
        }
        return opDates
    }
    
    // 首次就诊日期
    var firstTreatmentDate: NSDate {
        if let r = records.sorted("date", ascending: true).first {
            return r.date
        } else {
            return creationDate
        }
    }
    
    // 末次就诊日期
    var lastTreatmentDate: NSDate {
        if let r = records.sorted("date", ascending: false).first {
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
                let fds = diagnosis.componentsSeparatedByString(p)
                //                println("punctuation: \(p), \(fds.first)")
                if fds.first != nil {
                    if !fds.first!.isEmpty && count(fds.first!) < count(firstD) {
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
        re += appendedStringItem("\(gender)", "", !gender.isEmpty, false)
        let tAge = treatmentAge
        re += appendedStringItem("\(tAge)岁", "，", tAge>0, !re.isEmpty)
        let illDescription = g("illDescription")
        re += appendedStringItem("\(illDescription)", "。", !illDescription.isEmpty, !re.isEmpty)
        
        let diagnosis = g("diagnosis")
        re += appendedStringItem("▹ 诊断：", "\n\n", !diagnosis.isEmpty, !re.isEmpty)
        re += appendedStringItem(diagnosis, "\n", !diagnosis.isEmpty, true)
        
        return re
    }

    
    // set item
    func s(name: String, value: String) {
        let id = self.id + name
        let item = FormItem.addItem(id, name: name, value: value)
        if items.filter("id == '\(id)'").count == 0 {
            let realm = Realm()
            realm.write {
                self.items.append(item)
            }
        }
    }
    
    // get item
    func g(name: String) -> String {
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
        
        let realm = Realm()
        realm.write {
            realm.delete(self)
        }
    }
    
    func removeSubObjectsFromDB() {
        let realm = Realm()
        // remove subobjects asscociated with records
        for r in records {
            r.removeSubOjectsFromDB()
        }
        // delete records
        realm.write {
            realm.delete(self.records)
            realm.delete(self.items)
        }
        // remove tags associated with patient. (note: do not delete tag object)
        removeAllTags()
    }
    
    func sCategoryByName(categoryName: String) {
        let c = Category.getCategoryByName(categoryName)
        let realm = Realm()
        if let c = Category.getCategoryByName(categoryName) {
            realm.write {
                self.category = c
            }
        } else {
            let c = Category.addNewCategory(categoryName, isFirst: true)
            realm.write {
                self.category = c
            }
        }
    }
    
    func sBirthdate(date: NSDate) {
        let realm = Realm()
        realm.write {
            self.birthdate = date
        }
    }
    
    func sStarred(starred: Bool) {
        let realm = Realm()
        realm.write {
            self.starred = starred
        }
    }
    
    func toggleStar() {
        let realm = Realm()
        realm.write {
            self.starred = !self.starred
        }
    }
    
    func addRecord() -> Record {
        return Record.addNewRecord(self)
    }
    
    func hasTagByName(tagName: String) -> Int? {
        if let tag = Realm().objectForPrimaryKey(Tag.self, key: tagName) {
            return tags.indexOf(tag)
        } else {
            return nil
        }
    }
    
    func addTagByName(tagName: String) {
        if hasTagByName(tagName) != nil {
            return
        }
        var tag = Tag.getTagByName(tagName)
        let realm = Realm()
        realm.write {
            self.tags.append(tag)
        }
    }
    
    func removeTagByName(tagName: String) {
        if let i = hasTagByName(tagName) {
            let realm = Realm()
            realm.write {
                self.tags.removeAtIndex(i)
            }
        }
    }
    
    func removeAllTags() {
        let realm = Realm()
        realm.write {
            self.tags.removeAll()
        }
    }

    
    /* type properties */
    
    // 患者总数
    static var totalNumberOfPatients: Int {
        return Realm().objects(Patient).count
    }
    
    // 所有星标患者
    static var starredPatients: [Patient] {
        let q = Realm().objects(Patient).filter("starred == true")
        return Array(q)
    }
    
    // 所有星标患者，按末诊时间降序排列
    static var starredPatientsSortedByLastTreatmentDateDescending: [Patient] {
        let ps = Array(Realm().objects(Patient).filter("starred == true"))
        return ps.sorted({$0.lastTreatmentDate.compare($1.lastTreatmentDate) == NSComparisonResult.OrderedDescending})
    }
    
    // 所有星标患者，按末诊时间升序排列
    static var starredPatientsSortedByLastTreatmentDateAscending: [Patient] {
        let ps = Array(Realm().objects(Patient).filter("starred == true"))
        return ps.sorted({$0.lastTreatmentDate.compare($1.lastTreatmentDate) == NSComparisonResult.OrderedAscending})
    }
    
    // 所有星标患者，按首诊时间降序排列
    static var starredPatientsSortedByFirstTreatmentDateDescending: [Patient] {
        let ps = Array(Realm().objects(Patient).filter("starred == true"))
        return ps.sorted({$0.firstTreatmentDate.compare($1.firstTreatmentDate) == NSComparisonResult.OrderedDescending})
    }
    
    // 所有星标患者，按首诊时间升序排列
    static var starredPatientsSortedByFirstTreatmentDateAscending: [Patient] {
        let ps = Array(Realm().objects(Patient).filter("starred == true"))
        return ps.sorted({$0.firstTreatmentDate.compare($1.firstTreatmentDate) == NSComparisonResult.OrderedAscending})
    }
    
    /* type functions */
    
    static func getNewID() -> String {
        return NSUUID().UUIDString
    }
    
    static func addNewPatient(forCategory: Category?, starred: Bool?) -> Patient {
        let realm = Realm()
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
        
        realm.write {
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

class Record: Object {
    
    dynamic var id: String          = "" // primary key
    dynamic var date                = NSDate()
    let         photoMemos          = List<PhotoMemo>()
    let         voiceMemos          = List<VoiceMemo>()
    dynamic var operationPerformed  = false
    dynamic var operationDate       = NSDate()
    let         items               = List<FormItem>() // all string items
    
    // ---- End of data defination ----//
    
    /* primary key */
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    /* computed properties */
    
    var owner: Patient {
        return linkingObjects(Patient.self, forProperty: "records").first!
    }
    
    // 距离首诊的天数
    var daysAfterFirstTreatment: Int {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitDay, fromDate: owner.firstTreatmentDate, toDate: date, options: nil)
        return components.day
    }
    
    // 距离上次手术的天数。如果没有手术过，返回nil
    var daysAfterLastOperation: Int? {
        var days: Int? = nil
        for opDate in owner.operationDates {
            let d = numberOfDaysBetweenTwoDates(opDate, date)
            if d >= 0 {
                days = d
            } else {
                break
            }
        }
        return days
    }
    
    var photoMemosSortedByCreationDateAscending: [PhotoMemo] {
        return Array(photoMemos.sorted("creationDate", ascending: true))
    }
    
    var photoMemosSortedByCreationDateDescending: [PhotoMemo] {
        return Array(photoMemos.sorted("creationDate", ascending: false))
    }
    
    var voiceMemosSortedByCreationDateAscending: [VoiceMemo] {
        return Array(voiceMemos.sorted("creationDate", ascending: true))
    }
    
    var voiceMemosSortedByCreationDateDescending: [VoiceMemo] {
        return Array(voiceMemos.sorted("creationDate", ascending: false))
    }
    
    // 检查报告
    var report: String {
        
        // 病情描述
        let conditionDescription = g("conditionDescription")
        // 药物治疗
        let dosage = g("dosage")
        // 手术名称
        let operationName = g("operationName")
        
        /* 眼科检查 */
        
        let lShili = g("lShili")
        let rShili = g("rShili")
        let lJiaozhengshili = g("lJiaozhengshili")
        let rJiaozhengshili = g("rJiaozhengshili")
        let lJiaozhengshilizhujing = g("lJiaozhengshilizhujing")
        let rJiaozhengshilizhujing = g("rJiaozhengshilizhujing")
        let lJiaozhengshililengjing = g("lJiaozhengshililengjing")
        let rJiaozhengshililengjing = g("rJiaozhengshililengjing")
        let lJiaozhengshilizhouwei = g("lJiaozhengshilizhouwei")
        let rJiaozhengshilizhouwei = g("rJiaozhengshilizhouwei")
        let lYanya = g("lYanya")
        let rYanya = g("rYanya")
        let lYanjian = g("lYanjian")
        let rYanjian = g("rYanjian")
        let lJiemo = g("lJiemo")
        let rJiemo = g("rJiemo")
        let lJiaomo = g("lJiaomo")
        let rJiaomo = g("rJiaomo")
        let lZhoubianshendu = g("lZhoubianshendu")
        let rZhoubianshendu = g("rZhoubianshendu")
        let lFangshan = g("lFangshan")
        let rFangshan = g("rFangshan")
        let lFangshuixibao = g("lFangshuixibao")
        let rFangshuixibao = g("rFangshuixibao")
        let lHongmo = g("lHongmo")
        let rHongmo = g("rHongmo")
        let lTongkong = g("lTongkong")
        let rTongkong = g("rTongkong")
        let lTongkongzhijing = g("lTongkongzhijing")
        let rTongkongzhijing = g("rTongkongzhijing")
        let lDuiguangfanshe = g("lDuiguangfanshe")
        let rDuiguangfanshe = g("rDuiguangfanshe")
        let lJingzhuangti = g("lJingzhuangti")
        let rJingzhuangti = g("rJingzhuangti")
        let lJingzhuangtihe = g("lJingzhuangtihe")
        let rJingzhuangtihe = g("rJingzhuangtihe")
        let lHounangxia = g("lHounangxia")
        let rHounangxia = g("rHounangxia")
        let lBoliti = g("lBoliti")
        let rBoliti = g("rBoliti")
        let lSantong = g("lSantong")
        let rSantong = g("rSantong")
        let lShiwangmo = g("lShiwangmo")
        let rShiwangmo = g("rShiwangmo")
        let lYanwei = g("lYanwei")
        let rYanwei = g("rYanwei")
        let lYanjijiancha = g("lYanjijiancha")
        let rYanjijiancha = g("rYanjijiancha")
        let lYanqiudaxiao = g("lYanqiudaxiao")
        let rYanqiudaxiao = g("rYanqiudaxiao")
        let lYanqiutuchu = g("lYanqiutuchu")
        let rYanqiutuchu = g("rYanqiutuchu")
        let lYanqiuaoxian = g("lYanqiuaoxian")
        let rYanqiuaoxian = g("rYanqiuaoxian")
        let comment = g("comment")
        let preliminaryDiagnosis = g("preliminaryDiagnosis")
        
        
        var re = ""
        
        var re1 = ""
        re1 += appendedStringItem("视力：", "", !rShili.isEmpty || !lShili.isEmpty, false)
        re1 += appendedStringItem("右"+rShili, "", !rShili.isEmpty, false)
        re1 += appendedStringItem("左"+lShili, "，", !rShili.isEmpty, !re1.isEmpty)
        re1 += appendedStringItem("验光矫正：", "；", !rJiaozhengshili.isEmpty || !lJiaozhengshili.isEmpty, !re1.isEmpty)
        
        if !rJiaozhengshili.isEmpty {
            re1 += appendedStringItem("右", "", true, false)
            re1 += appendedStringItem(rJiaozhengshilizhujing+"DS", "+", !rJiaozhengshilizhujing.isEmpty, (rJiaozhengshilizhujing as NSString).floatValue > 0 && !rJiaozhengshilizhujing.beginsWith("+"))
            re1 += appendedStringItem("/", "", !rJiaozhengshilizhujing.isEmpty && !rJiaozhengshililengjing.isEmpty, false)
            re1 += appendedStringItem(rJiaozhengshililengjing+"DC", "+", !rJiaozhengshililengjing.isEmpty, (rJiaozhengshililengjing as NSString).floatValue > 0 && !rJiaozhengshililengjing.beginsWith("+"))
            re1 += appendedStringItem("×"+rJiaozhengshilizhouwei+"°", "", !rJiaozhengshilizhouwei.isEmpty, false)
            re1 += appendedStringItem(rJiaozhengshili, "=", true, !rJiaozhengshilizhujing.isEmpty || !rJiaozhengshililengjing.isEmpty)
        }
        if !lJiaozhengshili.isEmpty {
            re1 += appendedStringItem("左", "，", true, true)
            re1 += appendedStringItem(lJiaozhengshilizhujing+"DS", "+", !lJiaozhengshilizhujing.isEmpty, (lJiaozhengshilizhujing as NSString).floatValue > 0 && !lJiaozhengshilizhujing.beginsWith("+"))
            re1 += appendedStringItem("/", "", !lJiaozhengshilizhujing.isEmpty && !lJiaozhengshililengjing.isEmpty, false)
            re1 += appendedStringItem(lJiaozhengshililengjing+"DC", "+", !lJiaozhengshililengjing.isEmpty, (lJiaozhengshililengjing as NSString).floatValue > 0 && !lJiaozhengshililengjing.beginsWith("+"))
            re1 += appendedStringItem("×"+lJiaozhengshilizhouwei+"°", "", !lJiaozhengshilizhouwei.isEmpty, false)
            re1 += appendedStringItem(lJiaozhengshili, "=", true, !lJiaozhengshilizhujing.isEmpty || !lJiaozhengshililengjing.isEmpty)
        }
        
        re1 += appendedStringItem("眼压：", "；", !rYanya.isEmpty || !lYanya.isEmpty, !re1.isEmpty)
        re1 += appendedStringItem("右"+rYanya+" mmHg", "", !rYanya.isEmpty, false)
        re1 += appendedStringItem("左"+lYanya+" mmHg", "，", !rYanya.isEmpty, !rYanya.isEmpty)
        
        // 右眼
        var re2 = ""
        re2 += appendedStringItem("眼睑："+rYanjian, "", !rYanjian.isEmpty, false)
        re2 += appendedStringItem("结膜："+rJiemo, "，", !rJiemo.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("角膜："+rJiaomo, "，", !rJiaomo.isEmpty, !re2.isEmpty)
        
        re2 += appendedStringItem("前房", "，", !rZhoubianshendu.isEmpty || !rFangshan.isEmpty || !rFangshuixibao.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("周边深度："+rZhoubianshendu, "", !rZhoubianshendu.isEmpty, false)
        re2 += appendedStringItem("房闪："+rFangshan, "，", !rFangshan.isEmpty, !rZhoubianshendu.isEmpty)
        re2 += appendedStringItem("房水细胞："+rFangshuixibao, "，", !rFangshuixibao.isEmpty, !rZhoubianshendu.isEmpty || !rFangshan.isEmpty)
        
        re2 += appendedStringItem("虹膜："+rHongmo, "，", !rHongmo.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("瞳孔", "，", !rTongkong.isEmpty || !rTongkongzhijing.isEmpty || !rDuiguangfanshe.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem(rTongkong, "", !rTongkong.isEmpty, false)
        re2 += appendedStringItem("直径："+rTongkongzhijing+" mm", "，", !rTongkongzhijing.isEmpty, !rTongkong.isEmpty)
        re2 += appendedStringItem("对光反射："+rDuiguangfanshe, "，", !rDuiguangfanshe.isEmpty, !rTongkong.isEmpty || !rTongkongzhijing.isEmpty)
        re2 += appendedStringItem("晶状体：", "，", !rJingzhuangti.isEmpty || !rJingzhuangtihe.isEmpty || !rHounangxia.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem(rJingzhuangti, "", !rJingzhuangti.isEmpty, false)
        re2 += appendedStringItem("核："+rJingzhuangtihe, "，", !rJingzhuangtihe.isEmpty, !rJingzhuangti.isEmpty)
        re2 += appendedStringItem("后囊下："+rHounangxia, "，", !rHounangxia.isEmpty, !rJingzhuangti.isEmpty || !rJingzhuangtihe.isEmpty)
        re2 += appendedStringItem("玻璃体："+rBoliti, "，", !rBoliti.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("散瞳："+rSantong, "，", !rSantong.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("视网膜："+rShiwangmo, "，", !rShiwangmo.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("眼位："+rYanwei, "，", !rYanwei.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("眼肌检查："+rYanjijiancha, "，", !rYanjijiancha.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("眼球大小："+rYanqiudaxiao, "，", !rYanqiudaxiao.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("眼球突出："+rYanqiutuchu, "，", !rYanqiutuchu.isEmpty, !re2.isEmpty)
        re2 += appendedStringItem("眼球凹陷："+rYanqiuaoxian, "，", !rYanqiuaoxian.isEmpty, !re2.isEmpty)
        
        // 左眼
        var re3 = ""
        re3 += appendedStringItem("眼睑："+lYanjian, "", !lYanjian.isEmpty, false)
        re3 += appendedStringItem("结膜："+lJiemo, "，", !lJiemo.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("角膜："+lJiaomo, "，", !lJiaomo.isEmpty, !re3.isEmpty)
        
        re3 += appendedStringItem("前房", "，", !lZhoubianshendu.isEmpty || !lFangshan.isEmpty || !lFangshuixibao.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("周边深度："+lZhoubianshendu, "", !lZhoubianshendu.isEmpty, false)
        re3 += appendedStringItem("房闪："+lFangshan, "，", !lFangshan.isEmpty, !lZhoubianshendu.isEmpty)
        re3 += appendedStringItem("房水细胞："+lFangshuixibao, "，", !lFangshuixibao.isEmpty, !lZhoubianshendu.isEmpty || !lFangshan.isEmpty)
        
        re3 += appendedStringItem("虹膜："+lHongmo, "，", !lHongmo.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("瞳孔", "，", !lTongkong.isEmpty || !lTongkongzhijing.isEmpty || !lDuiguangfanshe.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem(lTongkong, "", !lTongkong.isEmpty, false)
        re3 += appendedStringItem("直径："+lTongkongzhijing+" mm", "，", !lTongkongzhijing.isEmpty, !lTongkong.isEmpty)
        re3 += appendedStringItem("对光反射："+lDuiguangfanshe, "，", !lDuiguangfanshe.isEmpty, !lTongkong.isEmpty || !lTongkongzhijing.isEmpty)
        re3 += appendedStringItem("晶状体：", "，", !lJingzhuangti.isEmpty || !lJingzhuangtihe.isEmpty || !lHounangxia.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem(lJingzhuangti, "", !lJingzhuangti.isEmpty, false)
        re3 += appendedStringItem("核："+lJingzhuangtihe, "，", !lJingzhuangtihe.isEmpty, !lJingzhuangti.isEmpty)
        re3 += appendedStringItem("后囊下："+lHounangxia, "，", !lHounangxia.isEmpty, !lJingzhuangti.isEmpty || !rJingzhuangtihe.isEmpty)
        re3 += appendedStringItem("玻璃体："+lBoliti, "，", !lBoliti.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("散瞳："+lSantong, "，", !lSantong.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("视网膜："+lShiwangmo, "，", !lShiwangmo.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("眼位："+lYanwei, "，", !lYanwei.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("眼肌检查："+lYanjijiancha, "，", !lYanjijiancha.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("眼球大小："+lYanqiudaxiao, "，", !lYanqiudaxiao.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("眼球突出："+lYanqiutuchu, "，", !lYanqiutuchu.isEmpty, !re3.isEmpty)
        re3 += appendedStringItem("眼球凹陷："+lYanqiuaoxian, "，", !lYanqiuaoxian.isEmpty, !re3.isEmpty)
        
        var re4 = ""
        re4 += appendedStringItem("▹ 初步诊断：\n"+preliminaryDiagnosis, "", !preliminaryDiagnosis.isEmpty, false)
        re4 += appendedStringItem("▹ 药物治疗：\n"+dosage, "\n\n", !dosage.isEmpty, !re4.isEmpty)
        if operationPerformed == true {
            re4 += appendedStringItem("▹ 手术治疗：\n", "\n\n", operationPerformed, !re4.isEmpty)
            re4 += appendedStringItem(operationName, "", !operationName.isEmpty, false)
            re4 += appendedStringItem("日期："+NSDateFormatter.localizedStringFromDate(operationDate, dateStyle: .LongStyle, timeStyle: .NoStyle), "，", true, !operationName.isEmpty)
        }
        re4 += appendedStringItem("▹ 备注：\n"+comment, "\n\n", !comment.isEmpty, !re4.isEmpty)
        
        // 连接 -->
        
        re += appendedStringItem("▹ 病情描述：\n"+conditionDescription, "", !conditionDescription.isEmpty, false)
        re += appendedStringItem("▹ 眼科检查：", "\n\n", !re1.isEmpty || !re2.isEmpty || !re3.isEmpty, !re.isEmpty)
        re += appendedStringItem(re1, "\n", !re1.isEmpty, !re1.isEmpty)
        re += appendedStringItem("右眼"+re2, "。", !re2.isEmpty, !re1.isEmpty)
        re += appendedStringItem("左眼"+re3, "。", !re3.isEmpty, !re1.isEmpty || !re2.isEmpty)
        re += appendedStringItem(re4, "\n\n", !re4.isEmpty, !re.isEmpty)
        
        return re
    }
    
    // setter
    func sDate(date: NSDate) {
        let realm = Realm()
        realm.write {
            self.date = date
        }
    }
    
    // setter
    func sOperationPerformed(operationPerformed: Bool) {
        let realm = Realm()
        realm.write {
            self.operationPerformed = operationPerformed
        }
    }
    
    // setter
    func sOperationDate(date: NSDate) {
        let realm = Realm()
        realm.write {
            self.operationDate = date
        }
    }

    
    // set item
    func s(name: String, value: String) {
        let id = self.id + name
        // update FormItem
        let item = FormItem.addItem(id, name: name, value: value)
        // add it to items if it is new
        if items.filter("id == '\(id)'").count == 0 {
            let realm = Realm()
            realm.write {
                self.items.append(item)
            }
        }
    }
    
    // get item (return empty string if it does exist)
    func g(name: String) -> String {
        let id = self.id + name
        let v = items.filter("id == '\(id)'").first?.value
        if v != nil {
            return v!
        } else {
            return ""
        }
    }

    func removeFromDB() {
        
        removeSubOjectsFromDB()
        
        let realm = Realm()
        realm.write {
            // delete the record itself
            realm.delete(self)
        }
    }
    
    // 删除所有当record本身被删除后也应随之被删除的子对象
    func removeSubOjectsFromDB() {
        // delete photoMemos and voiceMemos associated
        for pm in photoMemos {
            pm.removeSubObjectsFromDB()
        }
        for vm in voiceMemos {
            vm.removeSubObjectsFromDB()
        }
        
        let realm = Realm()
        realm.write {
            realm.delete(self.photoMemos)
            realm.delete(self.voiceMemos)
            realm.delete(self.items) // delete items
        }
    }
    
    
    func addPhotoMemo(originalImage: UIImage, creationDate: NSDate, shouldScaleDown: Bool) -> Bool {

        var pmImageData: NSData
        var thumbnailImageData: NSData

        // scale down image size if needed to save storage space
        if shouldScaleDown == true && (originalImage.size.width > PhotoMemo.imageSize.width || originalImage.size.height > PhotoMemo.imageSize.height) {
            let pmImage = resizeImage(originalImage, PhotoMemo.imageSize, false)
            pmImageData = UIImageJPEGRepresentation(pmImage, 1.0)
            let thumbnailImage = resizeImage(pmImage, PhotoMemo.thumbnailSize, true)
            thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0)
        } else { // original image as pmImage
            pmImageData = UIImageJPEGRepresentation(originalImage, 1.0)
            let thumbnailImage = resizeImage(originalImage, PhotoMemo.thumbnailSize, true)
            thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0)
        }
        
        // save image data to disk
        return addPhotoMemoByData(pmImageData, thumbnailData: thumbnailImageData, creationDate: creationDate)
    }
    
    func addPhotoMemoByData(imageData: NSData, thumbnailData: NSData, creationDate: NSDate) -> Bool {
        // save image & thumbnail image data to Documents
        let result1 = saveDataToFile(PhotoMemo.folder, imageData, ".jpg")
        let result2 = saveDataToFile(PhotoMemo.folder, thumbnailData, ".jpg")
        // create and add photoMemo
        if result1.success == true && result2.success == true {
            let photoMemo = PhotoMemo()
            photoMemo.imageFilename = result1.filename
            photoMemo.thumbnailFilename = result2.filename
            photoMemo.creationDate = creationDate
            let realm = Realm()
            realm.write {
                realm.add(photoMemo, update: true)
                self.photoMemos.append(photoMemo)
            }
        }
        return result1.success && result2.success
    }
    
    func addVoiceMemo(voiceData: NSData, creationDate: NSDate) -> (success: Bool, filename:String, urlString: String) {
        // save data to Documents
        let result = saveDataToFile(VoiceMemo.folder, voiceData, ".mp3")
        // create and add photoMemo
        if result.success {
            let voiceMemo = VoiceMemo()
            voiceMemo.audioFilename = result.filename
            voiceMemo.creationDate = creationDate
            voiceMemo.owner = self
            let realm = Realm()
            realm.write {
                self.voiceMemos.append(voiceMemo)
            }
            voiceMemo.saveToDB()
        }
        return result
    }
    
    static var recordItems: [RecordItem] = [
        RecordItem(name: "rShili", displayName: "右眼视力", tag: 0, basicChoices: ["无光感", "光感", "手动10cm", "手动30cm", "手动50cm", "指数10cm", "指数30cm", "指数50cm"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        RecordItem(name: "lShili", displayName: "左眼视力", tag: 0, basicChoices: ["无光感", "光感", "手动10cm", "手动30cm", "手动50cm", "指数10cm", "指数30cm", "指数50cm"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        
        RecordItem(name: "rJiaozhengshili", displayName: "右眼矫正视力", tag: 0, basicChoices: ["无光感", "光感", "手动10cm", "手动30cm", "手动50cm", "指数10cm", "指数30cm", "指数50cm"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        RecordItem(name: "lJiaozhengshili", displayName: "左眼矫正视力", tag: 0, basicChoices: ["无光感", "光感", "手动10cm", "手动30cm", "手动50cm", "指数10cm", "指数30cm", "指数50cm"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        
        RecordItem(name: "rJiaozhengshilizhujing", displayName: "右眼验光矫正球镜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        RecordItem(name: "lJiaozhengshilizhujing", displayName: "左眼验光矫正球镜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        
        RecordItem(name: "rJiaozhengshililengjing", displayName: "右眼验光矫正柱镜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        RecordItem(name: "lJiaozhengshililengjing", displayName: "左眼验光矫正柱镜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),

        RecordItem(name: "rJiaozhengshilizhouwei", displayName: "右眼验光矫正轴位", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        RecordItem(name: "lJiaozhengshilizhouwei", displayName: "左眼验光矫正轴位", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "Float"),
        
        RecordItem(name: "rYanya", displayName: "右眼眼压", tag: 0, basicChoices: ["测不出", "Tn", "T+1", "T+2", "T+3"], hasCustomText: true, prefix: "", suffix: " mmHg", dataFormat: "Float"),
        RecordItem(name: "lYanya", displayName: "左眼眼压", tag: 0, basicChoices: ["测不出", "Tn", "T+1", "T+2", "T+3"], hasCustomText: true, prefix: "", suffix: " mmHg", dataFormat: "Float"),
        
        RecordItem(name: "rYanjian", displayName: "右眼眼睑", tag: 0, basicChoices: ["正常"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lYanjian", displayName: "左眼眼睑", tag: 0, basicChoices: ["正常"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rJiemo", displayName: "右眼结膜", tag: 0, basicChoices: ["正常", "充血"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lJiemo", displayName: "左眼结膜", tag: 0, basicChoices: ["正常", "充血"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rJiaomo", displayName: "右眼角膜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lJiaomo", displayName: "左眼角膜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rZhoubianshendu", displayName: "右眼前房周边深度", tag: 0, basicChoices: [">1 CT", "1 CT", "1/2 CT", "1/3 CT", "<1/3 CT"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lZhoubianshendu", displayName: "左眼前房周边深度", tag: 0, basicChoices: [">1 CT", "1 CT", "1/2 CT", "1/3 CT", "<1/3 CT"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rFangshan", displayName: "右眼房闪", tag: 0, basicChoices: ["无", "+", "++", "+++"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lFangshan", displayName: "左眼房闪", tag: 0, basicChoices: ["无", "+", "++", "+++"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rFangshuixibao", displayName: "右眼房水细胞", tag: 0, basicChoices: ["无", "+", "++", "+++"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lFangshuixibao", displayName: "左眼房水细胞", tag: 0, basicChoices: ["无", "+", "++", "+++"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rHongmo", displayName: "右眼虹膜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lHongmo", displayName: "左眼虹膜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rTongkong", displayName: "右眼瞳孔", tag: 0, basicChoices: ["圆", "不圆"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lTongkong", displayName: "左眼瞳孔", tag: 0, basicChoices: ["圆", "不圆"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rTongkongzhijing", displayName: "右眼瞳孔直径", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: " mm", dataFormat: "Float"),
        RecordItem(name: "lTongkongzhijing", displayName: "左眼瞳孔直径", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: " mm", dataFormat: "Float"),
        
        RecordItem(name: "rDuiguangfanshe", displayName: "右眼对光反射", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lDuiguangfanshe", displayName: "左眼对光反射", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rJingzhuangti", displayName: "右眼晶状体", tag: 0, basicChoices: ["透明", "混浊"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lJingzhuangti", displayName: "左眼晶状体", tag: 0, basicChoices: ["透明", "混浊"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rJingzhuangtihe", displayName: "右眼晶状体-核", tag: 0, basicChoices: ["I级", "II级", "III级", "IV级"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lJingzhuangtihe", displayName: "左眼晶状体-核", tag: 0, basicChoices: ["I级", "II级", "III级", "IV级"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rHounangxia", displayName: "右眼后囊下", tag: 0, basicChoices: ["无混浊", "混浊"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lHounangxia", displayName: "左眼后囊下", tag: 0, basicChoices: ["无混浊", "混浊"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rBoliti", displayName: "右眼玻璃体", tag: 0, basicChoices: ["透明", "混浊", "积血"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lBoliti", displayName: "左眼玻璃体", tag: 0, basicChoices: ["透明", "混浊", "积血"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rSantong", displayName: "右眼散瞳", tag: 0, basicChoices: ["有", "无"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lSantong", displayName: "左眼散瞳", tag: 0, basicChoices: ["有", "无"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rShiwangmo", displayName: "右眼视网膜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lShiwangmo", displayName: "左眼视网膜", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rYanwei", displayName: "右眼眼位", tag: 0, basicChoices: ["正，各项运动正常"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lYanwei", displayName: "左眼眼位", tag: 0, basicChoices: ["正，各项运动正常"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rYanjijiancha", displayName: "右眼眼肌检查", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lYanjijiancha", displayName: "左眼眼肌检查", tag: 0, basicChoices: [], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rYanqiudaxiao", displayName: "右眼眼球大小", tag: 0, basicChoices: ["正常"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lYanqiudaxiao", displayName: "左眼眼球大小", tag: 0, basicChoices: ["正常"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rYanqiutuchu", displayName: "右眼眼球突出", tag: 0, basicChoices: ["无"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lYanqiutuchu", displayName: "左眼眼球突出", tag: 0, basicChoices: ["无"], hasCustomText: true, prefix: "", suffix: "", dataFormat: "String"),
        
        RecordItem(name: "rYanqiuaoxian", displayName: "右眼眼球凹陷", tag: 0, basicChoices: ["无", "有"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        RecordItem(name: "lYanqiuaoxian", displayName: "左眼眼球凹陷", tag: 0, basicChoices: ["无", "有"], hasCustomText: false, prefix: "", suffix: "", dataFormat: "String"),
        ]
    
    
    // helper dictionaries
    static var tagToItems = [Int: RecordItem]()
    static var nameToItems = [String: RecordItem]()
    
 
    /* type functions */
    
    static func generateHelperDictionaries() {
        for i in 0..<Record.recordItems.count {
            Record.recordItems[i].tag = i
            Record.tagToItems[i] = Record.recordItems[i]
            Record.nameToItems[Record.recordItems[i].name] = Record.recordItems[i]
        }
    }
    
    static func getNewID() -> String {
        return NSUUID().UUIDString
    }
    
    static func addNewRecord(forPatient: Patient) -> Record {
        let realm = Realm()
        let r = Record()
        r.id = Record.getNewID()
        
        realm.write {
            realm.add(r, update: true)
            forPatient.records.append(r)
        }
        
        // 病情描述
        r.s("conditionDescription", value: "")
        // 药物治疗
        r.s("dosage", value: "")
        // 手术名称
        r.s("operationName", value: "")
        
        /* 眼科检查 */
        
        // 视力
        r.s("lShili", value: "") // 无光感，光感，手动(?cm)，指数(?cm)，国际标准视力表小数值
        r.s("rShili", value: "")
        
        // 矫正视力
        r.s("lJiaozhengshili", value: "")
        r.s("rJiaozhengshili", value: "")
        
        r.s("lJiaozhengshilizhujing", value: "")
        r.s("rJiaozhengshilizhujing", value: "")
        
        r.s("lJiaozhengshililengjing", value: "")
        r.s("rJiaozhengshililengjing", value: "")
        
        r.s("lJiaozhengshilizhouwei", value: "")
        r.s("rJiaozhengshilizhouwei", value: "")
        
        
        // 眼压
        r.s("lYanya", value: "") // 测不出，自填数值
        r.s("rYanya", value: "")
        
        // 眼睑
        r.s("lYanjian", value: "正常") // 自填
        r.s("rYanjian", value: "正常")
        
        // 结膜
        r.s("lJiemo", value: "") // 充血，自填
        r.s("rJiemo", value: "")
        
        // 角膜
        r.s("lJiaomo", value: "") // 自填
        r.s("rJiaomo", value: "")
        
        // 前房周边深度
        r.s("lZhoubianshendu", value: "") // >1 CT, 1 CT, 1/2 CT, 1/3 CT, <1/3 CT
        r.s("rZhoubianshendu", value: "")
        
        // 房闪
        r.s("lFangshan", value: "无") // +, ++, +++
        r.s("rFangshan", value: "无")
        
        // 房水细胞
        r.s("lFangshuixibao", value: "无") // +, ++, +++
        r.s("rFangshuixibao", value: "无")
        
        // 虹膜
        r.s("lHongmo", value: "") // 自填
        r.s("rHongmo", value: "")
        
        // 瞳孔
        r.s("lTongkong", value: "圆") // 不圆
        r.s("rTongkong", value: "圆")
        
        // 瞳孔直径
        r.s("lTongkongzhijing", value: "3") // 自填
        r.s("rTongkongzhijing", value: "3")
        
        // 瞳孔对光反射
        r.s("lDuiguangfanshe", value: "") // 自填
        r.s("rDuiguangfanshe", value: "")
        
        // 晶状体
        r.s("lJingzhuangti", value: "透明") // 混浊，自填. 如自填，核、后囊下设为自填
        r.s("rJingzhuangti", value: "透明")
        
        // 晶状体 - 核
        r.s("lJingzhuangtihe", value: "") // II, III, IV级, 自填
        r.s("rJingzhuangtihe", value: "") // II, III, IV级, 自填
        
        // 晶状体 - 后囊下
        r.s("lHounangxia", value: "") // 混浊
        r.s("rHounangxia", value: "")
        
        // 玻璃体
        r.s("lBoliti", value: "透明") // 混浊，积血，自填
        r.s("rBoliti", value: "透明")
        
        // 散瞳
        r.s("lSantong", value: "无") // 有，无
        r.s("rSantong", value: "无")
        
        // 视网膜
        r.s("lShiwangmo", value: "") // 自填
        r.s("rShiwangmo", value: "")
        
        // 眼位
        r.s("lYanwei", value: "正，各项运动正常") // 自填
        r.s("rYanwei", value: "正，各项运动正常")
        
        // 眼肌检查
        r.s("lYanjijiancha", value: "") // 自填
        r.s("rYanjijiancha", value: "")
        
        // 眼球大小
        r.s("lYanqiudaxiao", value: "正常") // 自填
        r.s("rYanqiudaxiao", value: "正常")
        
        // 眼球突出
        r.s("lYanqiutuchu", value: "无") // "有: _ mm
        r.s("rYanqiutuchu", value: "无")
        
        // 眼球凹陷
        r.s("lYanqiuaoxian", value: "无") // 有
        r.s("rYanqiuaoxian", value: "无")
        
        // 备注
        r.s("comment", value: "")
        
        // 初步诊断
        r.s("preliminaryDiagnosis", value: "")
        
        // 分享时使用的检查报告文字，基于report生成，用户可编辑
        r.s("reportForShare", value: "")
        
        return r
    }

}

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
    
    // 患者列表，未排序
    var patients: [Patient] {
        return linkingObjects(Patient.self, forProperty: "category")
    }
    
    var numberOfPatients: Int {
        return patients.count
    }
    
    // 患者列表，按末次就诊时间降序排列
    var patientsSortedByLastTreatmentDateDescending: [Patient] {
        let ps = linkingObjects(Patient.self, forProperty: "category")
        return ps.sorted({$0.lastTreatmentDate.compare($1.lastTreatmentDate) == NSComparisonResult.OrderedDescending})
    }
    
    // 患者列表，按首诊时间升序排列
    var patientsSortedByFirstTreatmentDateAscending: [Patient] {
        let ps = linkingObjects(Patient.self, forProperty: "category")
        return ps.sorted({$0.firstTreatmentDate.compare($1.firstTreatmentDate) == NSComparisonResult.OrderedAscending})
    }
    
    /* member functions */
    
    func removeFromDB() {
        let realm = Realm()
        realm.write {
            realm.delete(self)
        }
    }
    
    func updateOrder(newOrder: Int) {
        let realm = Realm()
        let smallPos = min(order, newOrder)
        let bigPos = max(order, newOrder)
        //        println("smallPos: \(smallPos)")
        //        println("bigPos: \(bigPos)")
        var q = realm.objects(Category).filter("order >= \(smallPos) AND order <= \(bigPos) AND name != '\(name)'")
        //        println(q)
        //        println(q.count)
        let deltaPos = newOrder < order ? 1 : -1
        //        println("deltaPos: \(deltaPos)")
        
        realm.write {
            for c in q {
                //                println("update: \(c.name) \(c.order)->\(c.order+deltaPos)")
                c.order += deltaPos
            }
            self.order = newOrder
        }
    }
    
    func rename(newName: String) -> Bool {
        // 不允许重名
        if Category.getCategoryByName(newName) != nil {
            return false
        }
        
        let realm = Realm()
        realm.write {
            self.name = newName
        }
        return true
    }
    
    /* type properties */
    
    static var allCategories: [Category] {
        let cs = Realm().objects(Category).sorted("order", ascending: true)
        return Array(cs)
    }
    
    /* Type functions */
    
    static func getNewID() -> String {
        return NSUUID().UUIDString
    }

    static func addNewCategory(name: String, isFirst: Bool) -> Category {
        // name存在
        if let c = getCategoryByName(name) {
            return c
        }
        
        let realm = Realm()
        let c = Category()
        c.id = Category.getNewID()
        c.name = name
        let q = realm.objects(Category).sorted("order", ascending: true)
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
        realm.write {
            realm.add(c, update: true)
        }
        return c
    }
    
    static func getCategoryByName(name: String) -> Category? {
        let q = Realm().objects(Category).filter("name == '\(name)'")
        return q.first
    }
    
}


class Tag: Object {
    dynamic var name = "" // primary key
    
    // ---- End of data defination ----//
    
    /* primary key */
    override class func primaryKey() -> String {
        return "name"
    }
    
    var patientsTagged: [Patient] {
        return linkingObjects(Patient.self, forProperty: "tags")
    }
    
    // 带有tag的患者列表，按末次就诊时间降序排列
    var patientsTaggedSortedByLastTreatmentDateDescending: [Patient] {
        let ps = linkingObjects(Patient.self, forProperty: "tags")
        return ps.sorted({$0.lastTreatmentDate.compare($1.lastTreatmentDate) == NSComparisonResult.OrderedDescending})
    }
    
    // 带有tag的患者列表，按末次就诊时间升序排列
    var patientsTaggedSortedByLastTreatmentDateAscending: [Patient] {
        let ps = linkingObjects(Patient.self, forProperty: "tags")
        return ps.sorted({$0.lastTreatmentDate.compare($1.lastTreatmentDate) == NSComparisonResult.OrderedAscending})
    }
    
    var numberOfPatientsTagged: Int {
        return patientsTagged.count
    }
    
    static var numberOfTags: Int {
        return Realm().objects(Tag).count
    }
    
    static var allTagsSortedByNameAscending: [Tag] {
        let ps = Realm().objects(Tag).sorted("name", ascending: true)
        return Array(ps)
    }
    
    static var allTagsSortedByNumberOfPatientsDescending: [Tag] {
        let ts = Array(Realm().objects(Tag))
        return ts.sorted({$0.numberOfPatientsTagged > $1.numberOfPatientsTagged})
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
        
        let realm = Realm()
        realm.write {
            realm.delete(self)
        }
    }
    
    /* Type functions */
    
    static func addNewTag(name: String) -> Tag {
        let tag = Tag()
        tag.name = name
        let realm = Realm()
        realm.write {
            realm.add(tag, update: true)
        }
        return tag
    }
    
    static func getTagByName(name: String) -> Tag {
        if let tag = Realm().objectForPrimaryKey(Tag.self, key: name) {
            return tag
        } else {
            return Tag.addNewTag(name)
        }
    }
    
    static func tagExistsByName(name: String) -> Bool {
        if Realm().objectForPrimaryKey(Tag.self, key: name) != nil {
            return true
        } else {
            return false
        }
    }
    
    // 删除所有没有被任何患者tag的tag
    static func clearTagsWithZeroPatientsTagged() {
        let ts = Realm().objects(Tag)
//        println("clear")
        for t in ts {
            if t.numberOfPatientsTagged == 0 {
                t.removeFromDB()
            }
        }
    }
}

class PhotoMemo: Object {
    dynamic var imageFilename: String = "" // primary key, image filename
    dynamic var thumbnailFilename: String = "" // thumbnail image filename
    dynamic var creationDate = NSDate()
    dynamic var caption = "" // 图片描述文字
    
    // ---- End of data defination ----//
    

    /* computed properties */
    
    // 如果record还没保存到realm，则会返回nil
    var owner: Record {
        return linkingObjects(Record.self, forProperty: "photoMemos").first!
    }
 
    var url: NSURL? {
        return getURLFromFilename(imageFilename, PhotoMemo.folder)
    }
    
    var urlForThumbnail: NSURL? {
        return getURLFromFilename(thumbnailFilename, PhotoMemo.folder)
    }
    
    var urlString: String? {
        return url?.absoluteString
    }
    
    var urlStringForThumbnail: String? {
        return urlForThumbnail?.absoluteString
    }
    
    var image: UIImage? {
        if urlString != nil {
            return UIImage(contentsOfFile: urlString!)
        } else {
            return nil
        }
    }
    
    var thumbnailImage: UIImage? {
        if urlStringForThumbnail != nil {
            return UIImage(contentsOfFile: urlStringForThumbnail!)
        } else {
            return nil
        }
    }
    

    /* primary key */
    override class func primaryKey() -> String {
        return "imageFilename"
    }
    
    func sCaption(caption: String) {
        let realm = Realm()
        realm.write {
            self.caption = caption
        }
    }
    
    func removeFromDB() {
        let realm = Realm()
        
        removeSubObjectsFromDB()
        
        realm.write {
            realm.delete(self)
        }
        
    }
    
    // 删除与对象相关联的子对象（对象删除后，这些子对象也都应随之删除）
    func removeSubObjectsFromDB() {
        // delete image & thumbnail files
        if urlString != nil {
            deleteDataFile(urlString!)
        }
        if urlStringForThumbnail != nil {
            deleteDataFile(urlStringForThumbnail!)
        }
    }
    
    /* type properties */
    
    static let folder = "photomemos" // folder name in Documents
    static let imageSize = CGSizeMake(1024.0, 1024.0)
    static let thumbnailSize = CGSizeMake(150.0, 150.0) // for display in collection view (scale should be considered)
    
    static var totalNumberOfPhotoMemos: Int {
        return Realm().objects(PhotoMemo).count
    }
}

class VoiceMemo: Object {
    dynamic var audioFilename = "" // primary key
    dynamic var creationDate = NSDate()
    dynamic var caption = ""
    dynamic var owner: Record!
    
    static var folder = "voicememos"
    
    var url: NSURL? {
        return getURLFromFilename(audioFilename, VoiceMemo.folder)
    }
    
    var urlString: String? {
        return url?.absoluteString
    }
    
    /* primary key */
    override class func primaryKey() -> String {
        return "audioFilename"
    }
    
    func saveToDB() {
        let realm = Realm()
        realm.write {
            realm.add(self, update: true)
        }
    }
    
    func removeFromDB() {
        // delete audio file
        if urlString != nil {
            deleteDataFile(urlString!)
        }
        
        let realm = Realm()
        realm.write {
            realm.delete(self)
        }
    }
    
    // 用于删除与对象相关联的子对象（对象删除后，这些子对象也都应随之删除）
    func removeSubObjectsFromDB() {
        // delete audio files
        if urlString != nil {
            deleteDataFile(urlString!)
        }
    }
}

// placeholder object for 1) detecting the realm file existance. 2) track version history
class Spy: Object {
    
    dynamic var version = "1.0" // primary key
    override class func primaryKey() -> String {
        return "version"
    }
    
    var versionFloatValue: Float {
        return (version as NSString).floatValue
    }
    
    static func addNewSpy() -> Spy {
        let s = Spy()
        if let v = CaseNoteConstants.appVersion {
            s.version = v
        } else {
            s.version = "1.0"
        }
        let realm = Realm()
        realm.write {
            realm.add(s, update: true)
        }
        return s
    }
}


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


// MARK: - Helper functions for Default Data

func initData() {
    let realmPath = Realm.defaultPath
    // 如果Documents中有default.realm文件，执行migration
    if NSFileManager.defaultManager().fileExistsAtPath(realmPath) {
        println("Realm file exists. No need to load default data")
        performMigration()
    } else { // 否则从Bundle中copy default.realm文件到Documents中
        println("Load default data")
        if loadDefaultDataFromBundle() == true {
            performMigration()
        } else {
            generateDemoData() // copy失败则程序生成
        }
    }
    
    Spy.addNewSpy() // this will record the lastest installation version to the spy object
    
    Record.generateHelperDictionaries()
}

func performMigration() {
    
    let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
        println("migration begin")
        if oldSchemaVersion < 1 {
        }
        println("Migration complete.")
    }
    
    setDefaultRealmSchemaVersion(1, migrationBlock)
}

// return true only if default.realm is successfully copied
func loadDefaultDataFromBundle() -> Bool {
    var result = false
    
    // copy over data files from bundle
    let realmPath = Realm.defaultPath
    let defaultParentPath = realmPath.stringByDeletingLastPathComponent
    let pmPath = defaultParentPath.stringByAppendingPathComponent("photomemos")
    println("Realm default path: \(realmPath)")
    println("photomemos folder path: \(pmPath)")
    
    // copy default.realm
    if let dataPath = bundlePath("default.realm") {
        println("dataPath in bundle: \(dataPath)")
        var error: NSError?
        if NSFileManager.defaultManager().fileExistsAtPath(realmPath) {
            println("target exists. to remove it. spy count: \(Realm().objects(Spy).count)")
            NSFileManager.defaultManager().removeItemAtPath(realmPath, error: &error)
            if (error != nil) {
                println("remove error!")
                println(error!.description)
            }
        }
        
        if NSFileManager.defaultManager().copyItemAtPath(dataPath, toPath: realmPath, error: &error) {
            println("successfuly copied default.realm from bundle to Documents")
            result = true
        } else {
            println("failed to copy default data from bundle")
        }
        if (error != nil) {
            println("copy default.realm error!")
            println(error!.description)
        }
    }
    
    // copy photomemos folder
    if let dataPath = bundlePath("photomemos") {
        println("dataPath in bundle: \(dataPath)")
        var error: NSError?
        if NSFileManager.defaultManager().fileExistsAtPath(pmPath) {
            println("target exists. to remove it. spy count: \(Realm().objects(Spy).count)")
            NSFileManager.defaultManager().removeItemAtPath(pmPath, error: &error)
            if (error != nil) {
                println("remove photomemos folder error!")
                println(error!.description)
            }
        }
        if NSFileManager.defaultManager().copyItemAtPath(dataPath, toPath: pmPath, error: &error) {
            println("successfuly copied photomemos from bundle to Documents.")
        } else {
            println("failed to copy photomemos from bundle")
        }
        if (error != nil) {
            println("copy photomemos error!")
            println(error!.description)
        }
    }
    
    return result
}

func bundlePath(path: String) -> String? {
    return NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent(path)
}

func generateDemoData() {
    // add some demo categories
    //        let defaultCategoryNames = ["未分组", "角膜及眼表疾病", "晶体病", "青光眼", "免疫/葡萄膜炎", "玻璃体视网膜疾病", "斜弱视与小儿眼病", "视光", "眼外伤", "眼整形", "眼眶病", "神经眼科", "眼肿瘤", "与眼部相关的全身疾病"]
//    let defaultCategoryNames = ["未分组", "结膜炎", "结膜增生", "角膜炎", "角膜变性", "结膜及角膜肿物"]
    let defaultCategoryNames = ["未分组"]
    let defaultPatientNames = ["张某"]
    
    var categories = [Category]()
    for i in 0..<defaultCategoryNames.count {
        let c = Category.addNewCategory(defaultCategoryNames[i], isFirst: false)
        categories.append(c)
    }
    
    // add demo patients
    for i in 0..<defaultPatientNames.count {
        let p = Patient.addNewPatient(categories[i], starred: true)
        p.s("name", value: defaultPatientNames[i])
        p.s("diagnosis", value: "角膜变性")
        p.addTagByName("角膜变性")
        p.addTagByName("基因")
        
        let rDates = generateRandomDateArrayWithinDaysBeforeToday(6, 60)
        // add some demo records to patient
        for ri in 0..<6 {
            let r = p.addRecord()
            r.sDate(rDates[ri])
            r.s("rShili", value: "\(Float(arc4random_uniform(15))/10.0)")
            r.s("lShili", value: "\(Float(arc4random_uniform(15))/10.0)")
            r.s("rJiaozhengshili", value: "\(Float(arc4random_uniform(15))/10.0)")
            r.s("lJiaozhengshili", value: "\(Float(arc4random_uniform(15))/10.0)")
            r.s("rYanya", value: "\((Float(arc4random_uniform(80))+20.0)/10.0)")
            r.s("lYanya", value: "\((Float(arc4random_uniform(80))+20.0)/10.0)")
            if ri == 2 {
                r.sOperationPerformed(true)
                r.sOperationDate(r.date)
            }
        }
    }
    println("default data generated.")
}




// save data to folder ".../Documents/\(folder)/" with an unique name
func saveDataToFile(folderInDocuments: String, data: NSData, suffix: String) -> (success: Bool, filename:String, urlString: String) {
    let fileManager = NSFileManager.defaultManager()
    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let docsDir = dirPaths[0] as! String
    let dataDir = docsDir.stringByAppendingPathComponent(folderInDocuments)
    
    // create folder if it does not exist
    if !fileManager.fileExistsAtPath(dataDir) {
        var error: NSError?
        if !fileManager.createDirectoryAtPath(dataDir, withIntermediateDirectories: false, attributes: nil, error: &error) {
            println("Failed to create folder \(folderInDocuments) in Documents dir: \(error!.localizedDescription)")
        }
    }
    
    let unique = NSDate.timeIntervalSinceReferenceDate()
    let urlString = dataDir.stringByAppendingPathComponent("\(unique)"+suffix)
    return (data.writeToFile(urlString, atomically: true), "\(unique)"+suffix, urlString)
}


func deleteDataFile(pathString: String) -> Bool {
    var success = false
    let fileManager = NSFileManager.defaultManager()
    if fileManager.fileExistsAtPath(pathString) {
        var error: NSError?
        if !fileManager.removeItemAtPath(pathString, error: &error) {
            println("Failed to delete file: \(error!.localizedDescription)")
        } else {
            success = true
        }
    }
    return success
}

// get URL of image file saved in .../Documents/photos
func getURLFromFilename(filename: String, folderInDocuments: String) -> NSURL? {
    let fileManager = NSFileManager.defaultManager()
    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let docsDir = dirPaths[0] as! String
    let dataDir = docsDir.stringByAppendingPathComponent(folderInDocuments)
    let urlString = dataDir.stringByAppendingPathComponent(filename)
    
    if !fileManager.fileExistsAtPath(urlString) {
        return nil
    }
    return NSURL(string: urlString)?.absoluteURL
}
