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

    /// Valeurs de l'EFSA (eau totale) et part à boire (80 %, arrondie au décilitre).
    @Test(arguments: [
        (HydrationProfile.woman, 2.0, 1.6),
        (.man, 2.5, 2.0),
        (.pregnant, 2.3, 1.8),
        (.breastfeeding, 2.7, 2.2),
        (.girl9to13, 1.9, 1.5),
        (.boy9to13, 2.1, 1.7),
        (.child4to8, 1.6, 1.3),
    ])
    func dailyLiters(profile: HydrationProfile, totalWater: Double, toDrink: Double) {
        #expect(profile.totalWaterLiters == totalWater)
        #expect(profile.dailyLiters == toDrink)
    }

    @Test func storedValuesAreRecognized() {
        #expect(HydrationProfile(storedValue: "woman") == .woman)
        // Ancien nom avec un équivalent direct.
        #expect(HydrationProfile(storedValue: "Femmes enceintes") == .pregnant)
        // Anciens profils retirés : il faudra en choisir un nouveau.
        #expect(HydrationProfile(storedValue: "Sportifs") == nil)
        #expect(HydrationProfile(storedValue: "Nourrissons") == nil)
        #expect(WaterContainer(rawValue: "Moyen – 300 ml") == .medium)
    }

    @Test func eachExtraNeedAddsHalfALiter() {
        #expect(HydrationExtraNeed.allCases.allSatisfy { $0.extraLiters == 0.5 })
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
