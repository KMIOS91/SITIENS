//
//  ManagementHistory.swift
//  SITIENS
//
//  Created by Modibo on 01/09/2025.
//

import Foundation

struct ManagementHistory: Identifiable {
    let id = UUID()
    var name : String
    var quantity : String
    var date : String
    
}

extension ManagementHistory {
    /// Copie une entrée Core Data en valeur simple, plus facile à afficher.
    /// Les attributs Core Data sont optionnels : une valeur absente devient une chaîne vide.
    init(_ history: History) {
        self.init(
            name: history.name ?? "",
            quantity: history.quantity ?? "",
            date: history.date ?? ""
        )
    }
}
