//
//  HydrationProfileTests.swift
//  SITIENSTests
//
//  Reprend les vérifications de l'ancien UserSettingsViewModelTests sur les nouveaux types.
//

import Testing
import Foundation
@testable import SITIENS

struct HydrationProfileTests {

    // MARK: - Profils

    @Test(arguments: [
        (HydrationProfile.infant, 0.7),
        (.pregnantWoman, 2.5),
        (.elderly, 2),
        (.athlete, 3),
        (.youth, 2.5),
        (.hotEnvironmentWorker, 3),
        (.chronicIllness, 2),
        (.overweight, 3),
        (.highAltitude, 3),
        (.medication, 2),
    ])
    func dailyLiters(profile: HydrationProfile, liters: Double) {
        #expect(profile.dailyLiters == liters)
    }

    /// Les chaînes enregistrées par les versions précédentes doivent toujours être reconnues.
    @Test func savedNamesAreStillRecognized() {
        #expect(HydrationProfile(rawValue: "Sportifs") == .athlete)
        #expect(HydrationProfile(rawValue: "Personnes âgées") == .elderly)
        #expect(WaterContainer(rawValue: "Moyen – 300 ml") == .medium)
        #expect(HydrationProfile(rawValue: "FakeName") == nil)
    }

    // MARK: - Récipients

    @Test(arguments: [
        (WaterContainer.small, 200, "SmallGlace"),
        (.medium, 300, "MediumGlace"),
        (.large, 500, "LargeGlace"),
    ])
    func container(container: WaterContainer, milliliters: Int, imageName: String) {
        #expect(container.milliliters == milliliters)
        #expect(container.imageName == imageName)
    }

    // MARK: - Remise à zéro quotidienne

    private var parisCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        return calendar
    }

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        parisCalendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    @Test func isNewDayWhenNothingTrackedYet() {
        #expect(!WaterTracker.isNewDay(lastTracking: 0, now: date(3, 12), calendar: parisCalendar))
    }

    @Test func isNewDayWhenSameDay() {
        let last = date(3, 0, 5).timeIntervalSince1970
        #expect(!WaterTracker.isNewDay(lastTracking: last, now: date(3, 23, 59), calendar: parisCalendar))
    }

    @Test func isNewDayAfterMidnight() {
        let last = date(3, 23, 50).timeIntervalSince1970
        #expect(WaterTracker.isNewDay(lastTracking: last, now: date(4, 0, 10), calendar: parisCalendar))
    }
}
