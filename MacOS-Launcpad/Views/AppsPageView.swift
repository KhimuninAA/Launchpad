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
    
    private let itemSize = CGSize(width: 128, height: 128)
    private let offset: CGFloat = 128
    private let padding: CGFloat = 32
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
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        let selfSize = self.frame.size
        
        for item in items {
            item.isHidden = true
        }
        
        let maxSize = getAppsSize(size: selfSize)
        
        let maxY = maxSize.maxY //Int( (selfSize.height - 2 * offset) / (itemSize.height + padding) )
        let topOffset = 0.5 * (selfSize.height - CGFloat(maxY) * (itemSize.height + padding))
        
        let maxX = maxSize.maxX // Int( (selfSize.width - 2 * offset) / (itemSize.width + padding) )
        let leftOffset = 0.5 * (selfSize.width - CGFloat(maxX) * (itemSize.width + padding))
        
        if maxY > 1 && maxX > 1 {
            
            for y in 0...(maxY-1){
                for x in 0...(maxX-1) {
                    let index = y*maxX + x
                    if index < items.count {
                        let itemView = items[index]
                        itemView.isHidden = false
                        let pX = leftOffset + CGFloat(x) * (padding + itemSize.width)
                        let pY = selfSize.height - topOffset - itemSize.height - CGFloat(y) * (padding + itemSize.height)
                        //padding + CGFloat(y) * (padding + itemSize.height)
                        itemView.frame = CGRect(x: pX, y: pY, width: itemSize.width, height: itemSize.height)
                    }
                }
            }
        }
        
    }
    
}
