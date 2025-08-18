//
//  KhPageDotView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 17.08.2025.
//

import AppKit

class KhPageDotView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                layer?.backgroundColor = NSColor.gray.cgColor
            } else {
                layer?.backgroundColor = NSColor.white.cgColor
            }
        }
    }
    
    private func initView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor
        layer?.borderColor = NSColor.white.cgColor
        layer?.borderWidth = 1
        layer?.masksToBounds = true
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        let radius = newSize.width * 0.5
        layer?.cornerRadius = radius
    }
}
