//
//  FormItem.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


// save (name: String, value: String) pair. Note: name is not unique, id is.
class FormItem: Object {
    dynamic var id: String = ""
    dynamic var name = ""
    dynamic var value = "" // empty means nil
    //    dynamic var isNil = false
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    static func addItem(_ id: String, name: String, value: String) -> FormItem {
        let item = FormItem()
        item.id = id
        item.name = name
        item.value = value
        
        // save
        let realm = try! Realm()
        try! realm.write {
            realm.add(item, update: true)
        }
        return item
    }
    
    static func getValueById(_ id: String) -> String? {
        let realm = try! Realm()
        if let q = realm.object(ofType: FormItem.self, forPrimaryKey: id) {
            return q.value
        } else {
            return nil
        }
    }
}

