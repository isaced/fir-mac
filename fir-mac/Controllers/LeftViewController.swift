//
//  LeftViewController.swift
//  fir-mac
//
//  Created by isaced on 16/6/22.
//
//

import Cocoa
import Kingfisher

class LeftViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var uploadButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    var apps: [FIRApp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FIRLoginComplete, object: nil, queue: nil) { (noti) in
            self.reloadData()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FIRLogoutComplete, object: nil, queue: nil) { (noti) in
            self.reloadData()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FIRSchemeUploadAction, object: nil, queue: nil) { (noti) in
            if let fileUrl = noti.object as? URL {
                self.urlschemeUploadHandle(fileUrl: fileUrl)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if let appDelegate = NSApplication.shared().delegate as? AppDelegate {
                if let prepareUploadUrl = appDelegate.prepareUploadUrl {
                    self.urlschemeUploadHandle(fileUrl: prepareUploadUrl)
                }
            }
        }
        
    }
    
    func reloadData() {
        HTTPManager.shared.fetchApps { (apps) in
            self.apps = apps
            self.tableView.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return apps.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let  view = tableView.make(withIdentifier: "FIRAppTableCellView", owner: self) as! FIRAppTableCellView
        let app = apps[row]
        
        if app.iconURL != nil {
            view.iconImageView.kf.setImage(with: app.iconURL)
        }else{
            view.iconImageView.image = NSImage(named: NSImageNameApplicationIcon)
        }
        
        view.nameTextField.stringValue = app.name
        view.bundleIDTextField.stringValue = app.bundleID
        
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        var app: FIRApp?
        if tableView.selectedRow >= 0 {
            app = apps[tableView.selectedRow]
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.FIRListSelectionChange, object: app)
    }
    
    @IBAction func upload(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["ipa"]
        if openPanel.runModal() == NSModalResponseOK {
            if let url = openPanel.url {
                uploadfile(url: url)
            }
        }
    }
    
    func uploadfile(url: URL) {
        // uploading view controller
        let uploadViewController = self.storyboard?.instantiateController(withIdentifier: "UploadViewController") as! UploadViewController
        self.parent?.presentViewControllerAsSheet(uploadViewController)
        uploadViewController.startParsing()
        Util.parseAppInfo(sourceFile: url, callback: { (appInfo) in
            uploadViewController.stopParsing()
            if let appInfo = appInfo {
                print(appInfo)
                uploadViewController.appInfo = appInfo
                uploadViewController.startUpload()
                HTTPManager.shared.uploadApp(appInfo: appInfo,
                                             encodingRequestSuccess: { (request) in
                                                uploadViewController.cancelActionCallback = {
                                                    request.cancel()
                                                }
                }, uploadProgress: {(progress) in
                    uploadViewController.uploadingProgressIndicator.doubleValue = progress.fractionCompleted
                }, complate: { (success) in
                    print("upload complate")
                    uploadViewController.stopUpload()
                    uploadViewController.showResultStatus(success: success)
                })
            }else{
                print("App 解析出错...")
                uploadViewController.showResultStatus(success: false, message: "App 解析出错")
            }
        })
    }
    
    func urlschemeUploadHandle(fileUrl: URL) {
        // url && login && not uploading
        if HTTPManager.shared.APIToken != nil, !HTTPManager.shared.uploading {
            self.uploadfile(url: fileUrl)
        }
    }
}
