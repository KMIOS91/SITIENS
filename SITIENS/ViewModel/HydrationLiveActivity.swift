//
//  HydrationLiveActivity.swift
//  SITIENS
//
//  Démarre, met en pause et termine la Live Activity du minuteur.
//

import ActivityKit
import Foundation

@MainActor
enum HydrationLiveActivity {
    private typealias State = HydrationTimerAttributes.ContentState

    // `Activity` n'est pas `Sendable` : chaque tâche relit la liste des activités
    // au lieu de recevoir une activité venant de l'extérieur.

    /// Le minuteur démarre (ou reprend) avec `remaining` secondes sur une durée totale de `total`.
    static func start(remaining: Int, total: Int) {
        guard remaining > 0, total > 0,
              ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let endDate = Date.now.addingTimeInterval(TimeInterval(remaining))
        // `staleDate` : à la fin du minuteur, le système sait que l'affichage doit passer à « Buvez ! ».
        let content = ActivityContent(state: State(endDate: endDate, frozenRemaining: nil), staleDate: endDate)

        Task {
            var reused = false
            for activity in Activity<HydrationTimerAttributes>.activities {
                if !reused && activity.attributes.totalSeconds == total {
                    // Reprise après une pause avec la même durée : on met à jour l'activité existante.
                    await activity.update(content)
                    reused = true
                } else {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
            guard !reused else { return }
            do {
                _ = try Activity.request(attributes: HydrationTimerAttributes(totalSeconds: total), content: content)
            } catch {
                print("Live Activity impossible à démarrer : \(error.localizedDescription)")
            }
        }
    }

    /// Le minuteur est en pause : on fige le temps restant.
    static func pause(remaining: Int) {
        guard remaining > 0 else { return }
        let state = State(endDate: .now.addingTimeInterval(TimeInterval(remaining)), frozenRemaining: remaining)
        let content = ActivityContent(state: state, staleDate: nil)
        Task {
            for activity in Activity<HydrationTimerAttributes>.activities {
                await activity.update(content)
            }
        }
    }

    /// Le minuteur est arrivé à zéro : on affiche « Il est temps de boire ! » sur l'écran verrouillé.
    static func finish() {
        let final = ActivityContent(state: State(endDate: .now, frozenRemaining: 0), staleDate: nil)
        Task {
            for activity in Activity<HydrationTimerAttributes>.activities {
                await activity.end(final, dismissalPolicy: .default)
            }
        }
    }

    /// Réinitialisation : la Live Activity disparaît.
    static func endAll() {
        Task {
            for activity in Activity<HydrationTimerAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
