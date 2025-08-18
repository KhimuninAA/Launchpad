//
//  KhPageDotsView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 17.08.2025.
//

import AppKit

class KhPageDotsView: NSView{
    var changedIndex: ((_ : Int) -> Void)?
    
    private var dots: [KhPageDotView]!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        dots = [KhPageDotView]()
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func setDots(count: Int) {
        for dot in dots {
            dot.removeFromSuperview()
        }
        dots = [KhPageDotView]()
        if count > 1 {
            for _ in 0...(count-1) {
                let dot = KhPageDotView(frame: .zero)
                dots.append(dot)
                self.addSubview(dot)
            }
        }
        resizeSubviews(withOldSize: self.bounds.size)
    }
    
    private var index: Int = 0
    var currentIndex: Int {
        get{
            return index
        }
        set (newVal) {
            index = newVal
            resizeSubviews(withOldSize: self.bounds.size)
        }
    }
    
    func getSize() -> CGSize {
        let height = 2 * padding + dotSize.height
        let width = padding + CGFloat(dots.count) * (dotSize.width + padding)
        return CGSize(width: width, height: height)
    }
    
    private let dotSize = CGSize(width: 10, height: 10)
    private let padding: CGFloat = 10
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        let selfSize = self.bounds.size
        
        if dots.count > 0 {
            let left = 0.5 * (selfSize.width - (CGFloat(dots.count) * (dotSize.width + padding)) + padding)
            let bottom = 0.5 * (selfSize.height - dotSize.height)
            var i: Int = 0
            for dot in dots {
                dot.frame = CGRect(x: left + CGFloat(i) * (dotSize.width + padding), y: bottom, width: dotSize.width, height: dotSize.height)
                let isSelected = (i == index) ? true : false
                dot.isSelected = isSelected
                i += 1
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        
        var i: Int = 0
        for dot in dots {
            let loc = convert(locationInView, to: dot)
            if NSPointInRect(loc, dot.bounds) {
                changedIndex?(i)
            }
            i += 1
        }
    }
    
//    override func hitTest(_ point: NSPoint) -> NSView? {
//        return self.hitTest(point)
//    }
}
