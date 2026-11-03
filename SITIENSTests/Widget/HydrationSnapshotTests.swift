//
//  HydrationSnapshotTests.swift
//  SITIENSTests
//

import Testing
import Foundation
@testable import SITIENS

struct HydrationSnapshotTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris")!
        return calendar
    }

    private func date(_ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour))!
    }

    @Test func sameDayKeepsLiters() {
        let snapshot = HydrationSnapshot(liters: 1.2, targetLiters: 2, updatedAt: date(3, 9))
        #expect(snapshot.litersToday(now: date(3, 22), calendar: calendar) == 1.2)
        #expect(abs(snapshot.progressToday(now: date(3, 22), calendar: calendar) - 0.6) < 0.0001)
    }

    @Test func nextDayStartsFromZero() {
        let snapshot = HydrationSnapshot(liters: 1.2, targetLiters: 2, updatedAt: date(3, 23))
        #expect(snapshot.litersToday(now: date(4, 7), calendar: calendar) == 0)
        #expect(snapshot.progressToday(now: date(4, 7), calendar: calendar) == 0)
    }

    @Test func progressIsCappedAndSafeWithoutProfile() {
        let over = HydrationSnapshot(liters: 3, targetLiters: 2, updatedAt: date(3, 9))
        #expect(over.progressToday(now: date(3, 10), calendar: calendar) == 1)
        let noProfile = HydrationSnapshot(liters: 0, targetLiters: 0, updatedAt: date(3, 9))
        #expect(noProfile.progressToday(now: date(3, 10), calendar: calendar) == 0)
    }

    @Test func storeRoundTrip() {
        let snapshot = HydrationSnapshot(liters: 0.8, targetLiters: 2.5, updatedAt: date(3, 9))
        SharedHydrationStore.save(snapshot)
        #expect(SharedHydrationStore.load() == snapshot)
    }
}
