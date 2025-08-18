//
//  ItemView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 16.08.2025.
//

import AppKit

protocol ItemData{
    var name: String { get }
}

class ItemView: NSView {
    private var itemData: PageItemData?
    private var imageView: NSImageView!
    private var nameLabelView: KhLabel!
    
    func getPath() -> String? {
        if let itemData = itemData?.app as? AppsInfo {
            return itemData.path
        }
        return nil
    }
    
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
        
        
        layer?.cornerRadius = 16
        layer?.borderColor = NSColor.darkGray.cgColor
        layer?.borderWidth = 1
        layer?.masksToBounds = false
        
        
        imageView = NSImageView(frame: .zero)
        imageView.imageScaling = .scaleAxesIndependently
        addSubview(imageView)
        
        nameLabelView = KhLabel(frame: .zero)
        nameLabelView.alignment = .center
        nameLabelView.textColor = .white
        addSubview(nameLabelView)
    }
    
    func setData(_ data: PageItemData) {
        itemData = data
        if let itemData = itemData?.app as? AppsInfo {
            imageView.image = itemData.icon
            nameLabelView.stringValue = itemData.name
        }
    }
    
    private let padding: CGFloat = 16
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        let selfSize = self.frame.size
        
        let imgWidth = selfSize.width - 2 * padding
        let imgHeight = selfSize.height - 2 * padding
        imageView.frame = CGRect(x: padding, y: padding, width: imgWidth, height: imgHeight)
        
//        let imgSize = imageView.image?.size ?? CGSize(width: 0, height: 0)
//        let imgLeft = 0.5 * (selfSize.width - imgSize.width)
//        let imgBottom = 0.5 * (selfSize.height - imgSize.height)
//        
//        imageView.frame = CGRect(x: imgLeft, y: imgBottom, width: imgSize.width, height: imgSize.height)
//        
        var nameSize = nameLabelView.textSize()
        nameSize.width += 10
        let nameLeft = 0.5 * (selfSize.width - nameSize.width)
        let nameBottom = 0.5 * (padding - nameSize.height)
        
        nameLabelView.frame = CGRect(x: nameLeft, y: nameBottom, width: nameSize.width, height: nameSize.height)
    }
}
