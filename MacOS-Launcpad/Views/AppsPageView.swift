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

struct PageItemData{
    let id: String
    let name: String
    let page: Int
    let index: Int
    let app: AppsInfo?
    let apps: [AppsInfo]?
}

class AppsPageView: NSView{
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
    private let paddingScale: CGFloat = 0.6
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        let selfSize = self.frame.size
        
        for item in items {
            item.isHidden = true
        }
        
        let maxSize = getAppsSize(size: selfSize)
        
        let maxByXItemSize = (selfSize.width)/( (1 + paddingScale) * (CGFloat(maxSize.maxX) + 2) + paddingScale )
        let maxByYItemSize = (selfSize.height)/( (1 + paddingScale) * (CGFloat(maxSize.maxY) + 2) + paddingScale )
        let itemSize = min(maxByXItemSize, maxByYItemSize)
        let padding = itemSize * paddingScale
        
        topOffset = 0.5 * (selfSize.height - CGFloat(maxSize.maxY) * (itemSize + padding))
        leftOffset = 0.5 * (selfSize.width - CGFloat(maxSize.maxX) * (itemSize + padding))
        
        if maxSize.maxY > 1 && maxSize.maxX > 1 {
            
            for y in 0...(maxSize.maxY-1){
                for x in 0...(maxSize.maxX-1) {
                    let index = y*maxSize.maxX + x
                    if index < items.count {
                        let itemView = items[index]
                        itemView.isHidden = false
                        let pX = leftOffset + CGFloat(x) * (padding + itemSize)
                        let pY = selfSize.height - topOffset - itemSize - CGFloat(y) * (padding + itemSize)
                        //padding + CGFloat(y) * (padding + itemSize.height)
                        itemView.frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
                    }
                }
            }
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
