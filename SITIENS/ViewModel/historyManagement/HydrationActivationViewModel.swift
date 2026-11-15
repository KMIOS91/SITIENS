//
//  HydrationActivationViewModel.swift
//  SITIENS
//
//  Created by Modibo on 09/04/2025.
//

import Foundation

@MainActor
@Observable
class HydrationActivationViewModel  {
    let hydrationProtocol : HydrationProtocol

    init(hydrationProtocol : HydrationProtocol = DataHistoryHub()) {
        self.hydrationProtocol = hydrationProtocol
    }

    func playingSound(audioFile : String) {
        hydrationProtocol.playingSound(audioFile: audioFile)
    }

    func stopPlaying(){
        hydrationProtocol.stopPlaying()
    }

    func formatTimer(_ secondes: Int) -> String {
        let hours = secondes / 3600
        let minutes = (secondes % 3600) / 60
        let seconds = (secondes % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Durée en toutes lettres, dans la langue de l'appareil :
    /// « 1 heure et 30 minutes », « 1 hour, 30 minutes », « 1 Stunde und 30 Minuten »…
    /// Foundation gère les pluriels et les mots de liaison de chaque langue.
    func formatHour(_ secondes : Int) -> String {
        Duration.seconds(secondes)
            .formatted(.units(allowed: [.hours, .minutes], width: .wide, zeroValueUnits: .hide))
    }

    func playSound(sound:String) {
        hydrationProtocol.playSound(sound: sound)
    }

    func authorization(){
        hydrationProtocol.authorization()
    }

    func scheduleNotification(in seconds: Int) {
        hydrationProtocol.scheduleNotification(in: seconds)
    }

    func cancelNotification() {
        hydrationProtocol.cancelNotification()
    }
}
