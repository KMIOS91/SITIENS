//
//  HistoryRepository.swift
//  SITIENS
//
//  Created by Modibo on 07/05/2025.
//

import Foundation
import CoreData
import SwiftUI

struct HistoryRepository: HistoryProtocol {
    
     var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.newBackgroundContext()) {
        self.context = context
    }
    
    func getHisoData()  throws -> [History] {
        let result: [History] = try context.performAndWait {
            try fillMissingLiters()

            let request: NSFetchRequest<History> = History.fetchRequest()
            // Plus récent en premier. Les entrées créées avant la version 2 du modèle
            // n'ont pas de `createdAt` et se retrouvent en fin de liste.
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            return try context.fetch(request)
        }
        return result
    }

    func addtHisoData(name: String, quantity: String, liters: Double) throws {
        let now = Date.now
        let dateFormatted = now.formatted(date: .numeric, time: .shortened)
        
        try context.performAndWait {
            let newHistory = History(context: context)
            newHistory.name = name
            newHistory.quantity = quantity
            newHistory.date = dateFormatted
            newHistory.createdAt = now
            newHistory.liters = liters
            try context.save()
        }
    }
    
    /// Les entrées antérieures à la version 3 du modèle n'ont que le texte (« 3.0L ») :
    /// on en déduit les litres une fois, puis on enregistre.
    /// À appeler dans `context.performAndWait`.
    private func fillMissingLiters() throws {
        let request: NSFetchRequest<History> = History.fetchRequest()
        request.predicate = NSPredicate(format: "liters == 0")
        for entry in try context.fetch(request) {
            if let liters = Self.liters(fromLegacyQuantity: entry.quantity) {
                entry.liters = liters
            }
        }
        if context.hasChanges {
            try context.save()
        }
    }

    /// « 3.0L », « 3,0 L » → 3.0 ; `nil` si le texte n'est pas une quantité.
    static func liters(fromLegacyQuantity text: String?) -> Double? {
        guard let text else { return nil }
        let number = text
            .replacingOccurrences(of: "L", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard let liters = Double(number), liters > 0 else { return nil }
        return liters
    }

    func deleteHistory(history: History) {
        let objectID = history.objectID
        context.performAndWait {
            if let object = try? context.existingObject(with: objectID) {
                context.delete(object)
                try? context.save()
            }
        }
    }
}
