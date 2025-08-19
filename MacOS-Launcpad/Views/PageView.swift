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
    case dragged(item: ItemView)
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
    private var startLocation: NSPoint?
    private var startItemFrame: NSRect?
    override func mouseDown(with event: NSEvent) {
        let locationInWindow = event.locationInWindow
        let locationInView = convert(locationInWindow, from: nil)
        startLocation = locationInView

        if let item = getItem(by: locationInView) {
            startItemFrame = item.frame



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

        startLocation = nil
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
        case .dragged(item: let item):
            if let startItemFrame = startItemFrame {
                item.frame = startItemFrame
            }
            break
        }
        
        mouseActionType = .none
    }
    
    override func mouseDragged(with event: NSEvent) {
        mouseTimer?.invalidate()
        mouseTimer = nil
        
        super.mouseDragged(with: event)

        var isDragged: Bool = false
        var moveItem: ItemView? = nil
        switch mouseActionType {
        case .none:
            break
        case .click(item: let item):
            mouseActionType = .dragged(item: item)
            isDragged = true
            moveItem = item
        case .longClick:
            break
        case .dragged(item: let item):
            isDragged = true
            moveItem = item
            break
        }

        let isSearch = (searchText == nil) ? false : (searchText!.count > 0) ? true : false

        if isDragged == true && isSearch == false, let startItemFrame = startItemFrame, let moveItem = moveItem, let startLocation = startLocation {
            let locationInWindow = event.locationInWindow
            let locationInView = convert(locationInWindow, from: nil)

            let nX = startItemFrame.origin.x + (locationInView.x - startLocation.x)
            let nY = startItemFrame.origin.y + (locationInView.y - startLocation.y)

            let newFrame = CGRect(x: nX, y: nY, width: startItemFrame.width, height: startItemFrame.height)
            moveItem.frame = newFrame
            draggedNeedChangePage(x: nX)
        }
    }

    private var draggedNeedChangePageTimer: Timer?
    private var draggedNeedChangeValue: Int = 0
    func draggedNeedChangePage(x: CGFloat) {
        let mulNeedChangePageValue: CGFloat = 0.1
        let timerValue: TimeInterval = 0.6

        let leftValue = self.bounds.width * mulNeedChangePageValue
        let rightValue = self.bounds.width - leftValue

        if x > leftValue && x < rightValue {
            draggedNeedChangePageTimer?.invalidate()
            draggedNeedChangePageTimer = nil
        } else if x <= leftValue {
            if draggedNeedChangeValue >= 0 {
                draggedNeedChangePageTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(needChangePageTimer), userInfo: nil , repeats: false)
            }
            draggedNeedChangeValue = -1
        } else if x >= rightValue {
            if draggedNeedChangeValue <= 0 {
                draggedNeedChangePageTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(needChangePageTimer), userInfo: nil , repeats: false)
            }
            draggedNeedChangeValue = 1
        }
    }

    @objc func needChangePageTimer() {
        if draggedNeedChangeValue == 1 || draggedNeedChangeValue == -1 {
            changePage(spin: draggedNeedChangeValue)
        }
        draggedNeedChangePageTimer?.invalidate()
        draggedNeedChangePageTimer = nil
        draggedNeedChangeValue = 0
    }
}
