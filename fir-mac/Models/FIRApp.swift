//
//  FIRApp.swift
//  fir-mac
//
//  Created by isaced on 2017/5/8.
//
//

import Foundation
import SwiftyJSON

class FIRApp {
    var ID: String
    var name : String
    var bundleID: String
    
    var userID: String?
    var type: String?
    var iconURL: URL?
    
    // release
    var masterRelease: FIRAppRelease
    
    // from detail
    var short: String?
    var shortURLString: String {
        if let short = short {
            return "http://fir.im/\(short)"
        }else{
            return ""
        }
    }
    
    var isOpened: Bool?
    var isShowPlaza: Bool?
    var isOwner: Bool?
    var createdAt: Date?
    
    init(json: JSON) {
        self.ID = json["id"].stringValue
        self.name = json["name"].stringValue
        self.bundleID = json["bundle_id"].stringValue
        
        self.userID = json["userID"].string
        self.type = json["type"].string
            
        if let iconURLString = json["icon_url"].string {
            self.iconURL = URL(string: iconURLString)
        }
        
        self.masterRelease = FIRAppRelease(json: json["master_release"])
    }
    
    func fillDetail(with json: JSON?) {
        if let json = json {
            self.short = json["short"].string
            self.isOpened = json["is_opened"].bool
            self.isShowPlaza = json["is_show_plaza"].bool
            self.isOwner = json["is_owner"].bool
            if let createAtTime = json["created_at"].double {
                self.createdAt = Date(timeIntervalSince1970: createAtTime)
            }
        }
    }
}

struct FIRAppRelease {
    var build: String
    var version: String
    var createdAt: Date
    var distributonName: String
    var type: String
    
    init(json: JSON) {
        build = json["build"].stringValue
        version = json["version"].stringValue
        distributonName = json["distribution_name"].stringValue
        createdAt = Date(timeIntervalSince1970: json["created_at"].doubleValue)
        type = json["release_type"].stringValue
    }
}
