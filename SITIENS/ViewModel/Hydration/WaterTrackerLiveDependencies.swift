//
//  WaterTrackerLiveDependencies.swift
//  SITIENS
//
//  Implémentations réelles des dépendances de WaterTracker : historique Core Data et widget.
//

import Foundation
import WidgetKit

extension HistoryViewModel: GoalRecording {
    func recordGoal(profile: String, liters: Double) throws {
        name = profile
        quantity = "\(liters.formatted(.number.precision(.fractionLength(1)))) L"
        self.liters = liters
        try addHistory()
    }
}

/// Implémentation réelle : écrit dans l'App Group, puis demande au widget de se redessiner.
struct SharedWidgetPublisher: HydrationWidgetPublishing {
    func publish(liters: Double, targetLiters: Double) {
        let snapshot = HydrationSnapshot(liters: liters, targetLiters: targetLiters, updatedAt: .now)

        // Rien de neuf aujourd'hui : inutile de redessiner le widget.
        if let previous = SharedHydrationStore.load(),
           previous.liters == snapshot.liters,
           previous.targetLiters == snapshot.targetLiters,
           Calendar.current.isDateInToday(previous.updatedAt) {
            return
        }
        SharedHydrationStore.save(snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedHydrationStore.widgetKind)
    }
}
