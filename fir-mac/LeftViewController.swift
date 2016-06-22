//
//  LeftViewController.swift
//  fir-mac
//
//  Created by isaced on 16/6/22.
//
//

import Cocoa

class LeftViewController: NSViewController, NSTableViewDataSource {
    
    @IBOutlet weak var uploadButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableColumn?.identifier == "icon" {
            return NSImage(named: "airplane")
        } else if tableColumn?.identifier == "name" {
            return "Hello"
        } else {
            return nil
        }
    }
}
