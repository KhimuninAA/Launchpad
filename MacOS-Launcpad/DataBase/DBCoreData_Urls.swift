//
//  DBCoreData_Urls.swift
//  MacOS-Launcpad
//
//  Created by Алексей Химунин on 20.08.2025.
//

import CoreData

class DBCoreData_Urls{
    private var container: NSPersistentContainer!
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func new(with data: Data) -> DBAppUrl {
        let context = container.viewContext
        let url = DBAppUrl(context: context)

        url.urlData = data
        
        return url
    }
    
    func all() -> [DBAppUrl] {
        var urls = [DBAppUrl]()
        
        let context = container.viewContext
        let urlsCallRequest = NSFetchRequest<DBAppUrl>(entityName: "DBAppUrl")
        
        do{
            
            let urlsCallDatas = try context.fetch(urlsCallRequest)
            for (_,urlCallData) in urlsCallDatas.enumerated() {
                urls.append(urlCallData)
            }
            
        }catch let fetchErr {
        }
        
        return urls
    }
}
