//
//  FIRAppTableCellView.swift
//  fir-mac
//
//  Created by isaced on 2017/5/8.
//
//

import Cocoa

class FIRAppTableCellView: NSTableCellView {

    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var bundleIDTextField: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
