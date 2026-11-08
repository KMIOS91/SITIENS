//
//  ProgressRing.swift
//  SITIENS
//
//  Anneau de progression réutilisable, avec un contenu libre au centre.
//

import SwiftUI

struct ProgressRing<Content: View>: View {
    /// Part restante, entre 0 (vide) et 1 (plein).
    let progress: Double
    var lineWidth: CGFloat = 14
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            // Piste : l'anneau complet, très discret.
            Circle()
                .stroke(Theme.water.opacity(0.12), lineWidth: lineWidth)

            // Progression : part du haut (−90°) et tourne dans le sens horaire.
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Theme.ringGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            content
        }
        // Le trait déborde de moitié de chaque côté du cercle : on lui laisse la place.
        .padding(lineWidth / 2)
    }
}

#Preview {
    ProgressRing(progress: 0.65) {
        Text("06:30")
            .font(.system(size: 56, weight: .light, design: .rounded))
    }
    .frame(width: 280, height: 280)
}
