//
//  HydrationSnapshot.swift
//  SITIENS
//
//  Partagé entre l'app (qui écrit) et le widget (qui lit), via l'App Group.
//  Ce fichier appartient aux deux cibles : SITIENS et LiveActivityExtension.
//

import Foundation

/// Ce que le widget doit afficher : la quantité bue aujourd'hui et l'objectif.
struct HydrationSnapshot: Codable, Equatable {
    /// Litres bus (déjà plafonnés à l'objectif).
    var liters: Double
    /// Objectif du jour en litres ; 0 si aucun profil n'est choisi.
    var targetLiters: Double
    /// Moment de la dernière mise à jour.
    var updatedAt: Date

    /// Litres bus aujourd'hui : 0 si la dernière mise à jour date d'un autre jour.
    func litersToday(now: Date = .now, calendar: Calendar = .current) -> Double {
        calendar.isDate(updatedAt, inSameDayAs: now) ? liters : 0
    }

    /// Progression entre 0 et 1.
    func progressToday(now: Date = .now, calendar: Calendar = .current) -> Double {
        guard targetLiters > 0 else { return 0 }
        return min(max(litersToday(now: now, calendar: calendar) / targetLiters, 0), 1)
    }
}

enum SharedHydrationStore {
    static let appGroup = "group.SITIENS.SITIENS"
    static let widgetKind = "HydrationTodayWidget"
    private static let key = "hydrationSnapshot"

    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    static func save(_ snapshot: HydrationSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults?.set(data, forKey: key)
    }

    static func load() -> HydrationSnapshot? {
        guard let data = defaults?.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(HydrationSnapshot.self, from: data)
    }
}
