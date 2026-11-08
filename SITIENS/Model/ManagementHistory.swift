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
    /// Texte enregistré (« 3.0L ») : utilisé seulement si `liters` est inconnu.
    var quantity : String
    /// Date enregistrée en texte : utilisée seulement si `createdAt` est inconnue.
    var date : String
    var liters: Double = 0
    var createdAt: Date? = nil

    /// « 3,0 L », formaté selon la langue de l'appareil.
    var quantityText: String {
        guard liters > 0 else { return quantity }
        return "\(liters.formatted(.number.precision(.fractionLength(1)))) L"
    }

    /// « 8 nov. 2026 à 18:11 », formaté selon la langue de l'appareil.
    var dateText: String {
        createdAt?.formatted(date: .abbreviated, time: .shortened) ?? date
    }
}

extension ManagementHistory {
    /// Copie une entrée Core Data en valeur simple, plus facile à afficher.
    /// Les attributs Core Data sont optionnels : une valeur absente devient une chaîne vide.
    init(_ history: History) {
        self.init(
            name: history.name ?? "",
            quantity: history.quantity ?? "",
            date: history.date ?? "",
            liters: history.liters,
            createdAt: history.createdAt
        )
    }
}
