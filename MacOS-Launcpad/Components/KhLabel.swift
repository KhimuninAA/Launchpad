//
//  KhLabel.swift
//  USB-HID-3
//
//  Created by Алексей Химунин on 07.11.2020.
//

import Foundation
import Cocoa

class KhLabel: NSTextField{
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView(){
        isBezeled = false
        drawsBackground = false
        isEnabled = false
        isSelectable = false
    }
}

extension KhLabel {
    func textSize() -> NSSize {

        // Get the font used by the text field
        guard let font = self.font else {
            // Fallback to a default font if the text field's font is nil
            return stringValue.size(withAttributes: [.font: NSFont.systemFont(ofSize: NSFont.systemFontSize)])
        }

        // Create an attributed string with the text field's string value and font
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let attributedString = NSAttributedString(string: stringValue, attributes: attributes)

        // Calculate the bounding box for the attributed string
        // You might want to specify a maximum width if the text field wraps
        let options: NSString.DrawingOptions = .usesLineFragmentOrigin
        let boundingBox = attributedString.boundingRect(with: NSSize(width: self.bounds.width, height: .greatestFiniteMagnitude), options: options, context: nil)

        // Return the size component of the bounding box
        return boundingBox.size
    }
}
