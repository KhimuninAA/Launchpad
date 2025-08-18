//
//  KhSearchFieldNew.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 18.08.2025.
//

import AppKit

class KhSearchFieldNew: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        isBezeled = false
        focusRingType = .none
        
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.white.cgColor
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        let selfSize = self.frame.size
        
        layer?.cornerRadius = selfSize.height * 0.5
    }
}
