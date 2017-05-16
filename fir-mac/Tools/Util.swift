//
//  Util.swift
//  fir-mac
//
//  Created by isaced on 2017/5/8.
//
//

import Foundation
import Cocoa

enum UploadAppIOSReleaseType: String {
    case adhoc = "Adhoc"
    case inHouse = "Inhouse"
}
struct ParsedAppInfo: CustomStringConvertible {
    
    var appName: String?
    var bundleID: String?
    var version: String?
    var build: String?
    var type: UploadAppType?
    var iosReleaseType: UploadAppIOSReleaseType?
    
    var iconImage: NSImage?

    var sourceFileURL: URL?
    
    var description: String {
        return "--- App Info --- \nApp Name: \((appName ?? "")) \nBundle ID: \((bundleID ?? "")) \nVersion: \((version ?? "")) \nBuild: \((build ?? ""))\nType: \(type?.rawValue ?? "")\nIcon: \(iconImage != nil ? "YES":"NO") \n--- App Info ---"
    }
}

class Util {
    
    //MARK: Constants
    fileprivate static let mktempPath = "/usr/bin/mktemp"
    fileprivate static let unzipPath = "/usr/bin/unzip"
    fileprivate static let defaultsPath = "/usr/bin/defaults"
    
    static func parseAppInfo(sourceFile: URL, callback:((_ : ParsedAppInfo?)->Void)) {
        if sourceFile.pathExtension.lowercased() == "ipa" {
            // Create temp folder
            if let tempFolder = makeTempFolder() {
                print("--- makeTempFolder : \(tempFolder)")
                
                // unzip
                unzip(sourceFile.path, outputPath: tempFolder.path)
                print("--- unzip...")
                    
                // Payload Path
                let payloadPath = tempFolder.appendingPathComponent("Payload")
                if payloadPath.isExists() {
                    
                    // Loop payload directory
                    do {
                        let files = try FileManager.default.contentsOfDirectory(atPath: payloadPath.path)
                        for file in files {
                            let filePath = payloadPath.appendingPathComponent(file)
                            if !filePath.isExists(dir: true) { continue }
                            if filePath.pathExtension.lowercased() != "app" { continue}
                            
                            
                            // Got info.plist
                            let infoPlistPath = filePath.appendingPathComponent("Info.plist")
                            
                            if let data = try? Data(contentsOf: infoPlistPath) {
                                if let plist = (try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)) as? [String: Any] {
                                    var info = ParsedAppInfo()
                                    info.bundleID = plist["CFBundleIdentifier"] as? String
                                    info.version = plist["CFBundleShortVersionString"] as? String
                                    info.build = plist["CFBundleVersion"] as? String
                                    info.appName = plist["CFBundleDisplayName"] as? String
                                    info.type = .ios
                                    info.sourceFileURL = sourceFile
                                    
                                    // icon
                                    let iconNames = ["AppIcon60x60@3x.png",
                                                     "AppIcon60x60@2x.png",
                                                     "AppIcon57x57@3x.png",
                                                     "AppIcon57x57@2x.png",
                                                     "AppIcon40x40@3x.png",
                                                     "AppIcon40x40@2x.png"]
                                    
                                    for iconName in iconNames {
                                        let iconFile = filePath.appendingPathComponent(iconName, isDirectory: false)
                                        if iconFile.isExists() {
                                            info.iconImage = NSImage(contentsOfFile: iconFile.path)
                                            break
                                        }
                                    }
                                    callback(info)
                                }
                            }

                            // clean
                            cleanTempDir(path: tempFolder)
                            return
                        }
                    } catch {
                        print("loop file error...")
                    }
                }else{
                    print("can't find payload...")
                }
                
                // clean
                cleanTempDir(path: tempFolder)
            }else{
                print("make temp dir error...")
            }
        }else{
            print("pathExtension error...")
        }
        callback(nil)
    }
    
    static func cleanTempDir(path: URL) {
        try! FileManager.default.removeItem(atPath: path.path)
        print("--- clean temp dir...")
    }
    
    static func makeTempFolder() -> URL? {
        let tempTask = Process().execute(mktempPath, workingDirectory: nil, arguments: ["-d"])
        let url = URL(fileURLWithPath: tempTask.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), isDirectory: true)
        return url
    }

    static func unzip(_ inputFile: String, outputPath: String) {
        _ = Process().execute(unzipPath, workingDirectory: nil, arguments: ["-q", "-o", inputFile,"-d",outputPath])
    }
    
    static func defaultsRead(item: String, plistFilePath: String) -> String {
        let output = Process().execute(defaultsPath, workingDirectory: nil, arguments: ["read", plistFilePath, item]).output
        return output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    static func generateQRCode(from string: String) -> NSImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.applying(transform) {
                let rep = NSCIImageRep(ciImage: output)
                let nsImage = NSImage(size: rep.size)
                nsImage.addRepresentation(rep)
                return nsImage
            }
        }
        
        return nil
    }
}


extension URL {
    func isExists(dir: Bool = false) -> Bool {
        if dir {
            var isDirectory: ObjCBool = true
            return FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory)
        }else{
            return FileManager.default.fileExists(atPath: self.path)
        }
    }
}
