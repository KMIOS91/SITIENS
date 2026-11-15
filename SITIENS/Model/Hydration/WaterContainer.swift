//
//  WaterContainer.swift
//  SITIENS
//
//  Récipients proposés pour boire, avec leur contenance.
//

import Foundation

/// Récipient choisi dans les réglages : chaque appui sur « + » ajoute sa contenance.
///
/// La `rawValue` reprend les chaînes enregistrées par les versions précédentes.
enum WaterContainer: String, CaseIterable, Identifiable {
    case small = "Petit – 200 ml"
    case medium = "Moyen – 300 ml"
    case large = "Grand – 500 ml"

    var id: Self { self }

    /// Nom affiché, traduit. La `rawValue` (en français) reste l'identifiant enregistré.
    var name: String {
        switch self {
        case .small: String(localized: "Petit – 200 ml")
        case .medium: String(localized: "Moyen – 300 ml")
        case .large: String(localized: "Grand – 500 ml")
        }
    }

    var milliliters: Int {
        switch self {
        case .small: 200
        case .medium: 300
        case .large: 500
        }
    }

    /// Image du récipient dans le catalogue d'assets.
    var imageName: String {
        switch self {
        case .small: "SmallGlace"
        case .medium: "MediumGlace"
        case .large: "LargeGlace"
        }
    }
}
