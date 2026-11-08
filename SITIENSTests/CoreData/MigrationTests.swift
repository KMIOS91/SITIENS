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

    @Test func historyFromModelV2GetsLitersAfterMigration() throws {
        let momd = try modelDirectory
        let modelV2 = try #require(NSManagedObjectModel(contentsOf: momd.appendingPathComponent("SitiensModel 2.mom")))
        let currentModel = try #require(NSManagedObjectModel(contentsOf: momd))
        #expect(currentModel.entitiesByName["History"]?.attributesByName["liters"] != nil)

        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("migration-v2-\(UUID().uuidString).sqlite")
        defer {
            for suffix in ["", "-wal", "-shm"] {
                try? FileManager.default.removeItem(atPath: storeURL.path + suffix)
            }
        }

        // 1. Une base créée par la version 2 : quantité en texte uniquement.
        let oldCoordinator = NSPersistentStoreCoordinator(managedObjectModel: modelV2)
        let oldStore = try oldCoordinator.addPersistentStore(type: .sqlite, at: storeURL)
        let oldContext = NSManagedObjectContext(.privateQueue)
        oldContext.persistentStoreCoordinator = oldCoordinator
        try oldContext.performAndWait {
            let entity = try #require(modelV2.entitiesByName["History"])
            let history = NSManagedObject(entity: entity, insertInto: oldContext)
            history.setValue("Sportifs", forKey: "name")
            history.setValue("3.0L", forKey: "quantity")
            history.setValue("03/11/2026 10:00", forKey: "date")
            history.setValue(Date(timeIntervalSince1970: 1_793_700_000), forKey: "createdAt")
            try oldContext.save()
        }
        try oldCoordinator.remove(oldStore)

        // 2. La version 3 l'ouvre (migration automatique) puis déduit les litres du texte.
        let container = NSPersistentContainer(name: "SitiensModel", managedObjectModel: currentModel)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        #expect(loadError == nil)

        let repository = HistoryRepository(context: container.newBackgroundContext())
        let entries = try repository.getHisoData()
        #expect(entries.count == 1)
        #expect(entries.first?.liters == 3.0)
        #expect(entries.first?.quantity == "3.0L")
    }

    @Test(arguments: [
        ("3.0L", 3.0),
        ("3,0 L", 3.0),
        ("1.5L", 1.5),
        (" 2,5 L ", 2.5),
    ])
    func legacyQuantityIsParsed(text: String, liters: Double) {
        #expect(HistoryRepository.liters(fromLegacyQuantity: text) == liters)
    }

    @Test(arguments: ["", "beaucoup", "0L", "L"] as [String])
    func invalidLegacyQuantityIsIgnored(text: String) {
        #expect(HistoryRepository.liters(fromLegacyQuantity: text) == nil)
    }
}
