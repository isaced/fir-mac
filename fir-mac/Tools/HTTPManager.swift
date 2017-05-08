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
    
    func fetchApps(callback: @escaping ((_ apps: [FIRApp])->Void)) {
        guard let APIToken = APIToken else {
            callback([])
            return
        }
        
        Alamofire.request("http://api.fir.im/apps", parameters: ["api_token": APIToken]).responseSwiftyJSON { (response) in
            var apps: [FIRApp] = []
            if let items = response.value?["items"].array {
                for item in items {
                    let app = FIRApp(json: item)
                    apps.append(app)
                }
            }
            callback(apps)
        }
    }
    
    func fatchAppDetail(app: FIRApp, callback: @escaping (()->Void)) {
        guard let APIToken = APIToken else {
            callback()
            return
        }
        
        Alamofire.request("http://api.fir.im/apps/\(app.ID)", parameters: ["api_token": APIToken]).responseSwiftyJSON { (response) in
            app.fillDetail(with: response.value)
            callback()
        }
    }
}
