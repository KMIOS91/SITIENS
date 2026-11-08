//
//  HydrationTimer.swift
//  SITIENS
//
//  Toute la logique du minuteur : décompte, pause, reprise, fin et sauvegarde.
//  Aucune dépendance à SwiftUI : le modèle se teste sans afficher d'écran.
//

import Foundation
import Observation

@MainActor
@Observable
final class HydrationTimer {
    /// Clés de sauvegarde. Ce sont celles des versions précédentes de l'app (sauf `startDate`, nouvelle),
    /// pour qu'une mise à jour retrouve les réglages et le temps restant.
    enum Keys {
        static let duration = "hour"
        static let sound = "selectedItems"
        static let remaining = "timeInterval"
        static let elapsedBeforePause = "elapseBeforPause"
        static let startDate = "timerStartDate"
    }

    /// Durée totale choisie, en secondes.
    private(set) var duration: Int {
        didSet { defaults.set(duration, forKey: Keys.duration) }
    }

    /// Son joué à la fin du décompte.
    var sound: String {
        didSet { defaults.set(sound, forKey: Keys.sound) }
    }

    /// Secondes restantes avant de boire.
    private(set) var remaining: Int {
        didSet { defaults.set(remaining, forKey: Keys.remaining) }
    }

    private(set) var isRunning = false

    /// Temps déjà écoulé lors des périodes précédentes (avant une pause).
    @ObservationIgnored private var elapsedBeforePause: Int {
        didSet { defaults.set(elapsedBeforePause, forKey: Keys.elapsedBeforePause) }
    }

    /// Début de la période de décompte en cours, `nil` si le minuteur est arrêté.
    @ObservationIgnored private var startDate: Date? {
        didSet { defaults.set(startDate, forKey: Keys.startDate) }
    }

    @ObservationIgnored private var tickTask: Task<Void, Never>?

    // Dépendances injectées : les vraies dans l'app, des fausses dans les tests.
    @ObservationIgnored private let hydration: HydrationProtocol
    @ObservationIgnored private let liveActivity: LiveActivityControlling
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let now: () -> Date

    init(
        hydration: HydrationProtocol,
        liveActivity: LiveActivityControlling = SystemLiveActivity(),
        defaults: UserDefaults = .standard,
        now: @escaping () -> Date = { .now }
    ) {
        self.hydration = hydration
        self.liveActivity = liveActivity
        self.defaults = defaults
        self.now = now

        // Les `didSet` ne sont pas appelés dans `init` : relire ces valeurs ne les réécrit pas.
        duration = defaults.integer(forKey: Keys.duration)
        sound = defaults.string(forKey: Keys.sound) ?? ""
        remaining = defaults.integer(forKey: Keys.remaining)
        elapsedBeforePause = defaults.integer(forKey: Keys.elapsedBeforePause)
        startDate = defaults.object(forKey: Keys.startDate) as? Date

        restoreCountdownAfterRelaunch()
    }

    // MARK: - État

    /// L'état se déduit des données : il n'est jamais stocké, donc jamais désynchronisé.
    var state: TimerState {
        if duration == 0 || sound.isEmpty { return .unset }
        if remaining == 0 { return .finished }
        if isRunning { return .running }
        return remaining == duration ? .ready : .paused
    }

    /// Part restante, entre 0 et 1, pour l'anneau.
    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(Double(remaining) / Double(duration), 1)
    }

    // MARK: - Actions

    /// Nouvelle durée validée dans les réglages : le minuteur repart de zéro.
    func setDuration(_ seconds: Int) {
        guard !isRunning else { return }
        duration = seconds
        remaining = seconds
        elapsedBeforePause = 0
        startDate = nil
    }

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard state == .ready || state == .paused else { return }
        hydration.authorization()

        let remainingAtStart = max(duration - elapsedBeforePause, 0)
        startDate = now()
        isRunning = true

        // Le rappel est confié à iOS dès le départ : il arrivera même si l'app passe en arrière-plan.
        hydration.scheduleNotification(in: remainingAtStart)
        liveActivity.start(remaining: remainingAtStart, total: duration)
        startTicking()
    }

    func pause() {
        guard isRunning else { return }
        stopCounting()
        isRunning = false
        hydration.cancelNotification()
        liveActivity.pause(remaining: remaining)
    }

    func reset() {
        stopCounting()
        isRunning = false
        remaining = duration
        elapsedBeforePause = 0
        hydration.stopPlaying()
        hydration.cancelNotification()
        liveActivity.endAll()
    }

    /// Recalcule le temps restant à partir de l'heure réelle.
    /// Se baser sur l'horloge (et non compter les secondes) évite toute dérive.
    /// `internal` et non `private` : les tests l'appellent directement au lieu d'attendre.
    func tick() {
        guard isRunning, let startDate else { return }
        let elapsed = elapsedBeforePause + Int(now().timeIntervalSince(startDate))
        remaining = max(duration - elapsed, 0)

        if remaining == 0 {
            finish()
        }
    }

    // MARK: - Étapes internes

    /// Appelle `tick()` chaque seconde jusqu'à l'annulation de la tâche.
    private func startTicking() {
        tickTask?.cancel()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self?.tick()
            }
        }
    }

    /// Une `startDate` sauvegardée signifie que l'app a été fermée pendant un décompte.
    /// La notification, gérée par iOS, est toujours programmée : on reprend donc l'affichage.
    private func restoreCountdownAfterRelaunch() {
        guard let startDate else { return }
        let elapsed = elapsedBeforePause + Int(now().timeIntervalSince(startDate))

        if elapsed < duration {
            isRunning = true
            remaining = duration - elapsed
            startTicking()
        } else {
            // Terminé pendant que l'app était fermée : la notification a déjà prévenu, pas de son.
            self.startDate = nil
            elapsedBeforePause = 0
            remaining = 0
        }
    }

    private func finish() {
        stopCounting()
        isRunning = false
        elapsedBeforePause = 0
        liveActivity.finish()
        hydration.playingSound(audioFile: sound)
    }

    /// Arrête le décompte et ajoute la période écoulée au temps déjà consommé.
    private func stopCounting() {
        tickTask?.cancel()
        tickTask = nil
        if let startDate {
            elapsedBeforePause += Int(now().timeIntervalSince(startDate))
        }
        startDate = nil
    }
}
