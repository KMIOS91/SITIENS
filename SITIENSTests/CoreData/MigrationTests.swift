//
//  MigrationTests.swift
//  SITIENSTests
//
//  Vérifie qu'un historique enregistré avec l'ancien modèle (v1)
//  reste lisible après la mise à jour vers le modèle v2 (ajout de `createdAt`).
//

import Testing
import CoreData
@testable import SITIENS

struct MigrationTests {

    private var modelDirectory: URL {
        get throws {
            let bundle = Bundle(for: PersistenceController.self)
            return try #require(bundle.url(forResource: "SitiensModel", withExtension: "momd"))
        }
    }

    @Test func historyFromModelV1SurvivesMigration() throws {
        let momd = try modelDirectory
        let modelV1 = try #require(NSManagedObjectModel(contentsOf: momd.appendingPathComponent("SitiensModel.mom")))
        let currentModel = try #require(NSManagedObjectModel(contentsOf: momd))
        #expect(currentModel.entitiesByName["History"]?.attributesByName["createdAt"] != nil)

        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("migration-\(UUID().uuidString).sqlite")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(atPath: storeURL.path + suffix)
            }
        }

        // 1. Une base créée par l'ancienne version de l'app.
        let oldCoordinator = NSPersistentStoreCoordinator(managedObjectModel: modelV1)
        let oldStore = try oldCoordinator.addPersistentStore(type: .sqlite, at: storeURL)
        let oldContext = NSManagedObjectContext(.privateQueue)
        oldContext.persistentStoreCoordinator = oldCoordinator
        try oldContext.performAndWait {
            let entity = try #require(modelV1.entitiesByName["History"])
            let history = NSManagedObject(entity: entity, insertInto: oldContext)
            history.setValue("Sportifs", forKey: "name")
            history.setValue("3.0L", forKey: "quantity")
            history.setValue("03/11/2026 10:00", forKey: "date")
            try oldContext.save()
        }
        try oldCoordinator.remove(oldStore)

        // 2. La nouvelle version l'ouvre avec migration automatique.
        let container = NSPersistentContainer(name: "SitiensModel", managedObjectModel: currentModel)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        #expect(loadError == nil)

        let rows = try container.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: "History"))
        #expect(rows.count == 1)
        #expect(rows.first?.value(forKey: "name") as? String == "Sportifs")
        #expect(rows.first?.value(forKey: "createdAt") == nil)
    }
}
