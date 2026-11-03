//
//  HydrationActivationViewModel.swift
//  SITIENS
//
//  Created by Modibo on 09/04/2025.
//

import Foundation

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

    func formatHour(_ secondes : Int) -> String{
        let hours = secondes / 3600
        let minutes = (secondes % 3600) / 60
        if hours == 0 {
            return "\(minutes) \(minutes > 1 ? "minutes" : "minute")"
        } else if minutes == 0 {
            return "\(hours) \(hours > 1 ? "heures" : "heure")"
        } else {
            return "\(hours) \(hours > 1 ? "heures" : "heure") et \(minutes) \(minutes > 1 ? "minutes" : "minute")"
        }
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
