//
//  PersistenceController.swift
//  SITIENS
//
//  Created by Modibo on 27/04/2025.
//

import Foundation
import CoreData

final class PersistenceController : @unchecked Sendable{
    
    // MARK: - Properties
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    private(set) var backgroundContext: NSManagedObjectContext?

    // MARK: - Init
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SitiensModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            print("Store loaded successfully at \(storeDescription.url?.absoluteString ?? "No URL")")
            
            // Initialiser le contexte de fond ici, après le chargement des stores
            self.backgroundContext = self.container.newBackgroundContext()
            self.backgroundContext?.automaticallyMergesChangesFromParent = true
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// Contexte principal - toujours sur le main thread
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    /// Créer un nouveau contexte de fond
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }
}
