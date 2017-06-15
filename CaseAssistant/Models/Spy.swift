//
//  Spy.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


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
        
        s.version = CaseApp.version
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(s, update: true)
        }
        return s
    }
}
