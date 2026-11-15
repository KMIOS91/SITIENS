//
//  DataHistoryHub.swift
//  SITIENS
//
//  Created by Modibo on 15/05/2025.
//

import Foundation
import UserNotifications
import AVFoundation

/// Sons et rappels du minuteur.
///
/// `@MainActor` : appelé par les vues et le minuteur, qui vivent sur le main thread.
/// Le seul travail lent, l'activation de la session audio, est confié à `AudioSessionActivator`.
@MainActor
@Observable
class DataHistoryHub : HydrationProtocol {
    /// Identifiant fixe : un seul rappel peut être programmé à la fois.
    static let reminderIdentifier = "sitiens.hydration.reminder"

    var audioPlayer: AVAudioPlayer?

    var avAudioEngine = AVAudioEngine()
    var avAudioPlayerNode = AVAudioPlayerNode()

    /// Change à chaque nouveau son et à chaque arrêt. Un son dont l'attente de la session
    /// audio s'achève après un arrêt (ou après un son plus récent) n'est pas joué.
    @ObservationIgnored private var playbackID = 0

    /// Son de fin de minuteur.
    func playingSound(audioFile: String) {
        guard let url = Bundle.main.url(forResource: audioFile, withExtension: "mp3") else {
            return print("Erreur lors du chargement du fichier")
        }
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            return print("Erreur pendant la lecture : \(error.localizedDescription)")
        }

        let id = nextPlaybackID()
        // La tâche hérite du main actor : elle se suspend pendant l'activation (faite hors
        // du main thread par l'actor), puis reprend ici pour jouer, sans avoir bloqué l'écran.
        Task {
            await AudioSessionActivator.shared.activateIfNeeded()
            guard id == playbackID else { return }
            play(file)
        }
    }

    private func play(_ file: AVAudioFile) {
        // Le lecteur n'est attaché au moteur qu'une seule fois.
        if avAudioPlayerNode.engine == nil {
            avAudioEngine.attach(avAudioPlayerNode)
        }

        // Arrête un son éventuellement en cours et vide sa file d'attente,
        // pour que deux fins de minuteur ne s'enchaînent pas.
        // Le moteur est aussi arrêté : on ne modifie pas ses connexions pendant qu'il tourne.
        avAudioPlayerNode.stop()
        avAudioEngine.stop()

        avAudioEngine.connect(avAudioPlayerNode,
                              to: avAudioEngine.outputNode,
                              format: file.processingFormat)

        avAudioPlayerNode
            .scheduleFile(
                file,
                at: nil,
                completionCallbackType: .dataPlayedBack
            )

        do {
            try avAudioEngine.start()
            avAudioPlayerNode.play()
        } catch {
            print("Erreur pendant la lecture : \(error.localizedDescription)")
        }
    }

    /// Aperçu d'un son dans les réglages.
    func playSound(sound:String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        let player: AVAudioPlayer
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            return print("Erreur pendant la lecture : \(error.localizedDescription)")
        }
        audioPlayer = player

        let id = nextPlaybackID()
        Task {
            await AudioSessionActivator.shared.activateIfNeeded()
            guard id == playbackID else { return }
            // Session déjà active : `play()` n'a plus à l'activer sur le main thread.
            player.play()
        }
    }

    private func nextPlaybackID() -> Int {
        playbackID += 1
        return playbackID
    }

    func authorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                print("Error requesting authorization: \(error)")
            }
        }
    }

    func stopPlaying(){
        // Annule aussi un son encore en attente de la session audio.
        playbackID += 1
        avAudioEngine.stop()
        avAudioPlayerNode.stop()
        audioPlayer = nil
    }

    func scheduleNotification(in seconds: Int) {
        // Un déclencheur doit être strictement positif.
        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Il est temps de boire de l'eau")
        content.body = String(localized: "Boire de l'eau est essentiel à notre bien-être")
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
