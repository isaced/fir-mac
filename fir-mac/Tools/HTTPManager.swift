//
//  HTTPManager.swift
//  fir-mac
//
//  Created by isaced on 2017/5/8.
//
//

import Foundation
import Alamofire
import Alamofire_SwiftyJSON

class HTTPManager {
    
    static let shared = HTTPManager()
    
    var APIToken: String?
    
    func fetchApps(callback: @escaping ((_ apps: [FIRAPP])->Void)) {
        guard let APIToken = APIToken else {
            callback([])
            return
        }
        
        Alamofire.request("http://api.fir.im/apps", parameters: ["api_token": APIToken]).responseSwiftyJSON { (response) in
            var apps: [FIRAPP] = []
            if let items = response.value?["items"].array {
                for item in items {
                    let app = FIRAPP(json: item)
                    apps.append(app)
                }
            }
            callback(apps)
        }
    }
}
