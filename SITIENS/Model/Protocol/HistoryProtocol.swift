//
//  HistoryProtocol.swift
//  SITIENS
//
//  Created by Assistant on 09/26/2025.
//

import Foundation

protocol HistoryProtocol {
    func getHisoData() throws -> [History]
    /// `quantity` : texte historique (« 3,0 L ») ; `liters` : la même quantité en nombre.
    func addtHisoData(name: String, quantity: String, liters: Double) throws
    func deleteHistory(history: History)
}
