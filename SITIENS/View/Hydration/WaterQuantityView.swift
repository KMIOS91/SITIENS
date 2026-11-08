//
//  WaterQuantityView.swift
//  SITIENS
//
//  Created by Modibo on 16/04/2025.
//

import SwiftUI

/// Suivi de l'eau bue dans la journée. Toute la logique est dans `WaterTracker`.
struct WaterQuantityView: View {
    @Bindable var tracker: WaterTracker
    /// Utilisé seulement pour ouvrir l'historique.
    let historyViewModel: HistoryViewModel

    @State private var isSettingsPresented = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack {
            // En paysage, la goutte et les boutons se placent côte à côte.
            let layout = verticalSizeClass == .compact
                ? AnyLayout(HStackLayout(spacing: 48))
                : AnyLayout(VStackLayout(spacing: 28))

            layout {
                VStack(spacing: 24) {
                    header
                    WaterDrop(level: tracker.progress)
                        .frame(maxHeight: verticalSizeClass == .compact ? 220 : 280)
                }

                VStack(spacing: 20) {
                    controls
                    glassGoal
                }
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { AppBackground() }
            .navigationTitle("Hydratation")
            .toolbar { toolbarContent }
            .sheet(isPresented: $isSettingsPresented) {
                UserSettingsView(profil: $tracker.profile, glace: $tracker.container)
            }
        }
        .onAppear { tracker.refresh() }
        .onChange(of: scenePhase) {
            // L'app peut rester ouverte en arrière-plan pendant la nuit.
            if scenePhase == .active { tracker.refresh() }
        }
    }

    // MARK: - Affichage

    /// Litres bus et objectif, au-dessus de la goutte.
    private var header: some View {
        VStack(spacing: 4) {
            Text(liters(tracker.drunkLiters))
                .font(.system(size: 56, weight: .light, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: tracker.drunkLiters)

            Text(tracker.isConfigured
                 ? "sur \(liters(tracker.targetLiters)) aujourd'hui"
                 : "Choisissez un profil et un récipient")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack(spacing: 32) {
            RoundIconButton(systemImage: "arrow.counterclockwise") {
                withAnimation { tracker.reset() }
            }
            .disabled(tracker.glassesToday == 0)
            .accessibilityLabel("Réinitialiser le suivi")
            .accessibilityHint("Remet le niveau d'eau à zéro")

            RoundIconButton(systemImage: "plus", prominence: .primary) {
                withAnimation { tracker.addGlass() }
            }
            .disabled(!tracker.canAddGlass)
            .accessibilityLabel("Ajouter un verre d'eau")
            .accessibilityHint("Ajoute la quantité d'eau choisie au suivi du jour")
        }
        // Vibration qui « monte » à chaque verre ajouté.
        .sensoryFeedback(.increase, trigger: tracker.glassesToday)
    }

    /// Rappel de l'objectif en verres : « 6 verres de 500 ml ».
    @ViewBuilder
    private var glassGoal: some View {
        if tracker.isConfigured {
            Label {
                Text("\(tracker.glassesPerDay) verres de \(tracker.containerMilliliters) ml")
            } icon: {
                Image(tracker.containerImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassEffect(.regular, in: .capsule)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                ShowHistory(historyViewModel: HistoryViewModel(viewContext: historyViewModel.viewContext))
            } label: {
                Label("Historique", systemImage: "clock.arrow.circlepath")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Profil", systemImage: "person.crop.circle") {
                isSettingsPresented = true
            }
            .disabled(!tracker.canChangeSettings)
        }
    }

    /// « 1,2 L », avec la virgule de la langue de l'appareil.
    private func liters(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) L"
    }
}

#Preview {
    let history = HistoryViewModel()
    WaterQuantityView(tracker: WaterTracker(goals: history), historyViewModel: history)
}
