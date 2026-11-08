//
//  PersistenceController.swift
//  SITIENS
//
//  Created by Modibo on 27/04/2025.
//
import Foundation
import CoreData

final class PersistenceController: Sendable {

    // MARK: - Properties
    static let shared = PersistenceController()

    /// Pour les #Preview et les tests : base en mémoire, rien n'est sauvegardé
    static let preview = PersistenceController(inMemory: true)

    let container: NSPersistentContainer

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
            #if DEBUG
            print("Store chargé : \(storeDescription.url?.absoluteString ?? "pas d'URL")")
            #endif
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    /// Contexte principal : uniquement depuis l'UI / le main thread
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    /// Nouveau contexte de fond : un par tâche, ne pas le garder
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }
}
