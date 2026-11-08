//
//  WaterContainer.swift
//  SITIENS
//
//  Récipients proposés pour boire, avec leur contenance.
//

/// Récipient choisi dans les réglages : chaque appui sur « + » ajoute sa contenance.
///
/// Comme pour `HydrationProfile`, la `rawValue` reprend les chaînes déjà enregistrées.
enum WaterContainer: String, CaseIterable, Identifiable {
    case small = "Petit – 200 ml"
    case medium = "Moyen – 300 ml"
    case large = "Grand – 500 ml"

    var id: Self { self }

    var name: String { rawValue }

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
