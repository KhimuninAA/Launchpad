//
//  AppsUtils.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 15.08.2025.
//

import AppKit

struct AppsInfo: ItemData{
    let name: String
    let icon: NSImage
    let path: String
    let category: String
}

class AppsUtils{
    static func getAllApps() -> [AppsInfo] {
        var tempApps = [AppsInfo]()
        
        var appPaths = ["/Applications", "/System/Applications" ]
        
        ///Volumes/M4Ext1Tb/App
        /////NSRemovableVolumesUsageDescription
//        let user = NSUserName()
//        let userApps = "/Users/\(user)/Applications"
//        //appPaths.append(userApps)
//        appPaths = [userApps]
//        appPaths.append("/Volumes/M4Ext1Tb/App")
        
        
        for basePath in appPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(atPath: basePath) else { continue }
            
            if let apps = getApps(for: contents, basePath: basePath) {
                tempApps.insert(contentsOf: apps, at: tempApps.count)
            }
//            
//            for item in contents where item.hasSuffix(".app") {
//            }
        }
        
        return tempApps
    }
    
    static func getApps(for directories: [String]?, basePath: String, isSubDir: Bool = true) -> [AppsInfo]? {
        var tempApps = [AppsInfo]()
        if let directories = directories {
            for item in directories {
                if item.hasSuffix(".app") {
                    let fullPath = basePath + "/" + item
                    let appName = item.replacingOccurrences(of: ".app", with: "")
                    let icon = NSWorkspace.shared.icon(forFile: fullPath)
                    icon.size = NSSize(width: 64, height: 64)
                    let category = getCategory(by: fullPath)
                    
                    let app = AppsInfo(name: appName, icon: icon, path: fullPath, category: category)
                    tempApps.append(app)
                    
                } else if isSubDir {
                    let dir = basePath + "/" + item
                    let contents = try? FileManager.default.contentsOfDirectory(atPath: dir)
                    if let apps = getApps(for: contents, basePath: dir, isSubDir: false) {
                        tempApps.insert(contentsOf: apps, at: tempApps.count)
                    }
                }
            }
        }
        
        if tempApps.count > 0 {
            return tempApps
        } else {
            return nil
        }
    }
    
    static func getCategory(by appPath: String) -> String {
        let path = appPath + "/Contents/Info.plist"
        guard let xmlData = FileManager.default.contents(atPath: path) else {
            return "Default"
        }
        
        do {
            if let plistDict = try PropertyListSerialization.propertyList(from: xmlData, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
                if let category = plistDict["LSApplicationCategoryType"] as? String {
                    return category
                } else {
                    return "Default"
                }
            } else {
                return "Default"
            }
        } catch {
            print("Error parsing plist: \(error.localizedDescription)")
            return "Default"
        }
        
        return "Default"
    }
    
    static func getAppsPage(apps: [AppsInfo], pageCount: Int) -> [[PageItemData]] {
        var pages = [[PageItemData]]()
        
        var index: Int = 0
        var pageIndex: Int = 0
        var page = [PageItemData]()
        for app in apps {
            let item = PageItemData(id: app.path, name: app.name, page: pageIndex, index: index, app: app, apps: nil)
            page.append(item)
            index += 1
            if index >= pageCount {
                index = 0
                pageIndex += 1
                pages.append(page)
                page = [PageItemData]()
            }
        }
        if page.count > 0 {
            pages.append(page)
        }
        
        return pages
    }

    static func search(AppsPages: [[PageItemData]]?, pageCount: Int, searchText: String) -> [[PageItemData]]? {
        var searchPages: [[PageItemData]] = []
        var index: Int = 0
        var pageIndex: Int = 0

        let searchTempText = searchText.lowercased()
        var searchPage: [PageItemData] = []
        if let appsPages = AppsPages {
            for appsPage in appsPages {
                for app in appsPage {
                    let appName = app.name.lowercased()
                    if appName.contains(searchTempText) {
                        var newApp = app
                        newApp.index = index
                        newApp.page = pageIndex
                        searchPage.append(newApp)
                        index += 1
                        if index >= pageCount {
                            index = 0
                            pageIndex += 1
                            searchPages.append(searchPage)
                            searchPage = []
                        }
                    }
                }
            }
        }

        if searchPage.count > 0 {
            searchPages.append(searchPage)
        }
        return searchPages
    }
}



//App Category
