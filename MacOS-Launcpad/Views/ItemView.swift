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

enum ItemViewSelectedType {
    case none
    case border
    case foldered
}

enum ItemViewMoveType {
    case top
    case bottom
    case left
    case right
    
    static func allTypes() -> [ItemViewMoveType] {
        return [.top, .bottom, .left, .right] //[.left, .right] //[.top, .bottom, .left, .right]
    }
    
    func getNew(point: CGPoint) -> CGPoint {
        let delta: CGFloat = 16 //8 //16
        var newPoint = point
        switch self {
        case .top:
            newPoint.y += delta
        case .bottom:
            newPoint.y -= delta
        case .left:
            newPoint.x += delta
        case .right:
            newPoint.x -= delta
        }
        return newPoint
    }
}

class ItemView: NSView {
    private var itemData: PageItemData?
    private var imageView: NSImageView!
    private var nameLabelView: KhLabel!
    private var maskView: NSView!
    
    var isDragged: Bool = false
    
    func getPath() -> String? {
        if let itemData = itemData?.app as? AppsInfo {
            return itemData.path
        }
        return nil
    }
    
    var uid: String {
        return itemData?.dbApp.guid ?? ""
    }
    
    var page: Int {
        get{
            return Int(itemData?.dbApp.page ?? 0)
        }
        set{
            itemData?.page = newValue
        }
    }
    
    var index: Int {
        get{
            return itemData?.index ?? 0
        }
        set{
            itemData?.index = newValue
        }
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
        layer?.borderWidth = 0 //1 //0 //1
        layer?.masksToBounds = false
        
        
        imageView = NSImageView(frame: .zero)
        imageView.imageScaling = .scaleAxesIndependently
        addSubview(imageView)
        
        maskView = NSView(frame: .zero)
        maskView.wantsLayer = true
        maskView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.5).cgColor
        maskView.layer?.borderColor = NSColor.white.withAlphaComponent(0.3).cgColor
        maskView.layer?.borderWidth = 5
        maskView.layer?.cornerRadius = 16
        maskView.isHidden = true
        addSubview(maskView)
        
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
    private var oldSelfSize: CGSize = CGSize(width: 0, height: 0)
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        let selfSize = self.frame.size
        if selfSize == oldSelfSize {
            return
        }
        oldSelfSize = selfSize
        let imgWidth = selfSize.width - 2 * padding
        let imgHeight = selfSize.height - 2 * padding
        let imageViewFrame = CGRect(x: padding, y: padding, width: imgWidth, height: imgHeight)
        imageView.frame = imageViewFrame
            
        maskView.frame = imageViewFrame
        
        var nameSize = nameLabelView.textSize()
        nameSize.width += 10
        let nameLeft = 0.5 * (selfSize.width - nameSize.width)
        let nameBottom = 0.5 * (padding - nameSize.height)
        
        nameLabelView.frame = CGRect(x: nameLeft, y: nameBottom, width: nameSize.width, height: nameSize.height)
    }
    
    func setStyle(_ new: ItemViewSelectedType) {
        switch new {
        case .none:
            maskView.animator().alphaValue = 0.5
            layer?.borderWidth = 0
            maskView.isHidden = true
        case .border:
            layer?.borderWidth = 8
            maskView.isHidden = true
        case .foldered:
            maskView.isHidden = false
            layer?.borderWidth = 0
        }
    }
    
    func getFrameImage() -> CGRect {
        let imageRect = imageView.frame
        let newRect = convert(imageRect, to: self.superview)
        return newRect
    }
    
    func blinkMaskBolder(alphaFrom: CGFloat, alphaTo: CGFloat, onCompletion: (() -> Void)?) {
        let selfDuration: TimeInterval = 0.3
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = selfDuration
            maskView.animator().alphaValue = alphaFrom
        }, completionHandler: {
            NSAnimationContext.runAnimationGroup({ [weak self] (context) in
                context.duration = selfDuration
                self?.maskView.animator().alphaValue = alphaTo
            }, completionHandler: {
                NSAnimationContext.runAnimationGroup({ [weak self] (context) in
                    context.duration = selfDuration
                    self?.maskView.animator().alphaValue = alphaFrom
                }, completionHandler: {
                    NSAnimationContext.runAnimationGroup({ [weak self] (context) in
                        context.duration = selfDuration
                        self?.maskView.animator().alphaValue = alphaTo
                    }, completionHandler: {
                        onCompletion?()
                    })
                })
            })
        })
    }
}
