//
//  TimerControls.swift
//  SITIENS
//
//  Created by Modibo on 22/05/2025.
//

import SwiftUI

/// Les deux boutons du minuteur. La vue ne contient aucune logique :
/// elle affiche un état et signale les appuis par des closures.
struct TimerControls: View {
    let state: TimerState
    let onReset: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 32) {
            RoundIconButton(systemImage: "arrow.counterclockwise", action: onReset)
                .disabled(!state.canReset)
                .accessibilityLabel("Réinitialiser")
                .accessibilityHint("Remet le minuteur à sa durée de départ")

            RoundIconButton(systemImage: state.primarySymbol, prominence: .primary, action: onToggle)
                .disabled(!state.canToggle)
                .background {
                    if state == .running {
                        PulseHalo()
                    }
                }
                .accessibilityLabel(state.primaryLabel)
        }
        // Petite vibration à chaque changement d'état.
        .sensoryFeedback(.impact(weight: .medium), trigger: state)
    }
}

/// Onde qui s'élargit et s'efface en boucle derrière le bouton, tant que le minuteur tourne.
private struct PulseHalo: View {
    var body: some View {
        Circle()
            .fill(Theme.water.opacity(0.3))
            .phaseAnimator([false, true]) { content, expanded in
                content
                    .scaleEffect(expanded ? 1.4 : 1)
                    .opacity(expanded ? 0 : 1)
            } animation: { expanded in
                // Vers l'état élargi : animation lente. Retour au départ : instantané (nil).
                expanded ? .easeOut(duration: 1.6) : nil
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 40) {
        TimerControls(state: .ready, onReset: {}, onToggle: {})
        TimerControls(state: .running, onReset: {}, onToggle: {})
        TimerControls(state: .paused, onReset: {}, onToggle: {})
    }
}
