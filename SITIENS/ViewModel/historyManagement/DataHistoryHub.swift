//
//  DataHistoryHub.swift
//  SITIENS
//
//  Created by Modibo on 15/05/2025.
//

import Foundation
import UserNotifications
import AVFoundation

@Observable
class DataHistoryHub : HydrationProtocol {
    /// Identifiant fixe : un seul rappel peut être programmé à la fois.
    static let reminderIdentifier = "sitiens.hydration.reminder"

    var audioPlayer: AVAudioPlayer?

    var avAudioEngine = AVAudioEngine()
    var avAudioPlayerNode = AVAudioPlayerNode()

    func playingSound(audioFile: String) {
        guard let url = Bundle.main.url(forResource: audioFile, withExtension: "mp3") else{
            return  print("Erreur lors du chargement du fichier")
        }

        do{
            let file = try AVAudioFile(forReading: url)
            avAudioEngine.attach(avAudioPlayerNode)

            avAudioEngine
                .connect(
                    avAudioPlayerNode,
                    to: avAudioEngine.outputNode,
                    format: file.processingFormat
                )

              avAudioPlayerNode
                .scheduleFile(
                    file,
                    at: nil,
                    completionCallbackType: .dataPlayedBack
                )

            try avAudioEngine.start()
            avAudioPlayerNode.play()

        }catch {
            print("Erreur pendant la lecture : \(error.localizedDescription)")
        }
    }

    func playSound(sound:String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Erreur pendant la lecture : \(error.localizedDescription)")
        }
    }

    func authorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                print("Error requesting authorization: \(error)")
            }
        }
    }

    func stopPlaying(){
        avAudioEngine.stop()
        avAudioPlayerNode.stop()
        audioPlayer = nil
    }

    func scheduleNotification(in seconds: Int) {
        // Un déclencheur doit être strictement positif.
        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Il est temps de boire de l'eau"
        content.body = "Boire de l'eau est essentiel à notre bien-être"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(seconds),
            repeats: false
        )

        // Réutiliser le même identifiant remplace le rappel précédent au lieu d'en empiler plusieurs.
        let request = UNNotificationRequest(
            identifier: Self.reminderIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
    }
}
