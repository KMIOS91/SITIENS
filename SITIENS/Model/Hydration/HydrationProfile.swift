//
//  HydrationProfile.swift
//  SITIENS
//
//  Profils d'utilisateur et quantité d'eau à boire chaque jour.
//
//  Source : EFSA (Autorité européenne de sécurité des aliments), « Scientific Opinion on
//  Dietary Reference Values for water », EFSA Journal 2010;8(3):1459.
//  L'EFSA donne des apports d'eau *totale* (boissons + eau des aliments), pour une température
//  et une activité physique modérées. Les boissons en représentent environ 80 % :
//  c'est cette part, à boire, que l'app affiche comme objectif.
//

import Foundation

/// Profil choisi dans les réglages : il fixe l'objectif du jour.
///
/// La `rawValue` est un identifiant stable enregistré dans UserDefaults ;
/// le texte affiché est `name`, qui peut changer sans casser les sauvegardes.
enum HydrationProfile: String, CaseIterable, Identifiable {
    case woman
    case man
    case pregnant
    case breastfeeding
    case girl9to13
    case boy9to13
    case child4to8

    var id: Self { self }

    var name: String {
        switch self {
        case .woman: "Femme (14 ans et plus)"
        case .man: "Homme (14 ans et plus)"
        case .pregnant: "Femme enceinte"
        case .breastfeeding: "Femme allaitante"
        case .girl9to13: "Fille de 9 à 13 ans"
        case .boy9to13: "Garçon de 9 à 13 ans"
        case .child4to8: "Enfant de 4 à 8 ans"
        }
    }

    /// Apport d'eau totale de référence de l'EFSA, en litres par jour.
    /// Les personnes âgées ont les mêmes références que les adultes.
    var totalWaterLiters: Double {
        switch self {
        case .woman: 2.0
        case .man: 2.5
        case .pregnant: 2.3       // femme + 0,3 L
        case .breastfeeding: 2.7  // femme + 0,7 L
        case .girl9to13: 1.9
        case .boy9to13: 2.1
        case .child4to8: 1.6
        }
    }

    /// Part de l'eau totale apportée par les boissons (le reste vient des aliments).
    static let drinkShare = 0.8

    /// Quantité à boire par jour, en litres, arrondie au décilitre.
    var dailyLiters: Double {
        (totalWaterLiters * Self.drinkShare * 10).rounded() / 10
    }

    /// Profil enregistré : identifiant actuel, ou nom d'une ancienne version de l'app.
    /// Les anciens profils sans équivalent (« Sportifs », « Nourrissons »…) donnent `nil` :
    /// l'utilisateur choisit à nouveau.
    init?(storedValue: String) {
        if let profile = HydrationProfile(rawValue: storedValue) {
            self = profile
        } else if storedValue == "Femmes enceintes" {
            self = .pregnant
        } else {
            return nil
        }
    }
}

/// Situations où il faut penser à boire davantage, certains jours.
///
/// Elles ne changent pas l'objectif : aucune source fiable ne donne de quantité fixe à ajouter
/// par jour (les besoins dépendent de la durée, de l'intensité et de la personne).
/// Chacune affiche un conseil repris de sa source, avec un lien vers celle-ci.
enum HydrationExtraNeed: String, CaseIterable, Identifiable {
    case exercise
    case heat

    var id: Self { self }

    var name: String {
        switch self {
        case .exercise: "Activité physique"
        case .heat: "Forte chaleur"
        }
    }

    var detail: String {
        switch self {
        case .exercise: "Séance de sport ou travail physique"
        case .heat: "Canicule, climat chaud"
        }
    }

    /// Conseil affiché quand la situation est cochée, repris de `sourceName`.
    var advice: String {
        switch self {
        case .exercise:
            "L'effort fait perdre de 0,5 à 2,5 litres d'eau par heure. Buvez dès le début de l'exercice, sans attendre la soif."
        case .heat:
            "Buvez régulièrement de l'eau, sans attendre d'avoir soif. En travaillant dehors : au moins un verre d'eau toutes les 15 à 20 minutes."
        }
    }

    var sourceName: String {
        switch self {
        case .exercise: "VIDAL – Les besoins en eau pendant l'effort"
        case .heat: "Santé.fr – Fortes chaleurs et canicule"
        }
    }

    var sourceURL: URL {
        switch self {
        case .exercise:
            URL(string: "https://www.vidal.fr/sante/nutrition/equilibre-alimentaire-sportif/besoins-eau-sportifs.html")!
        case .heat:
            URL(string: "https://www.sante.fr/fortes-chaleurs-et-canicule-se-proteger-et-proteger-ses-proches")!
        }
    }
}
