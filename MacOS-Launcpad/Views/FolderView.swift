//
//  FolderView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 28.08.2025.
//

import AppKit

class FolderView: NSView {
    var startFrame: CGRect = .zero
    private var items: [ItemView]!
    
    var topOffset: CGFloat = 0
    var leftOffset: CGFloat = 0
    var appsSize: ViewAppsSize = ViewAppsSize(maxY: 0, maxX: 0)
    var itemSize: CGFloat = 0
    var padding: CGFloat = 0
    
    var onNeedClose: (() -> Void)?
    
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
        layer?.backgroundColor = NSColor.lightGray.withAlphaComponent(0.5).cgColor
        layer?.cornerRadius = 16
        
        items = [ItemView]()
    }
    
    func setItems(items: [ItemView]) {
        self.items = items
        for item in items {
            addSubview(item)
            item.isHidden = false
            item.setStyle(.none)
        }
        resizeSubviews(withOldSize: self.bounds.size)
    }
    
    private var isPosInFolder: Bool = false
    private func detectMoveOutFolder(point: NSPoint) {
        if NSPointInRect(point, self.frame) {
            isPosInFolder = true
        }
        if !NSPointInRect(point, outFrame()) {
            if isPosInFolder {
                onNeedClose?()
            }
        }
    }
    
    func getIndex(x: CGFloat, y: CGFloat, defaultIndex: Int? = nil) -> Int? {
        let point = NSPoint(x: x, y: y)
        detectMoveOutFolder(point: point)
        
        return nil
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        let selfSize = self.frame.size
        if selfSize.width == 0 || selfSize.height == 0 {
            return
        }
        super.resizeSubviews(withOldSize: oldSize)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let self = self {
                for item in items {
                    let pos = getPos(by: item.index)
                    let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
                    let pY = selfSize.height - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
                    let thredItemSize = self.itemSize
                    DispatchQueue.main.async { [weak self] in
                        item.frame = CGRect(x: pX, y: pY, width: thredItemSize, height: thredItemSize)
                        item.isHidden = false
                        //self?.addSubview(item)
                    }
                }
            }
        }
    }
}

extension FolderView {
    private func outFrame() -> CGRect {
        let padding: CGFloat = 70
        return CGRect(x: self.frame.origin.x - padding, y: self.frame.origin.y - padding, width: self.frame.width + 2 * padding, height: self.frame.height + 2 * padding)
    }
    
    private func getPos(by index: Int) -> PageItemPos {
        if appsSize.maxX == 0 {
            return PageItemPos(x: 0, y: 0)
        } else {
            let row = Int(index/appsSize.maxX)
            let pos = index - row * appsSize.maxX
            return PageItemPos(x: CGFloat(pos), y: CGFloat(row))
        }
    }
}
