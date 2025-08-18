//
//  KhPageView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 16.08.2025.
//

import AppKit

class KhPageView: NSView {
    private var views: [NSView]!
    var currentPage: Int = 0 {
        didSet {
            pageDotsView.currentIndex = currentPage
        }
    }
    private var pageDotsView: KhPageDotsView = KhPageDotsView(frame: .zero)
    private var searchField: NSSearchField = NSSearchField(frame: .zero)
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        views = [NSView]()
        
        wantsLayer = true
        //layer?.backgroundColor = NSColor.clear.cgColor
        layer?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.85).cgColor
        
        addSubview(pageDotsView)
        pageDotsView.changedIndex = { [weak self] (i) in
            self?.currentPage = i
            self?.setPages(isAnimator: true, dx: 0)
        }
        
        searchField.isEditable = true
        addSubview(searchField)
    }
    
    func addPage(_ newPage: NSView) {
        addSubview(newPage)
        views.append(newPage)
        resizeSubviews(withOldSize: self.bounds.size)
        pageDotsView.setDots(count: views.count)
    }
    
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)
        
        pageDotsView.removeFromSuperview()
        self.addSubview(pageDotsView)
        
        searchField.removeFromSuperview()
        self.addSubview(searchField)
        
        let dotsSize = pageDotsView.getSize()
        let dotsLeft = 0.5 * (self.bounds.width - dotsSize.width)
        pageDotsView.frame = CGRect(x: dotsLeft, y: 90, width: dotsSize.width, height: dotsSize.height)
        
        setPages(isAnimator: false, dx: 0)
        
        let searchFieldSize = CGSize(width: 320, height: 32)
        let searchFieldLetf = 0.5 * (self.bounds.width - searchFieldSize.width)
        let searchFieldTop = self.bounds.height - 100
        searchField.frame = CGRect(x: searchFieldLetf, y: searchFieldTop, width: searchFieldSize.width, height: searchFieldSize.height)
    }
    
    private var startLocation: NSPoint?
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        startLocation = locationInView
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        let changeValue: CGFloat = 0.1 //0.3
        
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        if let startLocation = startLocation {
            let dx = locationInView.x - startLocation.x
            if dx > self.bounds.width * changeValue {
                if currentPage > 0 {
                    currentPage -= 1
                }
            }
            if -dx > self.bounds.width * changeValue {
                if currentPage + 1 < views.count {
                    currentPage += 1
                }
            }
        }
        
        NSAnimationContext.runAnimationGroup { [weak self] context in
            context.duration = 0.4
            self?.setPages(isAnimator: true, dx: 0)
        } completionHandler: {
        }
        
        startLocation = nil
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        
        if let startLocation = startLocation {
            var dx = locationInView.x - startLocation.x
            if dx < 0 && currentPage == (views.count - 1) {
                dx = 0
            }
            if dx > 0 && currentPage == 0 {
                dx = 0
            }
            
            setPages(isAnimator: false, dx: dx)
        }
        
    }
    
    private func setPages(isAnimator: Bool = false , dx: CGFloat = 0) {
        let selfSize = self.bounds.size
        var startIndex: Int = -currentPage
        for view in views {
            let left = CGFloat(startIndex) * selfSize.width + dx
            if isAnimator {
                view.animator().frame = CGRect(x: left, y: 0, width: selfSize.width, height: selfSize.height)
            } else {
                view.frame = CGRect(x: left, y: 0, width: selfSize.width, height: selfSize.height)
            }
            startIndex += 1
        }
    }
}
