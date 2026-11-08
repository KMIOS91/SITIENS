//
//  HistoryViewModel.swift
//  SITIENS
//
//  Created by Modibo on 12/05/2025.
//

import Foundation
import CoreData
import SwiftUI


@Observable class HistoryViewModel {
    var history = [History]()
    var name: String
    var quantity: String
    /// La quantité en nombre, enregistrée à côté du texte `quantity`.
    var liters: Double = 0
    var errorMessage = ""
    
    var viewContext: NSManagedObjectContext
    
    var historyRepository : HistoryProtocol
    
    init(
        viewContext: NSManagedObjectContext = PersistenceController.shared.newBackgroundContext(),
        historyRepository: HistoryProtocol = HistoryRepository() ,
        name: String = "",
        quantity: String = ""
    ) {
        self.viewContext = viewContext
        self.historyRepository = historyRepository
        self.name = name
        self.quantity = quantity
        
        try?  fetchHistory()
    }
    
    enum FetchError: Error {
        case fetchFailed
        case deleteFailed
    }
    
    func showMessageError()  -> String? {
        if name.isEmpty || quantity.isEmpty   {
            return "Veuillez remplir tous les champs."
        }
        return nil
    }
    
    func addHistory() throws {
        if let erreor =  showMessageError(){
            errorMessage = erreor
        }
        
        do {
            
            try historyRepository.addtHisoData(name: name, quantity: quantity, liters: liters)
            print("result : \(name) \(quantity)")
        } catch {
            print("Fetching history failed: \(error)")
            throw FetchError.fetchFailed
        }
    }
    
    func fetchHistory()  throws {
        do {
            history = try historyRepository.getHisoData()
        } catch {
            throw FetchError.fetchFailed
        }
    }
    
    func reload() {
        do{
            try  fetchHistory()
        }catch {
            errorMessage = "Échec du rechargement des données : \(error.localizedDescription)"
        }
    }
    
    /// Supprime les entrées situées à ces positions dans `history` (la liste complète).
    func deleteHistory(at offsets: IndexSet) {
        deleteHistory(offsets.filter { $0 < history.count }.map { history[$0] })
    }

    /// Supprime ces entrées précises.
    /// À utiliser quand la liste affichée est filtrée : ses positions ne correspondent plus à `history`.
    func deleteHistory(_ entries: [History]) {
        for entry in entries {
            historyRepository.deleteHistory(history: entry)
        }

        do {
            try fetchHistory()
        } catch {
            errorMessage = "Échec du rechargement des données : \(error.localizedDescription)"
        }
    }
}
