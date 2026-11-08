//
//  TimerDurationOptions.swift
//  SITIENS
//
//  Durées proposées pour le minuteur.
//

enum TimerDurationOptions {
    /// Raccourcis affichés dans les réglages, en secondes : de 15 min à 3 h.
    static let presets = [900, 1800, 2700, 3600, 5400, 7200, 10800]

    /// Réglage libre : par pas de 5 min, de 5 min à 4 h.
    static let step = 300
    static let range = 300...14_400

    /// Durée suivante sur la grille de 5 min (ex. 7 min → 10 min).
    static func increment(_ seconds: Int) -> Int {
        min((seconds / step + 1) * step, range.upperBound)
    }

    /// Durée précédente sur la grille de 5 min (ex. 7 min → 5 min).
    static func decrement(_ seconds: Int) -> Int {
        max((seconds - 1) / step * step, range.lowerBound)
    }

    /// Libellé court : « 45 min », « 1 h », « 1 h 30 », « 1 h 05 ».
    static func shortLabel(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = seconds % 3600 / 60
        switch (hours, minutes) {
        case (0, _): return "\(minutes) min"
        case (_, 0): return "\(hours) h"
        default: return "\(hours) h \(String(format: "%02d", minutes))"
        }
    }
}
