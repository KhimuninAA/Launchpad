//
//  DBApps+CoreDataProperties.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 19.08.2025.
//

import Foundation
import CoreData


extension DBApps {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBApps> {
        return NSFetchRequest<DBApps>(entityName: "DBApps")
    }
    
    @NSManaged public var dirGuid: String?
    @NSManaged public var guid: String
    @NSManaged public var index: Int16
    @NSManaged public var isDir: Bool
    @NSManaged public var name: String
    @NSManaged public var page: Int16
}

extension DBApps{
}
