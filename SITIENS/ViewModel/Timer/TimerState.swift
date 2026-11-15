//
//  TimerState.swift
//  SITIENS
//
//  Les différents états du minuteur, et ce que chacun permet.
//

import Foundation

/// Chaque état sait comment il s'affiche et quels boutons il autorise.
enum TimerState: Equatable {
    /// Aucune durée ou aucun son choisi.
    case unset
    /// Durée choisie, minuteur pas encore lancé.
    case ready
    case running
    case paused
    /// Le décompte est arrivé à zéro : il est temps de boire.
    case finished

    /// Petit texte affiché sous le temps restant.
    var caption: String {
        switch self {
        case .unset: String(localized: "Choisissez une durée")
        case .ready: String(localized: "Prêt")
        case .running: String(localized: "avant de boire")
        case .paused: String(localized: "En pause")
        case .finished: String(localized: "C'est l'heure de boire")
        }
    }

    var primarySymbol: String {
        self == .running ? "pause.fill" : "play.fill"
    }

    var primaryLabel: String {
        switch self {
        case .running: String(localized: "Mettre en pause")
        case .paused: String(localized: "Reprendre")
        default: String(localized: "Démarrer")
        }
    }

    var canToggle: Bool {
        self == .ready || self == .running || self == .paused
    }

    var canReset: Bool {
        self == .paused || self == .finished
    }
}
