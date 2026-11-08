//
//  RoundIconButton.swift
//  SITIENS
//
//  Bouton rond en verre (Liquid Glass) avec une icône SF Symbols.
//  Utilisé par le minuteur et par le suivi d'hydratation pour un style identique.
//

import SwiftUI

struct RoundIconButton: View {
    enum Prominence {
        /// Action principale : grand bouton coloré.
        case primary
        /// Action secondaire : petit bouton en verre neutre.
        case secondary
    }

    let systemImage: String
    var prominence: Prominence = .secondary
    let action: () -> Void

    var body: some View {
        // Les deux styles de verre sont des types différents : on ne peut pas les choisir
        // avec un simple opérateur ternaire, d'où le `if` dans un @ViewBuilder.
        if prominence == .primary {
            button
                .buttonStyle(.glassProminent)
                .tint(Theme.water)
        } else {
            button
                .buttonStyle(.glass)
        }
    }

    private var button: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(prominence == .primary
                      ? .system(size: 32, weight: .semibold)
                      : .title2.weight(.semibold))
                .frame(width: diameter, height: diameter)
                // Quand l'icône change (lecture ↔ pause), elle se transforme au lieu d'être remplacée d'un coup.
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonBorderShape(.circle)
    }

    private var diameter: CGFloat {
        prominence == .primary ? 84 : 56
    }
}

#Preview {
    HStack(spacing: 32) {
        RoundIconButton(systemImage: "arrow.counterclockwise") {}
        RoundIconButton(systemImage: "play.fill", prominence: .primary) {}
    }
}
