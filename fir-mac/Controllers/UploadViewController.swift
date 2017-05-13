//
//  UploadViewController.swift
//  fir-mac
//
//  Created by isaced on 2017/5/13.
//
//

import Cocoa

class UploadViewController: NSViewController {

    @IBOutlet weak var parsingView: NSView!
    @IBOutlet weak var infoView: NSView!

    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var appIconImageView: NSImageView!
    @IBOutlet weak var parsingIndicator: NSProgressIndicator!
    
    @IBOutlet weak var uploadingProgressIndicator: NSProgressIndicator!
    var appInfo: ParsedAppInfo? {
        didSet{
            appNameLabel.stringValue = ""
            
            if let appName = appInfo?.appName {
                appNameLabel.stringValue = appNameLabel.stringValue + appName
            }
            if let version = appInfo?.version {
                appNameLabel.stringValue = appNameLabel.stringValue + " \(version)"
            }
            if let build = appInfo?.build {
                appNameLabel.stringValue = appNameLabel.stringValue + " Build(\(build))"
            }
            
            appIconImageView.image = appInfo?.iconImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadingProgressIndicator.usesThreadedAnimation = true
    }
    
    func startParsing() {
        infoView.isHidden = true
        parsingView.isHidden = false
        parsingIndicator.startAnimation(self)
    }
    
    func stopParsing() {
        parsingIndicator.stopAnimation(self)
        self.parsingView.isHidden = true
    }
    
    func startUpload() {
        parsingView.isHidden = true
        infoView.isHidden = false
    }
    
    func stopUpload() {
        
    }
}
