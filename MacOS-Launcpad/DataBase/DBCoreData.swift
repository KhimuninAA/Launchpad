//
//  DBCoreData.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 19.08.2025.
//

import CoreData

class DBCoreData{
    let model: String = "AppsBD"
    private var container: NSPersistentContainer!
    var apps: DBCoreData_Apps!
    var urls: DBCoreData_Urls!
    
    init() {
        container = initBD()
        apps = DBCoreData_Apps(container: container)
        urls = DBCoreData_Urls(container: container)
    }
    
    private func getDocumentsDirectory() -> URL? {
        let fileManager = FileManager.default
        // Request the URL for the .documentDirectory within the .userDomainMask
        if let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectoryURL
        }
        return nil
    }
    
    private func initBD() -> NSPersistentContainer{
        let container = NSPersistentContainer(name: self.model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print("storeDescription = \(storeDescription)")
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
    
    func saveContext () {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                container.viewContext.rollback()
            }
        }
    }
    
    func delete(object: NSManagedObject) {
        container.viewContext.delete(object)
        saveContext()
    }
}
