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

    var searchField: KhSearchFieldNew = KhSearchFieldNew(frame: .zero)
    //private var searchField: KhSearchField = KhSearchField(frame: .zero)

    func clearViews() {
        for view in views {
            view.removeFromSuperview()
        }
        views = [NSView]()
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
        views = [NSView]()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.85).cgColor
        
        addSubview(pageDotsView)
        pageDotsView.changedIndex = { [weak self] (i) in
            self?.currentPage = i
            self?.setPages(isAnimator: true, dx: 0)
        }

        searchField.font = NSFont.systemFont(ofSize: 24, weight: .regular)
        searchField.textColor = .white
        addSubview(searchField)
    }
    
    func addPage(_ newPage: NSView) {
        addSubview(newPage, positioned: .below, relativeTo: pageDotsView)
        views.append(newPage)
        pageDotsView.setDots(count: views.count)
        DispatchQueue.main.async { [weak self] in
            self?.resizeSubviews(withOldSize: self?.bounds.size ?? CGSize(width: 0, height: 0))
        }
    }

    private var verticalOffset: CGFloat = 0
    override func resizeSubviews(withOldSize oldSize: NSSize) {
        super.resizeSubviews(withOldSize: oldSize)

        setPages(isAnimator: false, dx: 0)
        let offset = getContentTopOffset()
        if offset > 0 {
            verticalOffset = offset
        }

        let dotsSize = pageDotsView.getSize()
        let dotsLeft = 0.5 * (self.bounds.width - dotsSize.width)
        let dotsY = verticalOffset - 16 - dotsSize.height
        pageDotsView.frame = CGRect(x: dotsLeft, y: dotsY, width: dotsSize.width, height: dotsSize.height)
        
        let searchFieldSize = CGSize(width: 320, height: 32)
        let searchFieldLetf = 0.5 * (self.bounds.width - searchFieldSize.width)
        let searchFieldTop = self.bounds.height - verticalOffset + searchFieldSize.height + 16
        searchField.frame = CGRect(x: searchFieldLetf, y: searchFieldTop, width: searchFieldSize.width, height: searchFieldSize.height)
    }
    
    private var startLocation: NSPoint?
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        searchFieldEndFocus()
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)

        if NSPointInRect(locationInView, searchField.frame) {
            searchField.window?.makeFirstResponder(searchField)
        } else {
            startLocation = locationInView
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        searchFieldEndFocus()
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
        searchFieldEndFocus()
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
    
    func getContentTopOffset() -> CGFloat {
        if let view = views.first as? AppsPageView {
            return view.getTopOffset()
        }
        return 0
    }
    
    func getItem(by location: NSPoint) -> ItemView? {
        for view in views {
            let loc = convert(location, to: view)
            if let view = view as? AppsPageView {
                if let item = view.getItem(by: loc) {
                    return item
                }
            }
        }
        return nil
    }
    
    func searchFieldEndFocus() {
        if let window = self.window {
            window.makeFirstResponder(window)
        }
    }

    func changePage(spin: Int) {
        let newPage = currentPage + spin

        if newPage >= 0 && newPage < views.count {
            currentPage = newPage
            setPages(isAnimator: true, dx: 0)
        }
    }
}
