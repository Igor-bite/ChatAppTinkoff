//
//  CoreDataStack.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 30.03.2021.
//

import Foundation
import CoreData

class CoreDataStack {
    private let dataBaseName = "Chat"
    var didUpdateDataBase: ((CoreDataStack) -> Void)?

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dataBaseName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("something went wrong \(error) \(error.userInfo)")
            }
        }
        return container
    }()
    
    func enableObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(managedObjectContextObjectsDidChange(notification:)),
                                       name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                       object: container.viewContext)
    }
    
    @objc
    private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        didUpdateDataBase?(self)
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
           inserts.count > 0 {
            print("Добавлено объектов: ", inserts.count)
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
           updates.count > 0 {
            print("Обновлено объектов: ", updates.count)
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
           deletes.count > 0 {
            print("Удалено объектов: ", deletes.count)
        }
    }
    
    func printDatabaseStatistice() {
        container.viewContext.perform {
            do {
                let count = try self.container.viewContext.count(for: Channel_db.fetchRequest())
                print("\(count) каналов")
                let array = try self.container.viewContext.fetch(Channel_db.fetchRequest()) as? [Channel_db] ?? []
                array.forEach {
                    print($0.about)
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func saveContext () {
        let context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
