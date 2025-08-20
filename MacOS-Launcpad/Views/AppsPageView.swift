//
//  AppsPageView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 16.08.2025.
//

import AppKit

struct ViewAppsSize{
    let maxY: Int
    let maxX: Int
}

struct PageItemPos{
    let x: CGFloat
    let y: CGFloat
}

class AppsPageView: NSView{
    var onNeedDBSave: (() -> Void)?
    var onFreeMoveItem: ((_ item: ItemView) -> Void)?
    private var items: [ItemView]!
    
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
        items = [ItemView]()
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func getMaxAppsCount(size: CGSize) -> Int {
        let appSize = getAppsSize(size: size)
        return appSize.maxX * appSize.maxY
    }
    
    func getAppsSize(size: CGSize) -> ViewAppsSize {
        let maxY = 5 //Int( (size.height - 2 * offset) / (itemSize.height + padding) )
        let maxX = 7 //Int( (size.width - 2 * offset) / (itemSize.width + padding) )
        return ViewAppsSize(maxY: maxY, maxX: maxX)
    }
    
    func setApps(_ apps: [PageItemData]) {
        for app in apps{
            let itemView = ItemView(frame: .zero)
            itemView.setData(app)
            self.addSubview(itemView)
            items.append(itemView)
        }
        resizeSubviews(withOldSize: bounds.size)
    }
    
    private var topOffset: CGFloat = 0
    private var leftOffset: CGFloat = 0
    private let paddingScale: CGFloat = 0.4 //0.6
    private var appsSize: ViewAppsSize = ViewAppsSize(maxY: 0, maxX: 0)
    private var itemSize: CGFloat = 0
    private var padding: CGFloat = 0
    
    override var frame: NSRect {
                didSet {
                    resizeSubviews(withOldSize: self.bounds.size)
                }
            }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        let selfSize = self.frame.size
        
        for item in items {
            item.isHidden = true
        }
        
        appsSize = getAppsSize(size: selfSize)
        
        let maxByXItemSize = (selfSize.width)/( (1 + paddingScale) * (CGFloat(appsSize.maxX) + 2) + paddingScale )
        let maxByYItemSize = (selfSize.height)/( (1 + paddingScale) * (CGFloat(appsSize.maxY) + 2) + paddingScale )
        itemSize = min(maxByXItemSize, maxByYItemSize)
        padding = itemSize * paddingScale
        
        topOffset = 0.5 * (selfSize.height - CGFloat(appsSize.maxY) * (itemSize + padding))
        leftOffset = 0.5 * (selfSize.width - CGFloat(appsSize.maxX) * (itemSize + padding))
        
        for item in items {
            item.isHidden = false
            let pos = getPos(by: item.index)
            let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
            let pY = selfSize.height - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
            item.frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
        }
    }
    
    func getIndex(x: CGFloat, y: CGFloat) -> Int? {
        let selfSize = self.frame.size
        if (x >= leftOffset && x <= (selfSize.width - leftOffset)) &&
            (y >= topOffset && y <= selfSize.height - topOffset) {
            if (itemSize + padding) > 0 {
                let col = Int((x-leftOffset)/(itemSize + padding))
                let row = Int(((selfSize.height - y)-topOffset)/(itemSize + padding))
                return col + appsSize.maxX * row
            } else {
                return 0
            }
        }
        return nil
    }
    
    func getPos(by index: Int) -> PageItemPos {
        let row = Int(index/appsSize.maxX)
        let pos = index - row * appsSize.maxX
        return PageItemPos(x: CGFloat(pos), y: CGFloat(row))
    }
    
    func toFrame(itemView: ItemView) {
        let selfSizeHeight = self.bounds.height
        var notAddItem: Bool = true
        for item in items {
            if item.uid == itemView.uid {
                notAddItem = false
                let pos = getPos(by: item.index)
                let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
                let pY = selfSizeHeight - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
                if pos.y < 5 {
                    item.isHidden = false
                    item.animator().frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
                } else {
                    item.isHidden = true
                    item.removeFromSuperview()
                    items = items.filter{ $0.uid != item.uid }
                    onFreeMoveItem?(item)
                }
            }
        }
        if notAddItem == true {
            items.append(itemView)
            let pos = getPos(by: itemView.index)
            let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
            let pY = selfSizeHeight - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
            itemView.animator().frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
        }
    }
    
    func move(itemView: ItemView, to toIndex: Int?) {
        items = items.sorted { $0.index < $1.index }
        var index = 0
        
        if let toIndex = toIndex {
            for item in items {
                if item.isDragged == false {
                    if index == toIndex {
                        index += 1
                    }
                    item.index = index
                    index += 1
                } else {
                    item.index = toIndex
                }
            }
        } else {
            for item in items {
                if item.isDragged == false {
                    item.index = index
                    index += 1
                }
            }
        }
        onNeedDBSave?()
        
        let selfSizeHeight = self.bounds.height
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            for item in items {
                let pos = getPos(by: item.index)
                let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
                let pY = selfSizeHeight - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
                if pos.y < 5 {
                    item.isHidden = false
                    item.animator().frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
                } else {
                    item.isHidden = true
                }
            }
        }) {
        }
        
    }
    
    func getItem(by location: NSPoint) -> ItemView? {
        for item in items {
            if item.isHidden == false {
                if NSPointInRect(location, item.frame) {
                    return item
                }
            }
        }
        return nil
    }
    
    func getTopOffset() -> CGFloat {
        return topOffset
    }
    
}
