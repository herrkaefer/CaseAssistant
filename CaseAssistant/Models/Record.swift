//
//  Record.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


class Record: Object {
    
    dynamic var id: String          = "" // primary key
    dynamic var date                = Date()
    let         photoMemos          = List<PhotoMemo>()
    let         voiceMemos          = List<VoiceMemo>()
    dynamic var operationPerformed  = false
    dynamic var operationDate       = Date()
    let         items               = List<FormItem>() // all string items
    
    let owners = LinkingObjects(fromType: Patient.self, property: "records")

    // ---- End of data defination ----//
    
    /* primary key */
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    /* computed properties */
    
    var owner: Patient {
//        return LinkingObjects(fromType: Patient.self, property: "records").first!
        return owners.first!
    }
    
    // 距离首诊的天数
    var daysAfterFirstTreatment: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: owner.firstTreatmentDate, to: date)
        return components.day!
    }
    
    // 距离上次手术的天数。如果没有手术过，返回nil
    var daysAfterLastOperation: Int? {
        var days: Int? = nil
        for opDate in owner.operationDates {
            let d = numberOfDaysBetweenTwoDates(opDate, toDate: date)
            if d >= 0 {
                days = d
            } else {
                break
            }
        }
        return days
    }
    
    var photoMemosSortedByCreationDateAscending: [PhotoMemo] {
        return Array(photoMemos.sorted(byKeyPath: "creationDate", ascending: true))
    }
    
    var photoMemosSortedByCreationDateDescending: [PhotoMemo] {
        return Array(photoMemos.sorted(byKeyPath: "creationDate", ascending: false))
    }
    
    var voiceMemosSortedByCreationDateAscending: [VoiceMemo] {
        return Array(voiceMemos.sorted(byKeyPath: "creationDate", ascending: true))
    }
    
    var voiceMemosSortedByCreationDateDescending: [VoiceMemo] {
        return Array(voiceMemos.sorted(byKeyPath: "creationDate", ascending: false))
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
        re1 += appendedStringItem("视力：", punctuationBefore: "", strShouldBeAppended: !rShili.isEmpty || !lShili.isEmpty, punctuationShouldBeAdded: false)
        re1 += appendedStringItem("右"+rShili, punctuationBefore: "", strShouldBeAppended: !rShili.isEmpty, punctuationShouldBeAdded: false)
        re1 += appendedStringItem("左"+lShili, punctuationBefore: "，", strShouldBeAppended: !rShili.isEmpty, punctuationShouldBeAdded: !re1.isEmpty)
        re1 += appendedStringItem("验光矫正：", punctuationBefore: "；", strShouldBeAppended: !rJiaozhengshili.isEmpty || !lJiaozhengshili.isEmpty, punctuationShouldBeAdded: !re1.isEmpty)
        
        if !rJiaozhengshili.isEmpty {
            re1 += appendedStringItem("右", punctuationBefore: "", strShouldBeAppended: true, punctuationShouldBeAdded: false)
            re1 += appendedStringItem(rJiaozhengshilizhujing+"DS", punctuationBefore: "+", strShouldBeAppended: !rJiaozhengshilizhujing.isEmpty, punctuationShouldBeAdded: (rJiaozhengshilizhujing as NSString).floatValue > 0 && !rJiaozhengshilizhujing.beginsWith("+"))
            re1 += appendedStringItem("/", punctuationBefore: "", strShouldBeAppended: !rJiaozhengshilizhujing.isEmpty && !rJiaozhengshililengjing.isEmpty, punctuationShouldBeAdded: false)
            re1 += appendedStringItem(rJiaozhengshililengjing+"DC", punctuationBefore: "+", strShouldBeAppended: !rJiaozhengshililengjing.isEmpty, punctuationShouldBeAdded: (rJiaozhengshililengjing as NSString).floatValue > 0 && !rJiaozhengshililengjing.beginsWith("+"))
            re1 += appendedStringItem("×"+rJiaozhengshilizhouwei+"°", punctuationBefore: "", strShouldBeAppended: !rJiaozhengshilizhouwei.isEmpty, punctuationShouldBeAdded: false)
            re1 += appendedStringItem(rJiaozhengshili, punctuationBefore: "=", strShouldBeAppended: true, punctuationShouldBeAdded: !rJiaozhengshilizhujing.isEmpty || !rJiaozhengshililengjing.isEmpty)
        }
        if !lJiaozhengshili.isEmpty {
            re1 += appendedStringItem("左", punctuationBefore: "，", strShouldBeAppended: true, punctuationShouldBeAdded: true)
            re1 += appendedStringItem(lJiaozhengshilizhujing+"DS", punctuationBefore: "+", strShouldBeAppended: !lJiaozhengshilizhujing.isEmpty, punctuationShouldBeAdded: (lJiaozhengshilizhujing as NSString).floatValue > 0 && !lJiaozhengshilizhujing.beginsWith("+"))
            re1 += appendedStringItem("/", punctuationBefore: "", strShouldBeAppended: !lJiaozhengshilizhujing.isEmpty && !lJiaozhengshililengjing.isEmpty, punctuationShouldBeAdded: false)
            re1 += appendedStringItem(lJiaozhengshililengjing+"DC", punctuationBefore: "+", strShouldBeAppended: !lJiaozhengshililengjing.isEmpty, punctuationShouldBeAdded: (lJiaozhengshililengjing as NSString).floatValue > 0 && !lJiaozhengshililengjing.beginsWith("+"))
            re1 += appendedStringItem("×"+lJiaozhengshilizhouwei+"°", punctuationBefore: "", strShouldBeAppended: !lJiaozhengshilizhouwei.isEmpty, punctuationShouldBeAdded: false)
            re1 += appendedStringItem(lJiaozhengshili, punctuationBefore: "=", strShouldBeAppended: true, punctuationShouldBeAdded: !lJiaozhengshilizhujing.isEmpty || !lJiaozhengshililengjing.isEmpty)
        }
        
        re1 += appendedStringItem("眼压：", punctuationBefore: "；", strShouldBeAppended: !rYanya.isEmpty || !lYanya.isEmpty, punctuationShouldBeAdded: !re1.isEmpty)
        re1 += appendedStringItem("右"+rYanya+" mmHg", punctuationBefore: "", strShouldBeAppended: !rYanya.isEmpty, punctuationShouldBeAdded: false)
        re1 += appendedStringItem("左"+lYanya+" mmHg", punctuationBefore: "，", strShouldBeAppended: !rYanya.isEmpty, punctuationShouldBeAdded: !rYanya.isEmpty)
        
        // 右眼
        var re2 = ""
        re2 += appendedStringItem("眼睑："+rYanjian, punctuationBefore: "", strShouldBeAppended: !rYanjian.isEmpty, punctuationShouldBeAdded: false)
        re2 += appendedStringItem("结膜："+rJiemo, punctuationBefore: "，", strShouldBeAppended: !rJiemo.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("角膜："+rJiaomo, punctuationBefore: "，", strShouldBeAppended: !rJiaomo.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        
        re2 += appendedStringItem("前房", punctuationBefore: "，", strShouldBeAppended: !rZhoubianshendu.isEmpty || !rFangshan.isEmpty || !rFangshuixibao.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("周边深度："+rZhoubianshendu, punctuationBefore: "", strShouldBeAppended: !rZhoubianshendu.isEmpty, punctuationShouldBeAdded: false)
        re2 += appendedStringItem("房闪："+rFangshan, punctuationBefore: "，", strShouldBeAppended: !rFangshan.isEmpty, punctuationShouldBeAdded: !rZhoubianshendu.isEmpty)
        re2 += appendedStringItem("房水细胞："+rFangshuixibao, punctuationBefore: "，", strShouldBeAppended: !rFangshuixibao.isEmpty, punctuationShouldBeAdded: !rZhoubianshendu.isEmpty || !rFangshan.isEmpty)
        
        re2 += appendedStringItem("虹膜："+rHongmo, punctuationBefore: "，", strShouldBeAppended: !rHongmo.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("瞳孔", punctuationBefore: "，", strShouldBeAppended: !rTongkong.isEmpty || !rTongkongzhijing.isEmpty || !rDuiguangfanshe.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem(rTongkong, punctuationBefore: "", strShouldBeAppended: !rTongkong.isEmpty, punctuationShouldBeAdded: false)
        re2 += appendedStringItem("直径："+rTongkongzhijing+" mm", punctuationBefore: "，", strShouldBeAppended: !rTongkongzhijing.isEmpty, punctuationShouldBeAdded: !rTongkong.isEmpty)
        re2 += appendedStringItem("对光反射："+rDuiguangfanshe, punctuationBefore: "，", strShouldBeAppended: !rDuiguangfanshe.isEmpty, punctuationShouldBeAdded: !rTongkong.isEmpty || !rTongkongzhijing.isEmpty)
        re2 += appendedStringItem("晶状体：", punctuationBefore: "，", strShouldBeAppended: !rJingzhuangti.isEmpty || !rJingzhuangtihe.isEmpty || !rHounangxia.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem(rJingzhuangti, punctuationBefore: "", strShouldBeAppended: !rJingzhuangti.isEmpty, punctuationShouldBeAdded: false)
        re2 += appendedStringItem("核："+rJingzhuangtihe, punctuationBefore: "，", strShouldBeAppended: !rJingzhuangtihe.isEmpty, punctuationShouldBeAdded: !rJingzhuangti.isEmpty)
        re2 += appendedStringItem("后囊下："+rHounangxia, punctuationBefore: "，", strShouldBeAppended: !rHounangxia.isEmpty, punctuationShouldBeAdded: !rJingzhuangti.isEmpty || !rJingzhuangtihe.isEmpty)
        re2 += appendedStringItem("玻璃体："+rBoliti, punctuationBefore: "，", strShouldBeAppended: !rBoliti.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("散瞳："+rSantong, punctuationBefore: "，", strShouldBeAppended: !rSantong.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("视网膜："+rShiwangmo, punctuationBefore: "，", strShouldBeAppended: !rShiwangmo.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("眼位："+rYanwei, punctuationBefore: "，", strShouldBeAppended: !rYanwei.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("眼肌检查："+rYanjijiancha, punctuationBefore: "，", strShouldBeAppended: !rYanjijiancha.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("眼球大小："+rYanqiudaxiao, punctuationBefore: "，", strShouldBeAppended: !rYanqiudaxiao.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("眼球突出："+rYanqiutuchu, punctuationBefore: "，", strShouldBeAppended: !rYanqiutuchu.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        re2 += appendedStringItem("眼球凹陷："+rYanqiuaoxian, punctuationBefore: "，", strShouldBeAppended: !rYanqiuaoxian.isEmpty, punctuationShouldBeAdded: !re2.isEmpty)
        
        // 左眼
        var re3 = ""
        re3 += appendedStringItem("眼睑："+lYanjian, punctuationBefore: "", strShouldBeAppended: !lYanjian.isEmpty, punctuationShouldBeAdded: false)
        re3 += appendedStringItem("结膜："+lJiemo, punctuationBefore: "，", strShouldBeAppended: !lJiemo.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("角膜："+lJiaomo, punctuationBefore: "，", strShouldBeAppended: !lJiaomo.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        
        re3 += appendedStringItem("前房", punctuationBefore: "，", strShouldBeAppended: !lZhoubianshendu.isEmpty || !lFangshan.isEmpty || !lFangshuixibao.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("周边深度："+lZhoubianshendu, punctuationBefore: "", strShouldBeAppended: !lZhoubianshendu.isEmpty, punctuationShouldBeAdded: false)
        re3 += appendedStringItem("房闪："+lFangshan, punctuationBefore: "，", strShouldBeAppended: !lFangshan.isEmpty, punctuationShouldBeAdded: !lZhoubianshendu.isEmpty)
        re3 += appendedStringItem("房水细胞："+lFangshuixibao, punctuationBefore: "，", strShouldBeAppended: !lFangshuixibao.isEmpty, punctuationShouldBeAdded: !lZhoubianshendu.isEmpty || !lFangshan.isEmpty)
        
        re3 += appendedStringItem("虹膜："+lHongmo, punctuationBefore: "，", strShouldBeAppended: !lHongmo.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("瞳孔", punctuationBefore: "，", strShouldBeAppended: !lTongkong.isEmpty || !lTongkongzhijing.isEmpty || !lDuiguangfanshe.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem(lTongkong, punctuationBefore: "", strShouldBeAppended: !lTongkong.isEmpty, punctuationShouldBeAdded: false)
        re3 += appendedStringItem("直径："+lTongkongzhijing+" mm", punctuationBefore: "，", strShouldBeAppended: !lTongkongzhijing.isEmpty, punctuationShouldBeAdded: !lTongkong.isEmpty)
        re3 += appendedStringItem("对光反射："+lDuiguangfanshe, punctuationBefore: "，", strShouldBeAppended: !lDuiguangfanshe.isEmpty, punctuationShouldBeAdded: !lTongkong.isEmpty || !lTongkongzhijing.isEmpty)
        re3 += appendedStringItem("晶状体：", punctuationBefore: "，", strShouldBeAppended: !lJingzhuangti.isEmpty || !lJingzhuangtihe.isEmpty || !lHounangxia.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem(lJingzhuangti, punctuationBefore: "", strShouldBeAppended: !lJingzhuangti.isEmpty, punctuationShouldBeAdded: false)
        re3 += appendedStringItem("核："+lJingzhuangtihe, punctuationBefore: "，", strShouldBeAppended: !lJingzhuangtihe.isEmpty, punctuationShouldBeAdded: !lJingzhuangti.isEmpty)
        re3 += appendedStringItem("后囊下："+lHounangxia, punctuationBefore: "，", strShouldBeAppended: !lHounangxia.isEmpty, punctuationShouldBeAdded: !lJingzhuangti.isEmpty || !rJingzhuangtihe.isEmpty)
        re3 += appendedStringItem("玻璃体："+lBoliti, punctuationBefore: "，", strShouldBeAppended: !lBoliti.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("散瞳："+lSantong, punctuationBefore: "，", strShouldBeAppended: !lSantong.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("视网膜："+lShiwangmo, punctuationBefore: "，", strShouldBeAppended: !lShiwangmo.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("眼位："+lYanwei, punctuationBefore: "，", strShouldBeAppended: !lYanwei.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("眼肌检查："+lYanjijiancha, punctuationBefore: "，", strShouldBeAppended: !lYanjijiancha.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("眼球大小："+lYanqiudaxiao, punctuationBefore: "，", strShouldBeAppended: !lYanqiudaxiao.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("眼球突出："+lYanqiutuchu, punctuationBefore: "，", strShouldBeAppended: !lYanqiutuchu.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        re3 += appendedStringItem("眼球凹陷："+lYanqiuaoxian, punctuationBefore: "，", strShouldBeAppended: !lYanqiuaoxian.isEmpty, punctuationShouldBeAdded: !re3.isEmpty)
        
        var re4 = ""
        re4 += appendedStringItem("▹ 初步诊断：\n"+preliminaryDiagnosis, punctuationBefore: "", strShouldBeAppended: !preliminaryDiagnosis.isEmpty, punctuationShouldBeAdded: false)
        re4 += appendedStringItem("▹ 药物治疗：\n"+dosage, punctuationBefore: "\n\n", strShouldBeAppended: !dosage.isEmpty, punctuationShouldBeAdded: !re4.isEmpty)
        if operationPerformed == true {
            re4 += appendedStringItem("▹ 手术治疗：\n", punctuationBefore: "\n\n", strShouldBeAppended: operationPerformed, punctuationShouldBeAdded: !re4.isEmpty)
            re4 += appendedStringItem(operationName, punctuationBefore: "", strShouldBeAppended: !operationName.isEmpty, punctuationShouldBeAdded: false)
            re4 += appendedStringItem("日期："+DateFormatter.localizedString(from: operationDate, dateStyle: .long, timeStyle: .none), punctuationBefore: "，", strShouldBeAppended: true, punctuationShouldBeAdded: !operationName.isEmpty)
        }
        re4 += appendedStringItem("▹ 备注：\n"+comment, punctuationBefore: "\n\n", strShouldBeAppended: !comment.isEmpty, punctuationShouldBeAdded: !re4.isEmpty)
        
        // 连接 -->
        
        re += appendedStringItem("▹ 病情描述：\n"+conditionDescription, punctuationBefore: "", strShouldBeAppended: !conditionDescription.isEmpty, punctuationShouldBeAdded: false)
        re += appendedStringItem("▹ 眼科检查：", punctuationBefore: "\n\n", strShouldBeAppended: !re1.isEmpty || !re2.isEmpty || !re3.isEmpty, punctuationShouldBeAdded: !re.isEmpty)
        re += appendedStringItem(re1, punctuationBefore: "\n", strShouldBeAppended: !re1.isEmpty, punctuationShouldBeAdded: !re1.isEmpty)
        re += appendedStringItem("右眼"+re2, punctuationBefore: "。", strShouldBeAppended: !re2.isEmpty, punctuationShouldBeAdded: !re1.isEmpty)
        re += appendedStringItem("左眼"+re3, punctuationBefore: "。", strShouldBeAppended: !re3.isEmpty, punctuationShouldBeAdded: !re1.isEmpty || !re2.isEmpty)
        re += appendedStringItem(re4, punctuationBefore: "\n\n", strShouldBeAppended: !re4.isEmpty, punctuationShouldBeAdded: !re.isEmpty)
        
        return re
    }
    
    // setter
    func sDate(_ date: Date) {
        let realm = try! Realm()
        try! realm.write {
            self.date = date
        }
    }
    
    // setter
    func sOperationPerformed(_ operationPerformed: Bool) {
        let realm = try! Realm()
        try! realm.write {
            self.operationPerformed = operationPerformed
        }
    }
    
    // setter
    func sOperationDate(_ date: Date) {
        let realm = try! Realm()
        try! realm.write {
            self.operationDate = date
        }
    }
    
    
    // set item
    func s(_ name: String, value: String) {
        let id = self.id + name
        // update FormItem
        let item = FormItem.addItem(id, name: name, value: value)
        // add it to items if it is new
        if items.filter("id == '\(id)'").count == 0 {
            let realm = try! Realm()
            try! realm.write {
                self.items.append(item)
            }
        }
    }
    
    // get item (return empty string if it does exist)
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
        
        removeSubOjectsFromDB()
        
        let realm = try! Realm()
        try! realm.write {
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
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self.photoMemos)
            realm.delete(self.voiceMemos)
            realm.delete(self.items) // delete items
        }
    }
    
    
    func addPhotoMemo(_ originalImage: UIImage, creationDate: Date, shouldScaleDown: Bool) -> Bool {
        
        var pmImageData: Data
        var thumbnailImageData: Data
        
        // scale down image size if needed to save storage space
        if shouldScaleDown == true && (originalImage.size.width > PhotoMemo.imageSize.width || originalImage.size.height > PhotoMemo.imageSize.height) {
            let pmImage = resizeImage(originalImage, targetSize: PhotoMemo.imageSize, forDisplay: false)
            pmImageData = UIImageJPEGRepresentation(pmImage, 1.0)!
            let thumbnailImage = resizeImage(pmImage, targetSize: PhotoMemo.thumbnailSize, forDisplay: true)
            thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0)!
        } else { // original image as pmImage
            pmImageData = UIImageJPEGRepresentation(originalImage, 1.0)!
            let thumbnailImage = resizeImage(originalImage, targetSize: PhotoMemo.thumbnailSize, forDisplay: true)
            thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0)!
        }
        
        // save image data to disk
        return addPhotoMemoByData(pmImageData, thumbnailData: thumbnailImageData, creationDate: creationDate)
    }
    
    func addPhotoMemoByData(_ imageData: Data, thumbnailData: Data, creationDate: Date) -> Bool {
        // save image & thumbnail image data to Documents
        let result1 = saveDataToFile(PhotoMemo.folder, data: imageData, suffix: ".jpg")
        let result2 = saveDataToFile(PhotoMemo.folder, data: thumbnailData, suffix: ".jpg")
        // create and add photoMemo
        if result1.success == true && result2.success == true {
            let photoMemo = PhotoMemo()
            photoMemo.imageFilename = result1.filename
            photoMemo.thumbnailFilename = result2.filename
            photoMemo.creationDate = creationDate
            let realm = try! Realm()
            try! realm.write {
                realm.add(photoMemo, update: true)
                self.photoMemos.append(photoMemo)
            }
        }
        return result1.success && result2.success
    }
    
    func addVoiceMemo(_ voiceData: Data, creationDate: Date) -> (success: Bool, filename:String, urlString: String) {
        // save data to Documents
        let result = saveDataToFile(VoiceMemo.folder, data: voiceData, suffix: ".mp3")
        // create and add photoMemo
        if result.success {
            let voiceMemo = VoiceMemo()
            voiceMemo.audioFilename = result.filename
            voiceMemo.creationDate = creationDate
            voiceMemo.owner = self
            let realm = try! Realm()
            try! realm.write {
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
        return UUID().uuidString
    }
    
    static func addNewRecord(_ forPatient: Patient) -> Record {
        let realm = try! Realm()
        let r = Record()
        r.id = Record.getNewID()
        
        try! realm.write {
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
