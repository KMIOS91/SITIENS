//
//  ConfigureTimer.swift
//  SITIENS
//
//  Created by Modibo on 10/04/2025.
//

import SwiftUI
import UIKit
import AVFAudio
import Combine

/// Réglages du minuteur : durée et son de fin.
struct TimerSettings: View {
    /// Nom du fichier du son choisi (voir `AlarmSound`).
    @Binding var selectedItems : String
    /// Durée choisie, en secondes. Appliquée au minuteur seulement à la validation.
    @Binding var selectedHour : Int
    @Environment(\.dismiss) var dismiss
    @Bindable var hydrationActivationViewModel : HydrationActivationViewModel
    /// Appelé par « Valider » : c'est l'écran appelant qui applique la durée.
    var onValidate: () -> Void = {}
    @State var isPlaying : Bool = false

    // États conservés pour le travail en cours sur la barre de lecture (Rectangle ci-dessous).
    @State private var audio : AVAudioPlayer?
    @State private var cancellable: AnyCancellable?
    @State private var navigationTitle : String = "Configuration"
    @State private var slide : Double = 0.0
    @State private var activeSlide : Bool = false
    @Environment(\.scenePhase) var scenePhase
    @State private var updateSlide : Double = 0.0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var progress: Double = 0.0
    @State private var isUserScrubbing = false
    /// Hauteur totale du formulaire (barre de titre comprise), pour ajuster la feuille.
    @State private var contentHeight: CGFloat = 0
    @State private var detent: PresentationDetent = .large

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DurationPresets(selection: $selectedHour)

                    Stepper {
                        LabeledContent("Autre durée") {
                            Text(selectedHour == 0 ? "—" : TimerDurationOptions.shortLabel(selectedHour))
                                .monospacedDigit()
                        }
                    } onIncrement: {
                        selectedHour = TimerDurationOptions.increment(selectedHour)
                    } onDecrement: {
                        selectedHour = TimerDurationOptions.decrement(selectedHour)
                    }
                    .accessibilityValue(selectedHour == 0 ? "Aucune" : hydrationActivationViewModel.formatHour(selectedHour))
                } header: {
                    Text("Durée")
                } footer: {
                    if selectedHour > 0 {
                        Text("SITIENS vous rappellera de boire dans \(hydrationActivationViewModel.formatHour(selectedHour)).")
                    }
                }

                Section("Son de fin") {
                    Picker("Son", selection: $selectedItems) {
                        if selectedItems.isEmpty {
                            Text("Sélectionner").tag("")
                        }
                        ForEach(AlarmSound.allCases) { sound in
                            Text(sound.title).tag(sound.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    // Changer de son pendant l'écoute : on arrête l'ancien.
                    .onChange(of: selectedItems) {
                        hydrationActivationViewModel.stopPlaying()
                        isPlaying = false
                    }

                    SoundPreviewButton(
                        isPlaying: $isPlaying,
                        hydrationActivationViewModel: hydrationActivationViewModel,
                        selectedItems: selectedItems
                    )

                }
            }
            .scrollContentBackground(.hidden)
            .background { AppBackground() }
            // Le Form est une liste défilante : on lit la hauteur de son contenu,
            // plus ses marges (barre de titre en haut, zone de sécurité en bas).
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentSize.height + geometry.contentInsets.top + geometry.contentInsets.bottom
            } action: { _, height in
                contentHeight = height
                // Sans cette ligne, la feuille resterait sur `.large`, la taille de départ.
                detent = .height(height)
            }
            .navigationTitle("Minuteur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider", systemImage: "checkmark") {
                        hydrationActivationViewModel.stopPlaying()
                        onValidate()
                        dismiss()
                    }
                    .disabled(selectedHour == 0 || selectedItems.isEmpty)
                }
            }
        }
        // La feuille prend la hauteur du contenu au lieu de tout l'écran.
        // `.large` reste disponible (en tirant vers le haut), utile avec une grande taille de texte.
        .presentationDetents(contentHeight > 0 ? [.height(contentHeight), .large] : [.large], selection: $detent)
        .onDisappear{
            hydrationActivationViewModel.stopPlaying()
            isPlaying = false
        }.environment(hydrationActivationViewModel.self)
    }
}

/// Raccourcis de durée : la durée choisie est mise en avant.
private struct DurationPresets: View {
    @Binding var selection: Int

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 10)], spacing: 10) {
            ForEach(TimerDurationOptions.presets, id: \.self) { seconds in
                presetButton(seconds)
            }
        }
        .padding(.vertical, 6)
    }

    // Les deux styles de verre sont des types différents : d'où le `if` dans un @ViewBuilder.
    @ViewBuilder
    private func presetButton(_ seconds: Int) -> some View {
        let label = Text(TimerDurationOptions.shortLabel(seconds))
            .font(.subheadline.weight(.semibold))
            .monospacedDigit()
            .frame(maxWidth: .infinity)

        if selection == seconds {
            Button { selection = seconds } label: { label }
                .buttonStyle(.glassProminent)
                .tint(Theme.water)
                .accessibilityAddTraits(.isSelected)
        } else {
            Button { selection = seconds } label: { label }
                .buttonStyle(.glass)
        }
    }
}

/// Écoute du son choisi avant de valider.
struct SoundPreviewButton: View {
    @Binding var isPlaying : Bool
    @Bindable var hydrationActivationViewModel : HydrationActivationViewModel
    let selectedItems : String

    var body: some View {
        Button {
            isPlaying.toggle()
            if isPlaying {
                hydrationActivationViewModel.playSound(sound: selectedItems)
            } else {
                hydrationActivationViewModel.stopPlaying()
            }
        } label: {
            Label(isPlaying ? "Arrêter l'écoute" : "Écouter",
                  systemImage: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                .contentTransition(.symbolEffect(.replace))
        }
        .disabled(selectedItems.isEmpty)
    }
}

#Preview {
    @Previewable @State var selectedItems : String = "fresh-breeze"
    @Previewable @State var selectedHour : Int = 2700
    TimerSettings(
        selectedItems: $selectedItems,
        selectedHour: $selectedHour,
        hydrationActivationViewModel: HydrationActivationViewModel()
    )
}
