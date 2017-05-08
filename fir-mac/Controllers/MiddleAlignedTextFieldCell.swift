//
//  MiddleAlignedTextFieldCell.swift
//  fir-mac
//
//  Created by isaced on 16/6/22.
//
//

import Cocoa

class MiddleAlignedTextFieldCell: NSTextFieldCell {

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleFrame: NSRect = super.titleRect(forBounds: rect)
        let titleSize: NSSize = self.attributedStringValue.size()
        titleFrame.origin.y = rect.origin.y - 0.5 + (rect.size.height - titleSize.height) / 2.0
        return titleFrame
    }
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let titleRect: NSRect = self.titleRect(forBounds: cellFrame)
        self.attributedStringValue.draw(in: titleRect)
    }
}
