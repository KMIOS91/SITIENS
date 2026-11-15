//
//  SITIENSApp.swift
//  SITIENS
//
//  Created by Modibo on 07/04/2025.
//

import SwiftUI

@main
struct SITIENSApp: App {
    @State private var hydrationActivationViewModel: HydrationActivationViewModel
    @State private var hydrationTimer: HydrationTimer
    @State private var historyViewModel: HistoryViewModel
    @State private var waterTracker: WaterTracker

    init() {
        // Un seul service audio/notifications, partagé : le son lancé par le minuteur
        // peut ainsi être arrêté depuis n'importe quel écran.
        let hub = DataHistoryHub()
        _hydrationActivationViewModel = State(initialValue: HydrationActivationViewModel(hydrationProtocol: hub))
        _hydrationTimer = State(initialValue: HydrationTimer(hydration: hub))

        let history = HistoryViewModel()
        _historyViewModel = State(initialValue: history)
        _waterTracker = State(initialValue: WaterTracker(goals: history, widget: SharedWidgetPublisher()))
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Chronomètre", systemImage: "stopwatch") {
                    Chronograph(timer: hydrationTimer, hydrationActivationViewModel: hydrationActivationViewModel)
                        .environment(hydrationActivationViewModel)
                }

                Tab("Hydratation", systemImage: "drop.fill") {
                    WaterQuantityView(tracker: waterTracker, historyViewModel: historyViewModel)
                }
            }
        }
    }
}

