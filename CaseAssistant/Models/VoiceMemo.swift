//
//  VoiceMemo.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


class VoiceMemo: Object {
    dynamic var audioFilename = "" // primary key
    dynamic var creationDate = Date()
    dynamic var caption = ""
    dynamic var owner: Record!
    
    static var folder = "voicememos"
    
    var url: URL? {
        return getURLFromFilename(audioFilename, folderInDocuments: VoiceMemo.folder)
    }
    
    var urlString: String? {
        return url?.absoluteString
    }
    
    /* primary key */
    override class func primaryKey() -> String {
        return "audioFilename"
    }
    
    func saveToDB() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self, update: true)
        }
    }
    
    func removeFromDB() {
        // delete audio file
        if urlString != nil {
            let _ = deleteDataFile(urlString!)
        }
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(self)
        }
    }
    
    // 用于删除与对象相关联的子对象（对象删除后，这些子对象也都应随之删除）
    func removeSubObjectsFromDB() {
        // delete audio files
        if urlString != nil {
            let _ = deleteDataFile(urlString!)
        }
    }
}

