//
//  AppDetailViewController.swift
//  fir-mac
//
//  Created by isaced on 2017/5/8.
//
//

import Cocoa
import Kingfisher

class AppDetailViewController: NSViewController {

    @IBOutlet weak var appNameTextField: NSTextField!
    @IBOutlet weak var appIDTextField: NSTextField!
    @IBOutlet weak var bundleIDTextField: NSTextField!
    @IBOutlet weak var shortLinkTextField: NSTextField!
    @IBOutlet weak var iconImageView: NSImageView!
    
    @IBOutlet weak var shortLinkGoButton: NSButton!
    @IBOutlet weak var isOpenedSwitch: NSButton!
    @IBOutlet weak var isShowPlazaSwitch: NSButton!
    
    @IBOutlet weak var releaseVersionTextField: NSTextField!
    @IBOutlet weak var releaseBuildTextField: NSTextField!
    @IBOutlet weak var releaseCreatedAtTextField: NSTextField!
    @IBOutlet weak var releaseDistributionNameTextField: NSTextField!
    @IBOutlet weak var releaseTypeTextField: NSTextField!
    
    var app: FIRApp? {
        didSet{
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImageView.wantsLayer = true
        iconImageView.layer?.cornerRadius = 10
        iconImageView.layer?.masksToBounds = true
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FIRListSelectionChange, object: nil, queue: nil) { (noti) in
            if let app = noti.object as? FIRApp {
                self.app = app
                self.loadData()
                
                if app.short == nil {
                    HTTPManager.shared.fatchAppDetail(app: app, callback: {
                        self.loadData()
                    })
                }
            }
        }
    }
    
    func loadData() {
        appNameTextField.stringValue = app?.name ?? ""
        appIDTextField.stringValue = app?.ID ?? ""
        bundleIDTextField.stringValue = app?.bundleID ?? ""
        shortLinkTextField.stringValue = app?.shortURLString ?? ""
        isOpenedSwitch.state = (app?.isOpened ?? false) ? 1 : 0
        isShowPlazaSwitch.state = (app?.isShowPlaza ?? false) ? 1 : 0
        
        releaseBuildTextField.stringValue = app?.masterRelease.build ?? ""
        releaseVersionTextField.stringValue = app?.masterRelease.version ?? ""
        releaseTypeTextField.stringValue = app?.masterRelease.type ?? ""
        releaseDistributionNameTextField.stringValue = app?.masterRelease.distributonName ?? ""
        
        if let date = app?.masterRelease.createdAt {
            let dateformatter = DateFormatter()
            dateformatter.dateStyle = .short
            dateformatter.timeStyle = .short
            releaseCreatedAtTextField.stringValue = dateformatter.string(from: date)
        }
        
        iconImageView.kf.setImage(with: app?.iconURL)
        
        
        // short link go button position
        if app?.short == nil {
            shortLinkGoButton.isHidden = true
        }else{
            shortLinkGoButton.isHidden = false
            shortLinkTextField.sizeToFit()
            shortLinkGoButton.frame = NSRect(x: shortLinkTextField.frame.maxX + 10,
                                             y: shortLinkTextField.frame.minY,
                                             width: shortLinkGoButton.frame.width,
                                             height: shortLinkGoButton.frame.height)
        }
    }
    
    @IBAction func shortLinkGoAction(_ sender: NSButton) {
        if let urlString = self.app?.shortURLString {
            if let url = URL(string: urlString) {
                NSWorkspace.shared().open(url)
            }
        }
    }
}
