//
//  Start_timer.swift
//  SITIENS
//
//  Created by Modibo on 22/05/2025.
//

import SwiftUI
import Combine


/// Quel bouton afficher : « Réinitialiser » ou « Démarrer/Arrêter ».
enum TimerButtonRole {
    case reset
    case playPause
}

/// État du minuteur : il porte lui-même son texte et sa couleur.
enum TimerState {
    case idle
    case running

    var label: String {
        switch self {
        case .idle: return "Démarrer"
        case .running: return "Arrêter"
        }
    }

    var color: Color {
        switch self {
        case .idle: return .green
        case .running: return .red
        }
    }

    var accessibilityHint: String {
        switch self {
        case .idle: return "Lance le minuteur"
        case .running: return "Met en pause le minuteur"
        }
    }
}

struct Start_timer: View {
    @Binding var showMessage: Bool
    @Bindable var hydrationActivationViewModel: HydrationActivationViewModel
    @Binding var timeInterval: Int
    @Binding var timerIsReading: Bool
    @AppStorage("hour") var timerhour: Int = 0
    @Binding var cancellable: AnyCancellable?
    @Binding var startDate: Date?
    @Binding var elapseBeforPause: Int
    @Binding var selectedItems: String
    var role: TimerButtonRole
    
    var body: some View {
        
        VStack {
            if role == .reset {
                if timerState == .idle {
                    Button {
                        timeInterval = timerhour
                        elapseBeforPause = 0
                        startDate = nil
                        timerIsReading = false
                        hydrationActivationViewModel.stopPlaying()
                        hydrationActivationViewModel.cancelNotification()
                        HydrationLiveActivity.endAll()
                        
                        if timerhour == 0 && timeInterval == 0 {
                            
                            Task {
                                try? await Task.sleep(for: .milliseconds(200))
                                withAnimation {
                                    showMessage = true
                                }
                            }
                        }
                        
                    } label: {
                        ZStack {
                            
                            Circle()
                                .fill(.gray)
                                .frame(width: 120, height: 120)
                                .shadow(radius: 10)
                            
                            Text("Réinitialiser")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .accessibilityLabel("Bouton Réinitialiser")
                    .accessibilityHint("Remet à zéro le minuteur")
                    .accessibilityAddTraits(.isButton)
                }
                
            }else{
                
                if  timeInterval != 0 {
                    Button {
                        showMessage = false
                        toggleTimer()
                        
                        if timerhour == 0 && timeInterval == 0 {
                            Task {
                                try? await Task.sleep(for: .milliseconds(200))
                                withAnimation {
                                    showMessage = true
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(timerState.color)
                                .frame(width: 13, height: 13)
                                .shadow(radius: 10)
                            
                         
                            
                            if timerState == .running {
                                // Pulsation : alterne en boucle entre l'échelle 1.0 et 1.5.
                                // phaseAnimator repart de zéro à chaque apparition du cercle.
                                Circle()
                                    .fill(.red)
                                    .frame(width: 120, height: 120)
                                    .shadow(radius: 10)
                                    .phaseAnimator([1.0, 1.5]) { content, scale in
                                        content.scaleEffect(scale)
                                    } animation: { _ in
                                        .easeInOut(duration: 1)
                                    }
                            }
                            
                            Circle()
                                .fill(timerState.color)
                                .frame(width: 120, height: 120)
                                .shadow(radius: 10)
                            
                            Text(timerState.label)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .accessibilityLabel("Bouton \(timerState.label)")
                    .accessibilityHint(timerState.accessibilityHint)
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
    }
    
    func toggleTimer() {
        withAnimation {
            hydrationActivationViewModel.authorization()
            timerIsReading.toggle()
            
            if timerIsReading && timeInterval != 0 {
                startTimer()
            }else{
                stopTimer()
                hydrationActivationViewModel.cancelNotification()
                HydrationLiveActivity.pause(remaining: timeInterval)
            }
        }
    }
    
    // vérifier elapseBeforPause car le problème provient d'un delai absurde
    func stopTimer() {
        cancellable?.cancel()
        if let start = startDate {
            let elapsedTime = Int(Date().timeIntervalSince(start))
            elapseBeforPause += elapsedTime
            UserDefaults.standard.set(elapseBeforPause, forKey: "elapseBeforPause")
        }
    }
    
    var timerState: TimerState {
        if timerIsReading && timeInterval != 0 && timeInterval != timerhour {
            return .running
        } else {
            return .idle
        }
    }
    
    func startTimer() {
        let now = Date()
        startDate = now
        
        // Le rappel est confié à iOS dès le départ : il arrivera même si l'app passe en arrière-plan.
        let remaining = max(timerhour - elapseBeforPause, 0)
        hydrationActivationViewModel.scheduleNotification(in: remaining)
        HydrationLiveActivity.start(remaining: remaining, total: timerhour)
        
        cancellable?.cancel()
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard let savedStart = startDate else { return }
                let elapsedTime = elapseBeforPause + Int(Date().timeIntervalSince(savedStart))
                let remainingTime = max(timerhour - elapsedTime, 0)
                timeInterval = remainingTime
                
                if remainingTime == 0 {
                    stopTimer()
                    HydrationLiveActivity.finish()
                    hydrationActivationViewModel.playingSound(audioFile: selectedItems)
                    elapseBeforPause = 0
                    UserDefaults.standard.set(0, forKey: "elapseBeforPause")
                }
            }
    }
}

#Preview {
    @Previewable @State var showMessage : Bool = false
    @Previewable @State var timeInterval : Int = 0
    @Previewable @State var timerIsReading : Bool = false
    @Previewable @State var cancellable : AnyCancellable? = nil
    @Previewable @State var startDate : Date? = Date.now
    @Previewable @State var elapseBeforPause : Int = 12
    @Previewable @State var selectedItems : String = "fakeTest"
    @Previewable @State var activeTrim : Bool = true
    @Previewable @State var hydrationActivationViewModel  = HydrationActivationViewModel()
    
    HStack {
        Start_timer(
            showMessage: $showMessage, hydrationActivationViewModel: hydrationActivationViewModel,
            timeInterval: $timeInterval,
            timerIsReading: $timerIsReading,
            cancellable: $cancellable,
            startDate: $startDate,
            elapseBeforPause: $elapseBeforPause,
            selectedItems: $selectedItems, role: .reset
        )
        
        Start_timer(
            showMessage: $showMessage, hydrationActivationViewModel: hydrationActivationViewModel,
            timeInterval: $timeInterval,
            timerIsReading: $timerIsReading,
            cancellable: $cancellable,
            startDate: $startDate,
            elapseBeforPause: $elapseBeforPause,
            selectedItems: $selectedItems, role: .playPause
        )
    }
}
