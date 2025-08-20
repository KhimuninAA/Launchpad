//
//  DBCoreData_Apps.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 19.08.2025.
//

import CoreData

class DBCoreData_Apps{
    private var container: NSPersistentContainer!
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func new(with info: AppsInfo, newPos: ItemDataNewPos) -> DBApps {
        let context = container.viewContext
        
        let app = DBApps(context: context)

        app.guid = info.path
        app.name = info.name
        app.index = Int16(newPos.index)
        app.page = Int16(newPos.page)
        app.isDir = false
        
        return app
    }
    
    func getAll() -> [DBApps] {
        var apps = [DBApps]()
        
        let context = container.viewContext
        let appsCallRequest = NSFetchRequest<DBApps>(entityName: "DBApps")
        
        do{
            
            let appsCallDatas = try context.fetch(appsCallRequest)
            for (_,appCallData) in appsCallDatas.enumerated() {
                apps.append(appCallData)
            }
            
        }catch let fetchErr {
        }
        
        return apps
    }
}
