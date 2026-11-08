//
//  TimerSettingsOptionsTests.swift
//  SITIENSTests
//

import Testing
import Foundation
@testable import SITIENS

struct TimerSettingsOptionsTests {

    // MARK: - Durées

    @Test(arguments: [
        (900, "15 min"),
        (3600, "1 h"),
        (5400, "1 h 30"),
        (3900, "1 h 05"),
        (10800, "3 h"),
    ])
    func shortLabel(seconds: Int, label: String) {
        #expect(TimerDurationOptions.shortLabel(seconds) == label)
    }

    @Test func stepperMovesOnAFiveMinuteGrid() {
        #expect(TimerDurationOptions.increment(0) == 300)
        #expect(TimerDurationOptions.increment(420) == 600)    // 7 min → 10 min
        #expect(TimerDurationOptions.decrement(420) == 300)    // 7 min → 5 min
        #expect(TimerDurationOptions.decrement(600) == 300)
    }

    @Test func stepperStaysWithinRange() {
        #expect(TimerDurationOptions.decrement(300) == 300)
        #expect(TimerDurationOptions.increment(14_400) == 14_400)
    }

    @Test func presetsAreSortedAndInRange() {
        let presets = TimerDurationOptions.presets
        #expect(presets == presets.sorted())
        #expect(presets.allSatisfy { TimerDurationOptions.range.contains($0) })
    }

    // MARK: - Sons

    /// Chaque son proposé doit correspondre à un fichier présent dans l'app.
    @Test(arguments: AlarmSound.allCases)
    func soundFileExists(sound: AlarmSound) {
        let bundle = Bundle(for: PersistenceController.self)
        #expect(bundle.url(forResource: sound.rawValue, withExtension: "mp3") != nil)
    }
}
