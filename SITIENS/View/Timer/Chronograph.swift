//
//  Chronograph.swift
//  SITIENS
//
//  Écran principal : le minuteur qui rappelle de boire de l'eau.
//

import SwiftUI

struct Chronograph: View {
    @Bindable var timer: HydrationTimer
    @Bindable var hydrationActivationViewModel: HydrationActivationViewModel

    /// Durée enregistrée par le bouton « Valider » des réglages.
    @AppStorage(HydrationTimer.Keys.duration) private var validatedDuration: Int = 0
    /// Durée sélectionnée dans les réglages, pas encore validée.
    @State private var pendingDuration = 0
    @State private var isSettingsPresented = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack {
            // En paysage, l'anneau et les boutons se placent côte à côte.
            let layout = verticalSizeClass == .compact
                ? AnyLayout(HStackLayout(spacing: 48))
                : AnyLayout(VStackLayout(spacing: 56))

            layout {
                ProgressRing(progress: timer.progress) {
                    readout
                }
                .frame(maxWidth: 300, maxHeight: 300)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Temps restant")

                TimerControls(
                    state: timer.state,
                    onReset: { withAnimation { timer.reset() } },
                    onToggle: { withAnimation { timer.toggle() } }
                )
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { AppBackground() }
            .navigationTitle("Hydratation")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Réglages", systemImage: "slider.horizontal.3") {
                        pendingDuration = timer.duration
                        isSettingsPresented = true
                    }
                    .disabled(timer.state == .running)
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                TimerSettings(
                    selectedItems: $timer.sound,
                    selectedHour: $pendingDuration,
                    hydrationActivationViewModel: hydrationActivationViewModel
                )
            }
            .onChange(of: validatedDuration) {
                timer.setDuration(validatedDuration)
            }
        }
    }

    // MARK: - Affichage

    /// Temps restant et légende, au centre de l'anneau.
    private var readout: some View {
        VStack(spacing: 4) {
            Text(formattedRemaining)
                .font(.system(size: 64, weight: .light, design: .rounded))
                .monospacedDigit()
                // Les chiffres qui changent glissent vers le bas, comme un compte à rebours.
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: timer.remaining)

            Text(timer.state.caption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// « 09:49 », ou « 1:09:49 » au-delà d'une heure.
    private var formattedRemaining: String {
        let pattern: Duration.TimeFormatStyle.Pattern = timer.remaining >= 3600
            ? .hourMinuteSecond
            : .minuteSecond(padMinuteToLength: 2)
        return Duration.seconds(timer.remaining).formatted(.time(pattern: pattern))
    }
}

#Preview {
    let hub = DataHistoryHub()
    Chronograph(
        timer: HydrationTimer(hydration: hub),
        hydrationActivationViewModel: HydrationActivationViewModel(hydrationProtocol: hub)
    )
}
