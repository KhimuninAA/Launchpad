//
//  PageView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 16.08.2025.
//
import AppKit

class PageView: KhPageView{
    private var firstAppsPageView: AppsPageView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        firstAppsPageView = AppsPageView(frame: .zero)
//        addPage(firstAppsPageView)
//        
//        let view1 = NSView(frame: .zero)
//        view1.wantsLayer = true
//        view1.layer?.backgroundColor = NSColor.red.cgColor
//        addPage(view1)
//        
//        let view2 = NSView(frame: .zero)
//        view2.wantsLayer = true
//        view2.layer?.backgroundColor = NSColor.blue.cgColor
//        addPage(view2)
//        
//        let view3 = NSView(frame: .zero)
//        view3.wantsLayer = true
//        view3.layer?.backgroundColor = NSColor.yellow.cgColor
//        addPage(view3)
    }
    
    private var fullAppsPages: [[PageItemData]]?
    private var showAppsPages: [[PageItemData]]?
    func setApps(_ apps: [AppsInfo]) {
        let maxAppCount = firstAppsPageView.getMaxAppsCount(size: self.bounds.size)
        fullAppsPages = AppsUtils.getAppsPage(apps: apps, pageCount: maxAppCount)
        
        updateAppsUI()
    }
    
    private func updateSearch() {
        showAppsPages = fullAppsPages
    }
    
    private func updateAppsUI() {
        updateSearch()
        if let showAppsPages = showAppsPages {
            for appsPage in showAppsPages {
                let appsPageView = AppsPageView(frame: .zero)
                addPage(appsPageView)
                appsPageView.setApps(appsPage)
            }
        }
        let newPageView = AppsPageView(frame: .zero)
        addPage(newPageView)
    }
    
    private func getItem(by location: NSPoint) -> ItemView? {
//        for item in items {
//            if item.isHidden == false {
//                let loc = convert(location, to: item)
//                if NSPointInRect(loc, item.bounds) {
//                    return item
//                }
//            }
//        }
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        
        let item = getItem(by: locationInView)
        
        super.mouseDown(with: event)
    }
}
