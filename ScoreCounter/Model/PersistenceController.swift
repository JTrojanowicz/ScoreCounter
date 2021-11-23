//
//  CoreDataOperations.swift
//  ScoreCounter
//
//  Created by Jaroslaw Trojanowicz on 21/11/2021.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    var moc: NSManagedObjectContext {
        container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "ScoreStorage")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save(completion: @escaping (Error?) -> () = {_ in}) {
        if moc.hasChanges {
            do {
                try moc.save() // save to mainContext
                let mainContext = container.viewContext
                if mainContext.hasChanges {
                    try mainContext.save()
                    completion(nil)
                }
            } catch {
                completion(error)
            }
        }
    }
}
