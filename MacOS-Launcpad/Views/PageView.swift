//
//  PageView.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 16.08.2025.
//
import AppKit

enum MouseActionType{
    case none
    case click(item: ItemView)
    case longClick
    case dragged
}

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
        searchField.onSearchTextChanged = { [weak self] (searchText) in
            self?.searchText = searchText
            self?.updateAppsUI()
        }
    }
    
    private var fullAppsPages: [[PageItemData]]?
    private var showAppsPages: [[PageItemData]]?
    private var maxAppCount: Int = 0
    func setApps(_ apps: [AppsInfo]) {
        maxAppCount = firstAppsPageView.getMaxAppsCount(size: self.bounds.size)
        fullAppsPages = AppsUtils.getAppsPage(apps: apps, pageCount: maxAppCount)
        
        updateAppsUI()
    }

    private var searchText: String? = nil
    private func updateSearch() {
        if let searchText = searchText, searchText.count > 0 {
            let searchAppsPages = AppsUtils.search(AppsPages: fullAppsPages, pageCount: maxAppCount, searchText: searchText)
            showAppsPages = searchAppsPages
        } else {
            showAppsPages = fullAppsPages
        }
    }
    
    private func updateAppsUI() {
        updateSearch()

        ///clear
        self.clearViews()

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
    
    func updateA(item: ItemView) {
        
    }

    private var mouseTimer: Timer?
    private var mouseActionType: MouseActionType = .none
    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        
        if let item = getItem(by: locationInView) {
            mouseActionType = .click(item: item)
            mouseTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] (time) in
                self?.mouseActionType = .longClick
                self?.updateA(item: item)
            })
            searchFieldEndFocus()
        } else {
            super.mouseDown(with: event)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        mouseTimer?.invalidate()
        mouseTimer = nil
        
        super.mouseUp(with: event)
        switch mouseActionType {
        case .none:
            break
        case .click(item: let item):
            if let path = item.getPath() {
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
                NSApp.terminate(nil)
            }
        case .longClick:
            break
        case .dragged:
            break
        }
        
        mouseActionType = .none
    }
    
    override func mouseDragged(with event: NSEvent) {
        mouseTimer?.invalidate()
        mouseTimer = nil
        
        super.mouseDragged(with: event)
        
        switch mouseActionType {
        case .none:
            break
        case .click(item: let item):
            mouseActionType = .dragged
        case .longClick:
            break
        case .dragged:
            break
        }
    }
}
