//
//  WaterTrackerTests.swift
//  SITIENSTests
//
//  Teste le suivi d'hydratation avec une horloge simulée et des espions
//  à la place de l'historique Core Data et du widget.
//

import Testing
import Foundation
@testable import SITIENS

@MainActor
struct WaterTrackerTests {

    // MARK: - Outils de test

    final class TestClock {
        var now: Date
        init(_ date: Date) { now = date }
        func advance(byHours hours: Double) { now += hours * 3600 }
    }

    final class GoalSpy: GoalRecording {
        var recorded: [(profile: String, liters: Double)] = []
        func recordGoal(profile: String, liters: Double) throws { recorded.append((profile, liters)) }
    }

    final class WidgetSpy: HydrationWidgetPublishing {
        var lastLiters: Double?
        var lastTarget: Double?
        func publish(liters: Double, targetLiters: Double) {
            lastLiters = liters
            lastTarget = targetLiters
        }
    }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        return calendar
    }

    /// 1er novembre 2026, 9 h (heure de Paris).
    let clock = TestClock(Date(timeIntervalSince1970: 1_793_520_000))
    let goals = GoalSpy()
    let widget = WidgetSpy()
    let defaults = UserDefaults(suiteName: "WaterTrackerTests-\(UUID().uuidString)")!

    func makeTracker() -> WaterTracker {
        WaterTracker(goals: goals, widget: widget, defaults: defaults, now: { [clock] in clock.now }, calendar: calendar)
    }

    /// Homme adulte (2,0 L à boire) avec un grand verre de 500 ml : 4 verres par jour.
    func makeConfiguredTracker() -> WaterTracker {
        let tracker = makeTracker()
        tracker.profile = .man
        tracker.container = .large
        return tracker
    }

    // MARK: - Réglages

    @Test func withoutSettingsNothingCanBeAdded() {
        let tracker = makeTracker()
        #expect(!tracker.isConfigured)
        #expect(!tracker.canAddGlass)
        tracker.addGlass()
        #expect(tracker.glassesToday == 0)
    }

    @Test func goalIsExpressedInGlasses() {
        let tracker = makeConfiguredTracker()
        #expect(tracker.targetLiters == 2)
        #expect(tracker.glassesPerDay == 4)
    }

    @Test func glassCountIsRoundedUp() {
        let tracker = makeTracker()
        tracker.profile = .woman        // 1,6 L
        tracker.container = .medium     // 5,3 verres → 6
        #expect(tracker.glassesPerDay == 6)
    }

    // MARK: - Ajout de verres

    @Test func addingAGlassUpdatesLitersAndWidget() {
        let tracker = makeConfiguredTracker()
        tracker.addGlass()
        tracker.addGlass()
        #expect(tracker.drunkLiters == 1)
        #expect(tracker.progress == 0.5)
        #expect(widget.lastLiters == 1)
        #expect(!tracker.canChangeSettings)
    }

    @Test func goalIsReachedExactlyAfterTheLastGlass() {
        let tracker = makeConfiguredTracker()
        for _ in 1...4 { tracker.addGlass() }
        #expect(tracker.isGoalReached)
        #expect(tracker.progress == 1)
        #expect(!tracker.canAddGlass)
    }

    @Test func goalIsRecordedOnlyOnce() {
        let tracker = makeConfiguredTracker()
        for _ in 1...10 { tracker.addGlass() }
        #expect(goals.recorded.count == 1)
        #expect(goals.recorded.first?.profile == "Homme (14 ans et plus)")
        #expect(goals.recorded.first?.liters == 2)
    }

    @Test func litersAreCappedAtTheGoal() {
        let tracker = makeTracker()
        tracker.profile = .woman        // 1,6 L
        tracker.container = .large      // 4 verres = 2 L
        for _ in 1...4 { tracker.addGlass() }
        #expect(tracker.drunkLiters == 1.6)
        #expect(tracker.progress == 1)
    }

    @Test func resetEmptiesTheDrop() {
        let tracker = makeConfiguredTracker()
        tracker.addGlass()
        tracker.reset()
        #expect(tracker.glassesToday == 0)
        #expect(tracker.canChangeSettings)
    }

    // MARK: - Sauvegarde et jours

    @Test func relaunchKeepsTheDayWithoutRecordingAgain() {
        let tracker = makeConfiguredTracker()
        for _ in 1...4 { tracker.addGlass() }

        let relaunched = makeTracker()
        relaunched.refresh()
        #expect(relaunched.glassesToday == 4)
        #expect(relaunched.isGoalReached)
        #expect(goals.recorded.count == 1)
    }

    @Test func aNewDayStartsFromZero() {
        let tracker = makeConfiguredTracker()
        tracker.addGlass()

        clock.advance(byHours: 24)
        tracker.refresh()
        #expect(tracker.glassesToday == 0)
        #expect(tracker.profile == .man)
    }

    @Test func laterTheSameDayKeepsTheGlasses() {
        let tracker = makeConfiguredTracker()
        tracker.addGlass()

        clock.advance(byHours: 10)  // 19 h, toujours le 1er novembre
        tracker.refresh()
        #expect(tracker.glassesToday == 1)
    }

    @Test func unknownSavedProfileIsIgnored() {
        defaults.set("Profil supprimé", forKey: WaterTracker.Keys.profile)
        let tracker = makeTracker()
        #expect(tracker.profile == nil)
        #expect(!tracker.isConfigured)
    }

    @Test func legacyProgressIsMigratedToGlasses() {
        // Sauvegarde d'une ancienne version : 50 % de 1,8 L (femme enceinte), en verres de 500 ml.
        defaults.set("Femmes enceintes", forKey: WaterTracker.Keys.profile)
        defaults.set("Grand – 500 ml", forKey: WaterTracker.Keys.container)
        defaults.set(0.5, forKey: WaterTracker.Keys.legacyProgress)

        let tracker = makeTracker()
        #expect(tracker.profile == .pregnant)
        #expect(tracker.glassesToday == 2)   // 0,9 L / 500 ml ≈ 1,8 → 2 verres
        #expect(tracker.drunkLiters == 1)
    }

    @Test func oldProfilesWithoutEquivalentMustBeChosenAgain() {
        defaults.set("Sportifs", forKey: WaterTracker.Keys.profile)
        #expect(makeTracker().profile == nil)
    }

    // MARK: - Besoins supplémentaires

    @Test func extraNeedsRaiseTheGoal() {
        let tracker = makeConfiguredTracker()
        tracker.extraNeeds = [.exercise, .heat]
        #expect(tracker.targetLiters == 3)
        #expect(tracker.glassesPerDay == 6)
        #expect(widget.lastTarget == 3)
    }

    @Test func extraNeedsAreSaved() {
        let tracker = makeConfiguredTracker()
        tracker.extraNeeds = [.heat]
        #expect(makeTracker().extraNeeds == [.heat])
    }
}
