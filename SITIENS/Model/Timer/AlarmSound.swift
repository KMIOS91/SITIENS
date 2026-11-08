//
//  AlarmSound.swift
//  SITIENS
//
//  Sons proposés pour la fin du minuteur.
//

/// Son joué quand il est temps de boire.
///
/// La `rawValue` est le nom du fichier .mp3 (dans Model/Audios) : c'est aussi la valeur
/// enregistrée, identique à celle des versions précédentes.
enum AlarmSound: String, CaseIterable, Identifiable {
    case basique
    case ringtone
    case musicBox = "music-box"
    case freshBreeze = "fresh-breeze"
    case cloverFeast = "clover-feast"
    case asphaltSizzle = "asphalt-sizzle"
    case alone
    case coolGuitarLoop = "cool-guitar-loop"
    case futureDesign = "future-design"
    case gardensStylishChill = "gardens-stylish-chill"
    case kugelsicher = "kugelsicher-by-tremoxbeatz"
    case lofiEffect = "lofi-effect"
    case lofiSample = "lofi-sample-if-i-cant-have-you"
    case meditation = "meditation-music-sound-bite"
    case mysticalMusic = "mystical-music"

    var id: Self { self }

    /// Nom affiché dans les réglages.
    var title: String {
        switch self {
        case .basique: "Basique"
        case .ringtone: "Sonnerie"
        case .musicBox: "Boîte à musique"
        case .freshBreeze: "Fresh Breeze"
        case .cloverFeast: "Clover Feast"
        case .asphaltSizzle: "Asphalt Sizzle"
        case .alone: "Alone"
        case .coolGuitarLoop: "Guitare"
        case .futureDesign: "Future Design"
        case .gardensStylishChill: "Gardens – Stylish Chill"
        case .kugelsicher: "Kugelsicher (TremoxBeatz)"
        case .lofiEffect: "Lofi Effect"
        case .lofiSample: "Lofi – If I Can't Have You"
        case .meditation: "Méditation"
        case .mysticalMusic: "Mystical Music"
        }
    }
}
