//
//  HydrationTimerTests.swift
//  SITIENSTests
//
//  Teste la logique du minuteur sans attendre : l'horloge est simulée,
//  et les effets (son, notification, Live Activity) sont remplacés par des espions.
//

import Testing
import Foundation
@testable import SITIENS

@MainActor
struct HydrationTimerTests {

    // MARK: - Outils de test

    /// Horloge contrôlée par le test : on avance le temps d'un coup au lieu d'attendre.
    final class TestClock {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        func advance(by seconds: TimeInterval) { now += seconds }
    }

    /// Espion : enregistre les appels reçus au lieu de jouer un son ou d'envoyer une notification.
    final class HydrationSpy: HydrationProtocol {
        var playedSounds: [String] = []
        var scheduledNotifications: [Int] = []
        var cancelledNotifications = 0
        var stopCount = 0

        func playingSound(audioFile: String) { playedSounds.append(audioFile) }
        func stopPlaying() { stopCount += 1 }
        func playSound(sound: String) {}
        func authorization() {}
        func scheduleNotification(in seconds: Int) { scheduledNotifications.append(seconds) }
        func cancelNotification() { cancelledNotifications += 1 }
    }

    final class LiveActivitySpy: LiveActivityControlling {
        var events: [String] = []
        func start(remaining: Int, total: Int) { events.append("start \(remaining)/\(total)") }
        func pause(remaining: Int) { events.append("pause \(remaining)") }
        func finish() { events.append("finish") }
        func endAll() { events.append("endAll") }
    }

    let clock = TestClock()
    let hydration = HydrationSpy()
    let liveActivity = LiveActivitySpy()
    /// Un espace de sauvegarde neuf pour chaque test : les tests ne se gênent pas entre eux.
    let defaults = UserDefaults(suiteName: "HydrationTimerTests-\(UUID().uuidString)")!

    func makeTimer() -> HydrationTimer {
        HydrationTimer(hydration: hydration, liveActivity: liveActivity, defaults: defaults, now: { [clock] in clock.now })
    }

    /// Minuteur de 10 minutes avec un son choisi, prêt à démarrer.
    func makeReadyTimer() -> HydrationTimer {
        let timer = makeTimer()
        timer.sound = "basique"
        timer.setDuration(600)
        return timer
    }

    // MARK: - État initial et réglages

    @Test func withoutSettingsTheTimerIsUnset() {
        let timer = makeTimer()
        #expect(timer.state == .unset)
        #expect(timer.progress == 0)
    }

    @Test func choosingADurationMakesTheTimerReady() {
        let timer = makeReadyTimer()
        #expect(timer.state == .ready)
        #expect(timer.remaining == 600)
        #expect(timer.progress == 1)
    }

    @Test func durationCannotChangeWhileRunning() {
        let timer = makeReadyTimer()
        timer.start()
        timer.setDuration(3600)
        #expect(timer.duration == 600)
    }

    // MARK: - Décompte

    @Test func startSchedulesTheReminder() {
        let timer = makeReadyTimer()
        timer.start()
        #expect(timer.state == .running)
        #expect(hydration.scheduledNotifications == [600])
        #expect(liveActivity.events == ["start 600/600"])
    }

    @Test func tickComputesRemainingFromTheClock() {
        let timer = makeReadyTimer()
        timer.start()
        clock.advance(by: 30)
        timer.tick()
        #expect(timer.remaining == 570)
        #expect(timer.progress == 0.95)
    }

    @Test func pauseThenResumeKeepsElapsedTime() {
        let timer = makeReadyTimer()
        timer.start()
        clock.advance(by: 100)
        timer.tick()
        timer.pause()
        #expect(timer.state == .paused)
        #expect(hydration.cancelledNotifications == 1)

        // Le temps passé en pause ne compte pas.
        clock.advance(by: 1000)
        timer.start()
        #expect(hydration.scheduledNotifications == [600, 500])

        clock.advance(by: 50)
        timer.tick()
        #expect(timer.remaining == 450)
    }

    @Test func reachingZeroPlaysTheSound() {
        let timer = makeReadyTimer()
        timer.start()
        clock.advance(by: 600)
        timer.tick()
        #expect(timer.state == .finished)
        #expect(hydration.playedSounds == ["basique"])
        #expect(liveActivity.events.last == "finish")
    }

    @Test func resetRestoresTheFullDuration() {
        let timer = makeReadyTimer()
        timer.start()
        clock.advance(by: 120)
        timer.tick()
        timer.pause()
        timer.reset()
        #expect(timer.state == .ready)
        #expect(timer.remaining == 600)
        #expect(hydration.stopCount == 1)
        #expect(liveActivity.events.last == "endAll")
    }

    // MARK: - Sauvegarde

    @Test func pausedTimerIsRestoredAfterRelaunch() {
        let timer = makeReadyTimer()
        timer.start()
        clock.advance(by: 60)
        timer.tick()
        timer.pause()

        let relaunched = makeTimer()
        #expect(relaunched.state == .paused)
        #expect(relaunched.remaining == 540)
    }

    @Test func runningTimerKeepsCountingAfterRelaunch() {
        let timer = makeReadyTimer()
        timer.start()

        // L'app est fermée pendant 2 minutes.
        clock.advance(by: 120)
        let relaunched = makeTimer()
        #expect(relaunched.state == .running)
        #expect(relaunched.remaining == 480)
    }

    @Test func countdownFinishedWhileClosedDoesNotPlayTheSound() {
        let timer = makeReadyTimer()
        timer.start()

        clock.advance(by: 900)
        let relaunched = makeTimer()
        #expect(relaunched.state == .finished)
        #expect(hydration.playedSounds.isEmpty)
    }
}
