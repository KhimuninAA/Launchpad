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
    var modelData: DBModelData!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    private func initView() {
        let coreData = DBCoreData.init()
        modelData = DBModelData(сoreData: coreData)
        modelData.onChangeApps = { [weak self] in
            self?.reloadApps()
        }
        modelData.onChangeUrls = { [weak self] in
            self?.reloadApps()
        }
        modelData.onChangeItemsData = { [weak self] (isChanged) in
            self?.updateAppsUI(isChanged: isChanged)
        }
        firstAppsPageView = AppsPageView(frame: .zero)
        PageView.maxAppCount = firstAppsPageView.getMaxAppsCount(size: self.bounds.size)
        
        searchField.onSearchTextChanged = { [weak self] (searchText) in
            self?.searchText = searchText
            self?.updateAppsUI(isChanged: true)
        }
    }
    
    private var showAppsPages: [PageItemData]?
    static var maxAppCount: Int = 0
    
    func getAllDBUrls() -> [DBAppUrl] {
        let urls = modelData.fullUrls ?? [DBAppUrl]()
        return urls
    }
    
    func reloadApps() {
        if let _ = modelData.fullApps, let _ = modelData.fullUrls {
            modelData.realoadItemsData()
        }
    }

    private var searchText: String? = nil
    private func updateSearch() {
        if let searchText = searchText, searchText.count > 0 {
            currentPage = 0
            let searchAppsPages = modelData.fullItemsData?.search(text: searchText)
            showAppsPages = searchAppsPages
        } else {
            showAppsPages = modelData.fullItemsData
        }
    }
    
    private func updateAppsUI(isChanged: Bool) {
        updateSearch()

        if isChanged == true {
            ///clear
            self.clearViews()
            var pageCount: Int = 0
            if let showAppsPages = showAppsPages {
                pageCount = showAppsPages.maxPage()
                if pageCount >= 0 {
                    for i in 0...pageCount {
                        let items = showAppsPages.one(page: i)
                        let appsPageView = AppsPageView(frame: .zero)
                        appsPageView.currentPage = i
                        addPage(appsPageView)
                        appsPageView.setApps(items)
                        appsPageView.onNeedDBSave = { [weak self] in
                            self?.modelData.save()
                        }
                        appsPageView.onFreeMoveItem = { [weak self] (itemView) in
                            self?.modelData.fullItemsData?.freeMove(uid: itemView.uid)
                            self?.modelData.save()
                            self?.updateAppsUI(isChanged: true) //TODO
                        }
                    }
                }
            }
            
            let newPageView = AppsPageView(frame: .zero)
            newPageView.currentPage = pageCount + 1
            addPage(newPageView)
        }
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
        
        //если открыта папка
        if let appsPageView = getCurrentView() as? AppsPageView {
            if appsPageView.isOpenedFolder {
                appsPageView.closeFolder()
                return
            }
        }
        
        startLocation = locationInView

        if let item = getItem(by: locationInView) {
            moveToIndex = item.index
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
            item.isDragged = false
            if let appsPageView = getCurrentView() as? AppsPageView {
                appsPageView.toFrame(itemView: item)
                appsPageView.addSubview(item)
            }
            break
        }
        
        mouseActionType = .none
    }
    
    var moveItem: ItemView? = nil
    override func mouseDragged(with event: NSEvent) {
        mouseTimer?.invalidate()
        mouseTimer = nil
        
        super.mouseDragged(with: event)

        var isDragged: Bool = false
        switch mouseActionType {
        case .none:
            break
        case .click(item: let item):
            item.isDragged = true
            mouseActionType = .dragged(item: item)
            isDragged = true
            moveItem = item
            if let moveItem = moveItem {
                addSubview(moveItem)
            }
            break
            
        case .longClick:
            break
        case .dragged(item: let item):
            isDragged = true
            if moveItem == nil {
                moveItem = item
            }
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
            moveInFolder(item: moveItem, x: nX + 0.5 * startItemFrame.width, y: nY + 0.5 * startItemFrame.height)
            
            moveItemView(item: moveItem, x: nX + 0.5 * startItemFrame.width, y: nY + 0.5 * startItemFrame.height)
        }
    }
    
    private var seekFolder: ItemView?
    private var seekFolderTimer: Timer?
    private func moveInFolder(item: ItemView, x: CGFloat, y: CGFloat) {
        let point = CGPoint(x: x, y: y)
        if let appsPageView = getCurrentView() as? AppsPageView {
            var isSeek: Bool = false
            let moves = ItemViewMoveType.allTypes()
            for move in moves {
                if let index = appsPageView.getIndex(point: move.getNew(point: point)), index != item.index {
                    if let seek = appsPageView.getItem(by: index) {
                        if seekFolder != seek {
                            seekFolder = seek
                            seekFolderTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(needOpenFolderTimer), userInfo: nil, repeats: false)
                        }
                    }
                    isSeek = true
                }
            }
            if isSeek == false {
                seekFolder = nil
                seekFolderTimer?.invalidate()
                seekFolderTimer = nil
                appsPageView.selected(style: .none, select: nil)
            }
        }        
    }
    
    @objc func needOpenFolderTimer() {
        if let seekFolder = seekFolder {
            seekFolderTimer?.invalidate()
            seekFolderTimer = nil
            if let appsPageView = getCurrentView() as? AppsPageView {
                appsPageView.selected(style: .foldered, select: seekFolder)
                seekFolder.blinkMaskBolder(alphaFrom: 0.9, alphaTo: 0.5, onCompletion: { [weak self] in
                    if let seekFolder = self?.seekFolder {
                        appsPageView.openFolder(folder: seekFolder)
                    }
                })
            }
        }
    }
    
    private var moveToIndex: Int? = nil
    func moveItemView(item: ItemView, x: CGFloat, y: CGFloat) {
        if let appsPageView = getCurrentView() as? AppsPageView {
            let index = appsPageView.getIndex(x: x, y: y, defaultIndex: item.index)
            if moveToIndex != index {
                moveToIndex = index
                appsPageView.move(itemView: item, to: index)
            }
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
    
    func addNewAppsFolder() {
        if let newUrl = promptForWorkingDirectoryPermission() {
            self.modelData.new(url: newUrl)
        }
    }
    
    private func promptForWorkingDirectoryPermission() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Choose your directory"
        openPanel.prompt = "Choose"
        openPanel.allowedContentTypes = []
        //openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true

        let response = openPanel.runModal()
        print(openPanel.urls) // this contains the chosen folder
        return openPanel.urls.first
    }
}
