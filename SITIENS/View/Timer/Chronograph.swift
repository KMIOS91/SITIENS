//
//  Chronograph.swift
//  SITIENS
//
//  Écran principal : le minuteur qui rappelle de boire de l'eau.
//

import SwiftUI
import Combine

struct Chronograph: View {
    @Bindable var hydrationActivationViewModel: HydrationActivationViewModel

    // Réglages choisis dans TimerSettings.
    @AppStorage("hour") private var duration: Int = 0
    @AppStorage("selectedItems") private var selectedSound: String = ""

    // État du décompte, sauvegardé pour retrouver le minuteur après une fermeture de l'app.
    // @AppStorage est lu dès le premier affichage : pas de passage par 0, donc pas d'animation parasite.
    @AppStorage("timeInterval") private var remaining: Int = 0
    @AppStorage("elapseBeforPause") private var elapsedBeforePause: Int = 0
    @AppStorage("startDate") private var startDate: Date?

    @State private var isRunning = false
    @State private var ticker: AnyCancellable?
    @State private var isSettingsPresented = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack {
            // En paysage, l'anneau et les boutons se placent côte à côte.
            let layout = verticalSizeClass == .compact
                ? AnyLayout(HStackLayout(spacing: 48))
                : AnyLayout(VStackLayout(spacing: 56))

            layout {
                ProgressRing(progress: progress) {
                    readout
                }
                .frame(maxWidth: 300, maxHeight: 300)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Temps restant")

                TimerControls(state: state, onReset: reset, onToggle: toggle)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { AppBackground() }
            .navigationTitle("Hydratation")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Réglages", systemImage: "slider.horizontal.3") {
                        isSettingsPresented = true
                    }
                    .disabled(state == .running)
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                TimerSettings(
                    selectedItems: $selectedSound,
                    selectedHour: $remaining,
                    hydrationActivationViewModel: hydrationActivationViewModel
                )
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
                .animation(.snappy, value: remaining)

            Text(state.caption)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// « 09:49 », ou « 1:09:49 » au-delà d'une heure.
    private var formattedRemaining: String {
        let pattern: Duration.TimeFormatStyle.Pattern = remaining >= 3600
            ? .hourMinuteSecond
            : .minuteSecond(padMinuteToLength: 2)
        return Duration.seconds(remaining).formatted(.time(pattern: pattern))
    }

    private var progress: Double {
        // Sans durée choisie, on évite la division par zéro.
        guard duration > 0 else { return 0 }
        return min(Double(remaining) / Double(duration), 1)
    }

    /// L'état se déduit des données : il n'est jamais stocké, donc jamais désynchronisé.
    private var state: TimerState {
        if duration == 0 || selectedSound.isEmpty { return .unset }
        if remaining == 0 { return .finished }
        if isRunning { return .running }
        return remaining == duration ? .ready : .paused
    }

    // MARK: - Actions

    private func toggle() {
        hydrationActivationViewModel.authorization()
        withAnimation {
            isRunning ? pause() : start()
        }
    }

    private func start() {
        let remainingAtStart = max(duration - elapsedBeforePause, 0)
        startDate = .now
        isRunning = true

        // Le rappel est confié à iOS dès le départ : il arrivera même si l'app passe en arrière-plan.
        hydrationActivationViewModel.scheduleNotification(in: remainingAtStart)
        HydrationLiveActivity.start(remaining: remainingAtStart, total: duration)

        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in tick() }
    }

    /// Appelée chaque seconde : recalcule le temps restant à partir de l'heure de départ.
    /// Se baser sur l'heure réelle (et non compter les secondes) évite toute dérive.
    private func tick() {
        guard let startDate else { return }
        let elapsed = elapsedBeforePause + Int(Date.now.timeIntervalSince(startDate))
        remaining = max(duration - elapsed, 0)

        if remaining == 0 {
            finish()
        }
    }

    private func pause() {
        stopTicker()
        isRunning = false
        hydrationActivationViewModel.cancelNotification()
        HydrationLiveActivity.pause(remaining: remaining)
    }

    private func finish() {
        stopTicker()
        isRunning = false
        elapsedBeforePause = 0
        HydrationLiveActivity.finish()
        hydrationActivationViewModel.playingSound(audioFile: selectedSound)
    }

    private func reset() {
        stopTicker()
        withAnimation {
            isRunning = false
            remaining = duration
        }
        elapsedBeforePause = 0
        hydrationActivationViewModel.stopPlaying()
        hydrationActivationViewModel.cancelNotification()
        HydrationLiveActivity.endAll()
    }

    /// Arrête le décompte et ajoute la période écoulée au temps déjà consommé.
    private func stopTicker() {
        ticker?.cancel()
        ticker = nil
        if let startDate {
            elapsedBeforePause += Int(Date.now.timeIntervalSince(startDate))
        }
        startDate = nil
    }
}

#Preview {
    Chronograph(hydrationActivationViewModel: HydrationActivationViewModel())
}
