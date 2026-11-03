//
//  HistoryProtocol.swift
//  SITIENS
//
//  Created by Assistant on 09/26/2025.
//

import Foundation

protocol HistoryProtocol {
    func getHisoData() throws -> [History]
    func addtHisoData(name: String, quantity: String) throws
    func deleteHistory(history: History)
}
