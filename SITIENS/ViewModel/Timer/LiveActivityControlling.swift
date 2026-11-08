//
//  LiveActivityControlling.swift
//  SITIENS
//
//  Ce que le minuteur demande à la Live Activity, sous forme de protocole
//  pour pouvoir le remplacer par un faux dans les tests.
//

@MainActor
protocol LiveActivityControlling {
    func start(remaining: Int, total: Int)
    func pause(remaining: Int)
    func finish()
    func endAll()
}

/// Implémentation réelle : délègue à `HydrationLiveActivity` (ActivityKit).
struct SystemLiveActivity: LiveActivityControlling {
    func start(remaining: Int, total: Int) { HydrationLiveActivity.start(remaining: remaining, total: total) }
    func pause(remaining: Int) { HydrationLiveActivity.pause(remaining: remaining) }
    func finish() { HydrationLiveActivity.finish() }
    func endAll() { HydrationLiveActivity.endAll() }
}
