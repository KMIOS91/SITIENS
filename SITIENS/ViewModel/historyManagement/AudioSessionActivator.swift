//
//  AudioSessionActivator.swift
//  SITIENS
//
//  Configure et active la session audio de l'app, une seule fois, hors du main thread.
//

import AVFoundation

/// Active la session audio avant de jouer un son.
///
/// `setActive(true)` est synchrone : il attend la réponse du système audio, ce qui peut
/// figer l'interface s'il est appelé sur le main thread. Un `actor` exécute ses méthodes
/// hors du main thread, et une seule à la fois : la session n'est configurée qu'une fois,
/// même si deux sons sont demandés en même temps.
actor AudioSessionActivator {
    static let shared = AudioSessionActivator()

    private var isActive = false

    /// Catégorie `.ambient` : le son respecte le mode silencieux (comme la notification
    /// de fin de minuteur) et se mélange à la musique de l'utilisateur au lieu de la couper.
    func activateIfNeeded() {
        guard !isActive else { return }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient)
            try session.setActive(true)
            isActive = true
        } catch {
            print("Session audio non activée : \(error.localizedDescription)")
        }
    }
}
