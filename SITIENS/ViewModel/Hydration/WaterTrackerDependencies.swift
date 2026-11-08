//
//  WaterTrackerDependencies.swift
//  SITIENS
//
//  Ce que le suivi d'hydratation demande au reste de l'app, sous forme de protocoles
//  pour pouvoir les remplacer par des faux dans les tests.
//  Fichier partagé avec l'App Clip : aucune dépendance à Core Data ni à WidgetKit ici.
//

import Foundation

/// Enregistre un objectif quotidien atteint.
protocol GoalRecording {
    func recordGoal(profile: String, liters: Double) throws
}

/// Transmet la quantité du jour au widget.
protocol HydrationWidgetPublishing {
    func publish(liters: Double, targetLiters: Double)
}

/// Pour l'App Clip, ou tout contexte sans historique ni widget : ne fait rien.
struct NoGoalRecording: GoalRecording {
    func recordGoal(profile: String, liters: Double) throws {}
}

struct NoWidgetPublishing: HydrationWidgetPublishing {
    func publish(liters: Double, targetLiters: Double) {}
}
