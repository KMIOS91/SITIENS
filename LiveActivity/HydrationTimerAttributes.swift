//
//  HydrationTimerAttributes.swift
//  SITIENS
//
//  Partagé entre l'app (qui démarre la Live Activity) et l'extension (qui l'affiche).
//  Ce fichier appartient aux deux cibles : SITIENS et LiveActivityExtension.
//

import ActivityKit
import Foundation

struct HydrationTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Fin prévue du minuteur quand il tourne.
        var endDate: Date
        /// Secondes restantes figées pendant une pause ; `nil` quand le minuteur tourne.
        /// `0` signifie que le minuteur est terminé.
        var frozenRemaining: Int?

        var isPaused: Bool { (frozenRemaining ?? 0) > 0 }
        var isFinished: Bool { frozenRemaining == 0 }
    }

    /// Durée totale choisie, en secondes (fixe pendant toute la Live Activity).
    var totalSeconds: Int
}
