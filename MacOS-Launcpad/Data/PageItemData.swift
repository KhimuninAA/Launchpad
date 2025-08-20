//
//  PageItemData.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 20.08.2025.
//

struct ItemDataNewPos{
    let index: Int
    let page: Int
}

struct PageItemData{
    var dbApp: DBApps
    var app: AppsInfo?
    var apps: [AppsInfo]?
    var newPos: ItemDataNewPos?
}

extension PageItemData {
    var page: Int {
        return newPos?.page ?? Int(dbApp.page)
    }
    var index: Int {
        get{
            return newPos?.index ?? Int(dbApp.index)
        }
        set{
            dbApp.index = Int16(newValue)
        }
    }
}

extension Array where Element == PageItemData {
    func newPos() -> ItemDataNewPos {
        let maxPage = self.maxPage()
        if maxPage >= 0 {
            for i in 0...maxPage {
                let count = one(page: i).count
                if count < PageView.maxAppCount {
                    return ItemDataNewPos(index: count, page: i)
                }
            }
        }
        return ItemDataNewPos(index: 0, page: maxPage + 1)
    }
    
    func one(page: Int) -> [PageItemData] {
        return filter { $0.page == Int16(page) }
    }
    
    func maxPage() -> Int {
        let sortedByPage = sorted(by: { $0.page > $1.page })
        if let temp = sortedByPage.first {
            return Int(temp.page)
        }
        return -1
    }
    
    func search(text: String) -> [PageItemData] {
        let searchTempText = text.lowercased()
        var temp = [PageItemData]()
        
        var sPage = 0
        var sIndex = 0
        for item in self {
            if item.dbApp.name.lowercased().contains(searchTempText) {
                var newItem = item
                newItem.newPos = ItemDataNewPos(index: sIndex, page: sPage)
                temp.append(newItem)
                
                sIndex += 1
                if sIndex >= PageView.maxAppCount {
                    sIndex = 0
                    sPage += 1
                }
            }
        }
        return temp
    }
}

//extension Array where Element == [[PageItemData]] {
//    func newPos() -> ItemDataNewPos {
//        return ItemDataNewPos(index: 0, page: 0)
//    }
//}
