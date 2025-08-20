//
//  DBAppUrl+CoreDataProperties.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 20.08.2025.
//

import Foundation
import CoreData


extension DBAppUrl {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBAppUrl> {
        return NSFetchRequest<DBAppUrl>(entityName: "DBAppUrl")
    }
    
    @NSManaged public var urlData: Data
}

extension DBAppUrl{
    static func data(for workDir: URL) -> Data? {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            return bookmarkData
        } catch {
            return nil
        }
    }
    
    func saveBookmarkData(for workDir: URL) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
        }
    }
    
    func url() -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: self.urlData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                saveBookmarkData(for: url)
            }
            return url
        } catch {
            return nil
        }
    }
}

extension Array where Element == DBAppUrl {
    func isExist(url: URL) -> Bool {
        for dbUrl in self {
            if dbUrl.url()?.path() == url.path() {
                return true
            }
        }
        return false
    }
}
