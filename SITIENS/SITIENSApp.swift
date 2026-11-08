//
//  SITIENSApp.swift
//  SITIENS
//
//  Created by Modibo on 07/04/2025.
//

import SwiftUI

@main
struct SITIENSApp: App {
    // Mémorisé : l'introduction ne s'affiche qu'au premier lancement.
    @AppStorage("hasSeenIntro") private var showMainApp: Bool = false
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
        _waterTracker = State(initialValue: WaterTracker(goals: history))
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showMainApp {
                    TabView {
                        
                        Tab("Chronomètre", systemImage : "stopwatch") {
                            Chronograph(timer: hydrationTimer, hydrationActivationViewModel: hydrationActivationViewModel)
                                .environment(hydrationActivationViewModel)
                                .transition(.opacity)
                        }
                        
                        Tab("Hydratation", systemImage: "drop.fill") {
                            WaterQuantityView(tracker: waterTracker, historyViewModel: historyViewModel)
                                .transition(.opacity)
                        }
                    }
                    
                } else {
                    TabView {
                        
                        Tab("Hydratation", systemImage: "drop.fill") {
                            HomeView(hasSeenIntro: $showMainApp)
                                .transition(.opacity)
                        }
                        
                        Tab("Informations", systemImage: "info.circle") {
                            InformationView(hasSeenIntro: $showMainApp)
                                .transition(.opacity)
                        }
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .ignoresSafeArea()
                    .onAppear {
                        UIPageControl.appearance().pageIndicatorTintColor = .gray
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color("TextBackground"))
                    }
                }
            }
            .animation(.easeOut, value: showMainApp)
        }
    }
}

