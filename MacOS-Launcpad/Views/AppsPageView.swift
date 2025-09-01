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
    var currentPage: Int = 0
    
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
        updateCount = 0
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
    
    private var updateCount: Int = 0
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        let selfSize = self.frame.size
        if selfSize.width == 0 || selfSize.height == 0 || updateCount > 0 {
            return
        }
        super.resizeSubviews(withOldSize: oldSize)
        
        
//        appsSize = getAppsSize(size: selfSize)
//
//
//        let maxByXItemSize = (selfSize.width)/( (1 + paddingScale) * (CGFloat(appsSize.maxX) + 2) + paddingScale )
//        let maxByYItemSize = (selfSize.height)/( (1 + paddingScale) * (CGFloat(appsSize.maxY) + 2) + paddingScale )
//        itemSize = min(maxByXItemSize, maxByYItemSize)
//        padding = itemSize * paddingScale
//
//        topOffset = 0.5 * (selfSize.height - CGFloat(appsSize.maxY) * (itemSize + padding))
//        leftOffset = 0.5 * (selfSize.width - CGFloat(appsSize.maxX) * (itemSize + padding))
//
//        for item in items {
//            let pos = getPos(by: item.index)
//            let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
//            let pY = selfSize.height - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
//            item.frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
//        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let self = self {
                self.appsSize = self.getAppsSize(size: selfSize)
                if items.count > 0 {
                    updateCount += 1
                }
                
                
                let maxByXItemSize = (selfSize.width)/( (1 + paddingScale) * (CGFloat(appsSize.maxX) + 2) + paddingScale )
                let maxByYItemSize = (selfSize.height)/( (1 + paddingScale) * (CGFloat(appsSize.maxY) + 2) + paddingScale )
                self.itemSize = min(maxByXItemSize, maxByYItemSize)
                self.padding = self.itemSize * self.paddingScale
                
                self.topOffset = 0.5 * (selfSize.height - CGFloat(appsSize.maxY) * (itemSize + padding))
                self.leftOffset = 0.5 * (selfSize.width - CGFloat(appsSize.maxX) * (itemSize + padding))
                
                for item in items {
                    let pos = getPos(by: item.index)
                    let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
                    let pY = selfSize.height - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
                    let thredItemSize = self.itemSize
                    DispatchQueue.main.async {
                        item.frame = CGRect(x: pX, y: pY, width: thredItemSize, height: thredItemSize)
                    }
                }
            }
        }
    }
    
    func getIndex(point: CGPoint) -> Int? {
        return getIndex(x: point.x, y: point.y)
    }
    
    func getIndex(x: CGFloat, y: CGFloat, defaultIndex: Int? = nil) -> Int? {
        if let folderView = folderView {
            return folderView.getIndex(x: x, y: y, defaultIndex: defaultIndex)
        } else {
            let selfSize = self.frame.size
            if (x >= leftOffset && x <= (selfSize.width - leftOffset)) &&
                (y >= topOffset && y <= selfSize.height - topOffset) {
                if (itemSize + padding) > 0 {
                    let c1 = Int((x-leftOffset)/(itemSize + padding))
                    let c2 = Int(((x + padding)-leftOffset)/(itemSize + padding))
                    var col: Int = 0
                    if c1 == c2 {
                        col = c1
                    } else {
                        return defaultIndex
                    }
                    var row: Int = 0
                    let r1 = Int(((selfSize.height - y)-topOffset)/(itemSize + padding))
                    let r2 = Int(((selfSize.height - (y - padding))-topOffset)/(itemSize + padding))
                    if r1 == r2 {
                        row = r1
                    } else {
                        return defaultIndex
                    }
                    return col + appsSize.maxX * row
                } else {
                    return 0
                }
            }
        }
        return nil
    }
    
    func getPos(by index: Int) -> PageItemPos {
        if appsSize.maxX == 0 {
            return PageItemPos(x: 0, y: 0)
        } else {
            let row = Int(index/appsSize.maxX)
            let pos = index - row * appsSize.maxX
            return PageItemPos(x: CGFloat(pos), y: CGFloat(row))
        }
    }
    
    func toFrame(itemView: ItemView) {
        let selfSizeHeight = self.bounds.height
        
        // Находим этот ярлык в этой странице и отрисовываем
        var notAddItem: Bool = true
        for item in items {
            if item.uid == itemView.uid {
                notAddItem = false
                if item.index >= items.count {
                    item.index = items.count - 1
                    onNeedDBSave?()
                }
                
                let pos = getPos(by: item.index)
                let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
                let pY = selfSizeHeight - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
                
                item.animator().frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
            }
        }
        
        // Если такого ярдыка не было - то добавляем и рисуем
        if notAddItem == true {
            if itemView.page != currentPage {
                itemView.page = currentPage
                onNeedDBSave?()
            }
            if itemView.index >= items.count || itemView.index < 0 {
                itemView.index = items.count
                onNeedDBSave?()
            }
            
            
            items.append(itemView)
            let pos = getPos(by: itemView.index)
            let pX = leftOffset + CGFloat(pos.x) * (padding + itemSize)
            let pY = selfSizeHeight - topOffset - itemSize - CGFloat(pos.y) * (padding + itemSize)
            itemView.animator().frame = CGRect(x: pX, y: pY, width: itemSize, height: itemSize)
        }
        
        // Если остался ярлык каторый на странице лишний - то передаем следующей странице
//        item.isHidden = true
//        item.removeFromSuperview()
//        items = items.filter{ $0.uid != item.uid }
//        onFreeMoveItem?(item)
    }
    
    func move(itemView: ItemView, to toIndex: Int?) {
        if isOpenedFolder {
            
        } else {
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
                itemView.index = 100
            }
            onNeedDBSave?()
            
            let selfSizeHeight = self.bounds.height
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                for item in items {
                    if item.isDragged == false {
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
                }
            }) {
            }
        }
    }
    
    func getItem(by index: Int) -> ItemView? {
        for item in items {
            if item.index == index {
                return item
            }
        }
        return nil
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
    
    func selected(style: ItemViewSelectedType, select: ItemView?) {
        if let select = select {
            for item in items {
                if item.index == select.index {
                    item.setStyle(style)
                } else {
                    item.setStyle(.none)
                }
            }
        } else {
            for item in items {
                item.setStyle(style)
            }
        }
    }
    
    var isOpenedFolder: Bool {
        get {
            return (folderView == nil) ? false : true
        }
    }
    
    func closeFolder() {
        if let folderView = folderView {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                
                //let selfSize = self.bounds.size
                folderView.animator().frame = folderView.startFrame
                folderView.animator().layer?.backgroundColor = NSColor.clear.cgColor
                for item in items {
                    if item.isDragged == false {
                        item.animator().isHidden = false
                        item.setStyle(.none)
                    }
                }
            }) {
                self.folderView?.removeFromSuperview()
                self.folderView = nil
            }
        }
    }
    
    private var folderView: FolderView?
    func openFolder(folder: ItemView) {
        //если уже открыта папка - еще одну открыть нельзя
        if let _ = folderView {
            return
        }
        
        folderView = FolderView(frame: .zero)
        if let folderView = folderView {
            addSubview(folderView)
            let folderViewFrame = folder.getFrameImage()
            folderView.startFrame = folderViewFrame
            
            folderView.topOffset = 2 * padding //topOffset
            folderView.leftOffset = 2 * padding //leftOffset
            folderView.appsSize = appsSize
            folderView.itemSize = itemSize
            folderView.padding = padding
            
            folderView.frame = folderViewFrame
            folderView.onNeedClose = { [weak self] in
                self?.closeFolder()
            }
            
            //newItem.index = 0
            let folerItems = [folder]
            folderView.setItems(items: folerItems)
            
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                
                let selfSize = self.bounds.size
                let row: Int = 1
                let newFolderViewHeight = 4 * padding + CGFloat(row) * (itemSize + padding) - padding
                let newFolderViewTop = 0.5 * (selfSize.height - newFolderViewHeight)
                let newFolderViewLeft = leftOffset - 2 * padding
                let newFolderViewWidth = selfSize.width - 2 * newFolderViewLeft
                folderView.animator().frame = CGRect(x: newFolderViewLeft, y: newFolderViewTop, width: newFolderViewWidth, height: newFolderViewHeight)
                folderView.animator().layer?.backgroundColor = NSColor.lightGray.cgColor
                for item in items {
                    if item.isDragged == false {
                        item.animator().isHidden = true
                    }
                }
            }) {
            }
        }
    }
}
