//
//  HydrationProtocol.swift
//  SITIENS
//
//  Created by Modibo on 15/05/2025.
//

import Foundation

protocol HydrationProtocol {
    func playingSound(audioFile : String)
    func stopPlaying()
    func playSound(sound:String)
    func authorization()
    /// Programme le rappel d'hydratation dans `seconds` secondes.
    /// Le rappel est géré par iOS : il arrive même si l'app est en arrière-plan ou fermée.
    func scheduleNotification(in seconds: Int)
    /// Annule le rappel programmé (pause ou réinitialisation du minuteur).
    func cancelNotification()
}
