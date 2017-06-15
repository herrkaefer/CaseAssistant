//
//  PhotoMemo.swift
//  CaseAssistant
//
//  Created by HerrKaefer on 2017/5/18.
//  Copyright © 2017年 HerrKaefer. All rights reserved.
//

import Foundation
import RealmSwift


class PhotoMemo: Object {
    dynamic var imageFilename: String = "" // primary key, image filename
    dynamic var thumbnailFilename: String = "" // thumbnail image filename
    dynamic var creationDate = Date()
    dynamic var caption = "" // 图片描述文字
    
    // ---- End of data defination ----//
    
    
    /* computed properties */
    
    // 如果record还没保存到realm，则会返回nil
    var owner: Record {
        return LinkingObjects(fromType: Record.self, property: "photoMemos").first!
    }
    
    var url: URL? {
        return getURLFromFilename(imageFilename, folderInDocuments: PhotoMemo.folder)
    }
    
    var urlForThumbnail: URL? {
        return getURLFromFilename(thumbnailFilename, folderInDocuments: PhotoMemo.folder)
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
    
    func sCaption(_ caption: String) {
        let realm = try! Realm()
        try! realm.write {
            self.caption = caption
        }
    }
    
    func removeFromDB() {
        let realm = try! Realm()
        
        removeSubObjectsFromDB()
        
        try! realm.write {
            realm.delete(self)
        }
        
    }
    
    // 删除与对象相关联的子对象（对象删除后，这些子对象也都应随之删除）
    func removeSubObjectsFromDB() {
        // delete image & thumbnail files
        if urlString != nil {
            let _ = deleteDataFile(urlString!)
        }
        if urlStringForThumbnail != nil {
            let _ = deleteDataFile(urlStringForThumbnail!)
        }
    }
    
    /* type properties */
    
    static let folder = "photomemos" // folder name in Documents
    static let imageSize = CGSize(width: 1024.0, height: 1024.0)
    static let thumbnailSize = CGSize(width: 150.0, height: 150.0) // for display in collection view (scale should be considered)
    
    static var totalNumberOfPhotoMemos: Int {
        let realm = try! Realm()
        return realm.objects(PhotoMemo.self).count
    }
}
