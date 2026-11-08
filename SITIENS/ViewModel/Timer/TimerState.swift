//
//  TimerState.swift
//  SITIENS
//
//  Les différents états du minuteur, et ce que chacun permet.
//

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
        case .unset: "Choisissez une durée"
        case .ready: "Prêt"
        case .running: "avant de boire"
        case .paused: "En pause"
        case .finished: "C'est l'heure de boire"
        }
    }

    var primarySymbol: String {
        self == .running ? "pause.fill" : "play.fill"
    }

    var primaryLabel: String {
        switch self {
        case .running: "Mettre en pause"
        case .paused: "Reprendre"
        default: "Démarrer"
        }
    }

    var canToggle: Bool {
        self == .ready || self == .running || self == .paused
    }

    var canReset: Bool {
        self == .paused || self == .finished
    }
}
