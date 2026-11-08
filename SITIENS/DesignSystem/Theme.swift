//
//  Theme.swift
//  SITIENS
//
//  Couleurs et fonds partagés par toute l'app.
//

import SwiftUI
import UIKit

/// Point unique pour les couleurs de l'app : changer une teinte ici la change partout.
enum Theme {
    /// Bleu « eau » : la couleur principale (anneau, bouton principal).
    static let water = Color(
        light: Color(red: 0.05, green: 0.50, blue: 0.85),
        dark: Color(red: 0.35, green: 0.72, blue: 1.00)
    )

    /// Variante plus claire du bleu, utilisée pour les dégradés.
    static let waterLight = Color(
        light: Color(red: 0.30, green: 0.80, blue: 0.95),
        dark: Color(red: 0.55, green: 0.88, blue: 1.00)
    )

    /// Dégradé de l'anneau de progression : du bleu clair (en haut) au bleu profond (en bas).
    /// Linéaire plutôt que circulaire : un dégradé circulaire crée une démarcation là où il se referme.
    static let ringGradient = LinearGradient(
        colors: [waterLight, water],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
}

extension Color {
    /// Crée une couleur qui change selon le mode clair ou sombre.
    ///
    /// `UIColor` sait se recalculer quand l'apparence change : SwiftUI en profite automatiquement.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

/// Fond des écrans : la couleur système avec un léger voile bleu en haut.
struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Theme.water.opacity(0.14), .clear],
            startPoint: .top,
            endPoint: .center
        )
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
