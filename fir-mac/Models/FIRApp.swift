//
//  FIRApp.swift
//  fir-mac
//
//  Created by isaced on 2017/5/8.
//
//

import Foundation
import SwiftyJSON

class FIRAPP {
    var ID: String
    var name : String
    var bundleID: String
    
    var userID: String?
    var type: String?
    var iconURL: URL?
    
    init(json: JSON) {
        self.ID = json["id"].stringValue
        self.name = json["name"].stringValue
        self.bundleID = json["bundle_id"].stringValue
        
        self.userID = json["userID"].string
        self.type = json["type"].string
            
        if let iconURLString = json["icon_url"].string {
            self.iconURL = URL(string: iconURLString)
        }
    }
}
