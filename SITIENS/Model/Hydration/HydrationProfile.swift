//
//  HydrationProfile.swift
//  SITIENS
//
//  Profils d'utilisateur et besoin en eau quotidien de chacun.
//

/// Profil choisi dans les réglages : il fixe l'objectif du jour.
///
/// La `rawValue` est le texte affiché et aussi la valeur enregistrée
/// (UserDefaults et historique) : elle reprend à l'identique les chaînes
/// des versions précédentes, pour que les sauvegardes existantes restent lisibles.
enum HydrationProfile: String, CaseIterable, Identifiable {
    case infant = "Nourrissons"
    case pregnantWoman = "Femmes enceintes"
    case elderly = "Personnes âgées"
    case athlete = "Sportifs"
    case youth = "Enfants et adolescents"
    case hotEnvironmentWorker = "Travailleurs en environnement chaud"
    case chronicIllness = "Personnes souffrant de maladies chroniques"
    case overweight = "Personnes en surpoids ou obèses"
    case highAltitude = "Voyageurs ou personnes en altitude"
    case medication = "Personnes sous traitement médicamenteux"

    var id: Self { self }

    var name: String { rawValue }

    /// Quantité d'eau recommandée par jour, en litres.
    var dailyLiters: Double {
        switch self {
        case .infant: 0.7
        case .pregnantWoman, .youth: 2.5
        case .elderly, .chronicIllness, .medication: 2
        case .athlete, .hotEnvironmentWorker, .overweight, .highAltitude: 3
        }
    }
}
