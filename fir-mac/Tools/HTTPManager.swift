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
import SwiftyJSON

enum UploadAppType: String {
    case ios = "ios"
    case android = "android"
}

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
        
        Alamofire.request("http://api.fir.im/apps/\(app.ID)", method: .post, parameters: ["api_token": APIToken]).responseSwiftyJSON { (response) in
            app.fillDetail(with: response.value)
            callback()
        }
    }
    
    func prepareUploadApp(bundleID: String, type:UploadAppType, callback:@escaping ((JSON?)->Void)) {
        guard let APIToken = APIToken else {
            callback(nil)
            return
        }
        
        Alamofire.request("http://api.fir.im/apps", method: .post, parameters: ["api_token": APIToken, "bundle_id":bundleID,"type": type.rawValue]).responseSwiftyJSON { (response) in
            callback(response.value)
        }
    }
    
    func uploadFile(uploadUrl: String,
                    qiniuKey: String,
                    qiniuToken: String,
                    file: Data?,
                    fileURL: URL?,
                    appName: String? = nil,
                    version: String? = nil,
                    build: String? = nil,
                    type: String? = nil,
                    uploadProgress: Request.ProgressHandler?,
                    complate: @escaping ((_ success: Bool)->Void)) {
        
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(qiniuKey.data(using: .utf8)!, withName: "key") // mimeType: "text/plain"
            multipartFormData.append(qiniuToken.data(using: .utf8)!, withName: "token")
            if let file = file {
                multipartFormData.append(file, withName: "file")
            }
            if let fileURL = fileURL {
                multipartFormData.append(fileURL, withName: "file")
            }
            if let appName = appName {
                multipartFormData.append(appName.data(using: .utf8)!, withName: "x:name")
            }
            if let version = version {
                multipartFormData.append(version.data(using: .utf8)!, withName: "x:version")
            }
            if let build = build {
                multipartFormData.append(build.data(using: .utf8)!, withName: "x:build")
            }
            if let type = type {
                multipartFormData.append(type.data(using: .utf8)!, withName: "x:release_type")
            }
        }, to: uploadUrl) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (progress) in
                    uploadProgress?(progress)
                })
                upload.responseJSON { response in
                    debugPrint(response)
                    complate(true)
                }
            case .failure(let encodingError):
                print(encodingError)
                complate(false)
            }
        }
    }
    
    func uploadApp(appInfo: ParsedAppInfo, uploadProgress: Request.ProgressHandler?, complate: @escaping ((_ success: Bool)->Void)) {
        guard let bundleID = appInfo.bundleID,
            let appName = appInfo.appName,
            let version = appInfo.version,
            let build = appInfo.build,
            let type = appInfo.type,
            let souceFile = appInfo.sourceFileURL else {
            complate(false)
            return
        }

        prepareUploadApp(bundleID: bundleID, type: type) { (response) in
            if let iconQiniuKey = response?.dictionary?["cert"]?["icon"]["key"].string,
                let iconQiniuToken = response?.dictionary?["cert"]?["icon"]["token"].string,
                let iconUploadUrl = response?.dictionary?["cert"]?["icon"]["upload_url"].url?.absoluteString,
                let binaryQiniuKey = response?.dictionary?["cert"]?["binary"]["key"].string,
                let binaryQiniuToken = response?.dictionary?["cert"]?["binary"]["token"].string,
                let binaryUploadUrl = response?.dictionary?["cert"]?["binary"]["upload_url"].url?.absoluteString {
                // success
                
                // upload icon
                if let iconData = appInfo.iconImage?.tiffRepresentation(using: .JPEG, factor: 0.9) {
                    self.uploadFile(uploadUrl: iconUploadUrl,
                               qiniuKey: iconQiniuKey,
                               qiniuToken: iconQiniuToken,
                               file: nil,
                               fileURL: appInfo.iconImageURL!,
                               uploadProgress: nil, complate: { (success) in
                                if !success {
                                    print("icon upload error...")
                                }
                    })
                }
                
                // upload package
                self.uploadFile(uploadUrl: binaryUploadUrl,
                                qiniuKey: binaryQiniuKey,
                                qiniuToken: binaryQiniuToken,
                                file: nil,
                                fileURL: souceFile,
                                appName: appName,
                                version: version,
                                build: build,
                                type: type.rawValue,
                                uploadProgress: { (p) in
                    uploadProgress?(p)
                }, complate: { (success) in
                    complate(success)
                })
                
            }else{
                complate(false)
            }
        }
    }
}
