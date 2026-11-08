//
//  WaterQuantityView.swift
//  SITIENS
//
//  Created by Modibo on 16/04/2025.
//

import SwiftUI

/// Onglet Hydratation de l'app : le tableau de bord, plus l'accès à l'historique.
struct WaterQuantityView: View {
    let tracker: WaterTracker
    /// Utilisé seulement pour ouvrir l'historique.
    let historyViewModel: HistoryViewModel

    var body: some View {
        NavigationStack {
            HydrationDashboard(tracker: tracker)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink {
                            ShowHistory(historyViewModel: HistoryViewModel(viewContext: historyViewModel.viewContext))
                        } label: {
                            Label("Historique", systemImage: "clock.arrow.circlepath")
                        }
                    }
                }
        }
    }
}

#Preview {
    let history = HistoryViewModel()
    WaterQuantityView(tracker: WaterTracker(goals: history, widget: NoWidgetPublishing()), historyViewModel: history)
}
