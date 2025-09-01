//
//  DBModelData.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 21.08.2025.
//
import Foundation

class DBModelData{
    private var сoreData: DBCoreData!
    private var urls: [DBAppUrl]?
    private var apps: [DBApps]?
    private var itemsData: [PageItemData]?
    
    var onChangeUrls: (() -> Void)?
    var onChangeApps: (() -> Void)?
    var onChangeItemsData: ((_ isChanged: Bool) -> Void)?
    
    var fullItemsData: [PageItemData]? {
        return itemsData
    }
    
    var fullUrls: [DBAppUrl]? {
        return urls
    }
    
    var fullApps: [DBApps]? {
        return apps
    }
    
    init(сoreData: DBCoreData) {
        self.сoreData = сoreData
        loadUrls()
        loadApps()
    }
    
    private func loadUrls() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let temp = self?.сoreData.urls.all()
            DispatchQueue.main.async {
                self?.urls = temp
                self?.onChangeUrls?()
            }
        }
    }
    
    private func loadApps() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let temp = self?.сoreData.apps.getAll()
            DispatchQueue.main.async {
                self?.apps = temp
                self?.onChangeApps?()
            }
        }
    }
    
    func realoadItemsData() {
        if itemsData == nil || itemsData?.count == 0 {
            loadItemsData()
        } else {
            onChangeItemsData?(false)
        }
    }
    
    private func loadItemsData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let appsInfo = AppsUtils.getAllApps(urls: self?.urls)
            let temp = self?.loadItemsData(apps: appsInfo)
            DispatchQueue.main.async {
                self?.itemsData = temp
                self?.resore()
                self?.onChangeItemsData?(true)
            }
        }
    }
    
    func save() {
        self.сoreData.saveContext()
    }
    
    func new(url: URL) {
        if urls?.isExist(url: url) == false, let data = DBAppUrl.data(for: url) {
            let newUrl = self.сoreData.urls.new(with: data)
            urls?.append(newUrl)
            save()
            onChangeUrls?()
            loadItemsData()
        }
    }
}

extension DBModelData {
    private func loadItemsData(apps: [AppsInfo]) -> [PageItemData] {
        var tempItemsData = [PageItemData]()
        var newApps = [AppsInfo]()
        for app in apps {
            if let dbApp = self.apps?.filter({ $0.guid == app.path }).first {
                let item = PageItemData(dbApp: dbApp, app: app, apps: nil)
                tempItemsData.append(item)
            } else {
                newApps.append(app)
            }
        }
        
        for newApp in newApps {
            let newPos = tempItemsData.newPos()
            let newDBApp = сoreData.apps.new(with: newApp, newPos: newPos)
            let item = PageItemData(dbApp: newDBApp, app: newApp, apps: nil)
            tempItemsData.append(item)
        }
        
        if newApps.count > 0 {
            self.сoreData.saveContext()
        }
        
        return tempItemsData
    }
    
    private func resore() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let itemsData = self?.itemsData {
                let maxPage = itemsData.maxPage()
                for i in 0...maxPage {
                    let pageItems = itemsData.one(page: i)
                    self?.fixPageIndex(items: pageItems)
                    if pageItems.count > PageView.maxAppCount {
                        print("count > \(PageView.maxAppCount)")
                    }
                }
            }
        }
    }
    
    private func fixPageIndex(items: [PageItemData]?) {
        if let items = items {
            let count = items.count
            var index0: Int = -1
            var seekN = [[PageItemData]]()
            //Ищем все проблемы
            for i in 0...(count-1) {
                let seek = items.filter({$0.index == i})
                if seek.count == 0 {
                    index0 = i
                }
                if seek.count > 1 {
                    seekN.append(seek)
                }
            }
            //Если есть ярлыки с одинаковыми индексами
            if seekN.count > 0 {
                for seek in seekN {
                    for i in 1...(seek.count) {
                        var item = seek[i]
                        if index0 >= 0 {
                            item.index = index0
                            index0 = -1
                        } else {
                            if let nextIndex = items.max(by: {$0.index < $1.index})?.index {
                                item.index = nextIndex + 1
                            } else {
                                item.index = 0
                            }
                        }
                    }
                }
            } else if index0 >= 0 { //Если нет двойных индексов но есть пустые места....
                //....
            }
            //Если index < 0 или > максимума
            let seek = items.filter({$0.index < 0 || $0.index >= PageView.maxAppCount})
            if seek.count > 0 {
                for var item in seek {
                    let validItems = items.filter({$0.index >= 0 || $0.index < PageView.maxAppCount})
                    if let nextIndex = validItems.max(by: {$0.index < $1.index})?.index {
                        if nextIndex < PageView.maxAppCount - 1 {
                            item.index = nextIndex + 1
                        } else {
                            //...
                        }
                    } else {
                        //...
                    }
                }
            }
        }
    }
    
    func verivyData() {
        //Проверка что в папке всего 1 приложение
        
        //Проверка что на экране верное кол-во приложений
        
        
        
        //onChangeApps?()
    }
}
