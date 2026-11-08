//
//  WaterDrop.swift
//  SITIENS
//
//  Goutte qui se remplit d'eau, avec une vague animée et le pourcentage au centre.
//

import SwiftUI

struct WaterDrop: View {
    /// Niveau de remplissage, entre 0 (vide) et 1 (plein).
    let level: Double

    var body: some View {
        ZStack {
            // Contour : la goutte vide, très discrète.
            dropShape
                .foregroundStyle(Theme.water.opacity(0.10))

            // TimelineView redessine la vague à chaque image : son décalage dépend de l'heure,
            // donc l'animation ne s'arrête jamais, même après un changement d'onglet.
            // Elle se met en pause quand la goutte est vide, pour économiser la batterie.
            TimelineView(.animation(paused: level == 0)) { context in
                WaterWave(
                    progress: level,
                    waveHeight: 0.035,
                    offset: wavePhase(at: context.date)
                )
                .fill(
                    LinearGradient(
                        colors: [Theme.waterLight, Theme.water],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .overlay { bubbles }
            .mask { dropShape }

            Text(level, format: .percent.precision(.fractionLength(0)))
                .font(.system(.title, design: .rounded, weight: .semibold))
                .monospacedDigit()
                // Blanc sur l'eau, bleu sur la goutte vide : le texte reste toujours lisible.
                .foregroundStyle(level > 0.45 ? .white : Theme.water)
                .contentTransition(.numericText())
                .offset(y: 30)
        }
        .animation(.easeInOut(duration: 0.6), value: level)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Objectif du jour")
        .accessibilityValue(Text(level, format: .percent.precision(.fractionLength(0))))
    }

    private var dropShape: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    /// Décalage de la vague, en degrés : un tour complet toutes les 3 secondes.
    private func wavePhase(at date: Date) -> CGFloat {
        let seconds = date.timeIntervalSinceReferenceDate
        return CGFloat(seconds.truncatingRemainder(dividingBy: 3) / 3 * 360)
    }

    /// Petites bulles claires dans l'eau.
    private var bubbles: some View {
        ZStack {
            Bubble(size: 15, x: -20, y: 0)
            Bubble(size: 15, x: 40, y: 30)
            Bubble(size: 25, x: -30, y: 80)
            Bubble(size: 25, x: 50, y: 70)
            Bubble(size: 10, x: 40, y: 100)
            Bubble(size: 10, x: -40, y: 50)
        }
        .opacity(level > 0 ? 1 : 0)
    }
}

/// Surface de l'eau : une sinusoïde dont la hauteur dépend du niveau.
struct WaterWave: Shape {
    /// Niveau de l'eau, entre 0 et 1.
    var progress: CGFloat
    /// Amplitude de la vague, en proportion de la hauteur.
    var waveHeight: CGFloat
    /// Décalage horizontal de la vague, en degrés.
    var offset: CGFloat

    /// `animatableData` indique à SwiftUI quelle valeur interpoler pendant une animation :
    /// ici le niveau, pour que l'eau monte en douceur quand on ajoute un verre.
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // Goutte vide : pas de vague du tout (sinon un filet d'eau resterait visible).
        guard progress > 0 else { return Path() }

        let waterTop = (1 - min(progress, 1)) * rect.height
        let amplitude = waveHeight * rect.height

        var path = Path()
        path.move(to: CGPoint(x: 0, y: waterTop))
        for x in stride(from: 0, through: rect.width, by: 2) {
            let sine = sin(Angle(degrees: x + offset).radians)
            path.addLine(to: CGPoint(x: x, y: waterTop + amplitude * sine))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

private struct Bubble: View {
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat

    var body: some View {
        Circle()
            .fill(.white.opacity(0.18))
            .frame(width: size, height: size)
            .offset(x: x, y: y)
    }
}

#Preview {
    HStack(spacing: 24) {
        WaterDrop(level: 0)
        WaterDrop(level: 0.35)
        WaterDrop(level: 0.8)
    }
    .frame(height: 220)
    .padding()
}
