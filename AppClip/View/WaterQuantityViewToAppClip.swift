//
//  WaterQuantityViewToAppClip.swift
//  AppClip
//
//  Created by Modibo on 02/08/2025.
//

import SwiftUI

/// Onglet Hydratation de l'App Clip : le même tableau de bord que l'app,
/// sans historique ni widget (une App Clip n'en a pas).
struct WaterQuantityViewToAppClip: View {
    @State private var tracker = WaterTracker(goals: NoGoalRecording(), widget: NoWidgetPublishing())

    var body: some View {
        NavigationStack {
            HydrationDashboard(tracker: tracker)
        }
    }
}

#Preview {
    WaterQuantityViewToAppClip()
}
