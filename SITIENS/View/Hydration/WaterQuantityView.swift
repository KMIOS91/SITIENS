//
//  WaterQuantityView.swift
//  SITIENS
//
//  Created by Modibo on 16/04/2025.
//

import SwiftUI
import WidgetKit

/// Suivi de l'eau bue dans la journée.
struct WaterQuantityView: View {
    // Sauvegarde du suivi : relue à l'affichage, réécrite à chaque verre ajouté.
    @AppStorage("updateHeight") private var updateHeightRaw: Double = 0
    @AppStorage("progress") private var progressRaw: Double = 0
    @AppStorage("profilType") private var profilTypeRaw: String = ""
    @AppStorage("glace") private var glaceRaw: String = ""
    /// Date (timestamp) du dernier verre ajouté, pour remettre le suivi à zéro chaque jour.
    @AppStorage("lastTrackingDate") private var lastTrackingDate: Double = 0

    @Bindable var historyViewModel: HistoryViewModel
    @State private var userSettingsViewModel = UserSettingsViewModel()

    /// Niveau de remplissage sur une échelle de 0 à 300 (le plein).
    @State private var updateHeight: CGFloat = 0
    /// Part de l'objectif atteinte (peut dépasser 1 avec le dernier verre).
    @State private var progress: CGFloat = 0
    @State private var profilType = ""
    @State private var glace = ""
    @State private var isSettingsPresented = false

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// Échelle interne du niveau : 300 correspond à l'objectif atteint.
    private let fullHeight: CGFloat = 300

    var body: some View {
        NavigationStack {
            // En paysage, la goutte et les boutons se placent côte à côte.
            let layout = verticalSizeClass == .compact
                ? AnyLayout(HStackLayout(spacing: 48))
                : AnyLayout(VStackLayout(spacing: 28))

            layout {
                VStack(spacing: 24) {
                    header
                    WaterDrop(level: min(progress, 1))
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
                UserSettingsView(profil: $profilType, glace: $glace)
            }
        }
        .onAppear(perform: restoreTracking)
        .onChange(of: profilType) {
            profilTypeRaw = profilType
            publishToWidget()
        }
        .onChange(of: scenePhase) {
            // L'app peut rester ouverte en arrière-plan pendant la nuit.
            if scenePhase == .active { resetIfNewDay() }
        }
        .onChange(of: updateHeight) {
            saveTracking()
        }
    }

    // MARK: - Calculs

    private var isConfigured: Bool {
        !profilType.isEmpty && !glace.isEmpty
    }

    /// Litres bus aujourd'hui.
    private var currentWater: CGFloat {
        updateHeight * userSettingsViewModel.updateType(name: profilType)
    }

    /// Litres à boire dans la journée selon le profil.
    private var targetWater: CGFloat {
        userSettingsViewModel.updateWater(type: profilType)
    }

    private var canAddGlass: Bool {
        isConfigured && targetWater > 0 && updateHeight < fullHeight && progress < 1
    }

    // MARK: - Affichage

    /// Litres bus et objectif, au-dessus de la goutte.
    private var header: some View {
        VStack(spacing: 4) {
            Text(liters(min(currentWater, targetWater)))
                .font(.system(size: 56, weight: .light, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(.snappy, value: currentWater)

            Text(isConfigured
                 ? "sur \(liters(targetWater)) aujourd'hui"
                 : "Choisissez un profil et un récipient")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack(spacing: 32) {
            RoundIconButton(systemImage: "arrow.counterclockwise") {
                withAnimation {
                    updateHeight = 0
                    progress = 0
                }
            }
            .disabled(updateHeight == 0)
            .accessibilityLabel("Réinitialiser le suivi")
            .accessibilityHint("Remet le niveau d'eau à zéro")

            RoundIconButton(systemImage: "plus", prominence: .primary, action: addGlass)
                .disabled(!canAddGlass)
                .accessibilityLabel("Ajouter un verre d'eau")
                .accessibilityHint("Ajoute la quantité d'eau choisie au suivi du jour")
        }
        // Vibration qui « monte » à chaque verre ajouté.
        .sensoryFeedback(.increase, trigger: updateHeight)
    }

    /// Rappel de l'objectif en verres : « 8 verres de 300 ml ».
    @ViewBuilder
    private var glassGoal: some View {
        if isConfigured {
            let glasses = Int(ceil(userSettingsViewModel.uptateQuanittyOfWater(
                quantityWater: profilType,
                chooseBottle: glace
            )))
            let milliliters = userSettingsViewModel.quantityWaterNumber(chooseBottle: glace)

            Label {
                Text("\(glasses) verres de \(milliliters) ml")
            } icon: {
                Image(userSettingsViewModel.chooseBottleOfWater(name: glace))
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
                    .onAppear { historyViewModel.reload() }
            } label: {
                Label("Historique", systemImage: "clock.arrow.circlepath")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Profil", systemImage: "person.crop.circle") {
                isSettingsPresented = true
            }
            // Le profil ne change pas en cours de journée : les verres déjà bus en dépendent.
            .disabled(progress != 0)
        }
    }

    /// « 1,2 L », avec la virgule de la langue de l'appareil.
    private func liters(_ value: CGFloat) -> String {
        "\(Double(value).formatted(.number.precision(.fractionLength(1)))) L"
    }

    // MARK: - Actions

    private func addGlass() {
        guard canAddGlass else { return }
        let progressPerGlass = userSettingsViewModel.showNumberOfGlass(chooseBottle: glace, name: profilType)
        let heightPerGlass = userSettingsViewModel.uptateQuanittyOfWater2(quantityWater: profilType, chooseBottle: glace)

        withAnimation {
            updateHeight += heightPerGlass
            progress += progressPerGlass
        }

        // Enregistré ici, au moment précis où l'objectif est atteint, et non dans `onChange` :
        // `onChange` se déclenche aussi quand le niveau sauvegardé est relu au lancement,
        // ce qui créait un doublon dans l'historique à chaque ouverture de l'app.
        if updateHeight >= fullHeight {
            recordGoalInHistory()
        }
    }

    private func restoreTracking() {
        updateHeight = CGFloat(updateHeightRaw)
        progress = CGFloat(progressRaw)
        profilType = profilTypeRaw
        glace = glaceRaw
        resetIfNewDay()
        publishToWidget()
    }

    private func saveTracking() {
        if updateHeight > 0 { lastTrackingDate = Date.now.timeIntervalSince1970 }
        updateHeightRaw = Double(updateHeight)
        progressRaw = Double(progress)
        profilTypeRaw = profilType
        glaceRaw = glace
        publishToWidget()
    }

    /// Objectif atteint : on l'enregistre dans l'historique.
    private func recordGoalInHistory() {
        historyViewModel.name = profilType
        historyViewModel.quantity = liters(currentWater)
        do {
            try historyViewModel.addHistory()
        } catch {
            print("Impossible d'enregistrer l'objectif dans l'historique : \(error)")
        }
    }

    /// Le suivi est journalier : un nouveau jour repart de zéro.
    private func resetIfNewDay() {
        guard userSettingsViewModel.isNewDay(lastTracking: lastTrackingDate) else { return }
        progress = 0
        progressRaw = 0
        updateHeight = 0
        lastTrackingDate = 0
    }

    /// Transmet la quantité du jour au widget (via l'App Group) et lui demande de se redessiner.
    private func publishToWidget() {
        let target = Double(targetWater)
        let snapshot = HydrationSnapshot(
            liters: min(Double(currentWater), target),
            targetLiters: target,
            updatedAt: .now
        )
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

#Preview {
    WaterQuantityView(historyViewModel: HistoryViewModel())
}
