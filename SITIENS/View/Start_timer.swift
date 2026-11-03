//
//  Start_timer.swift
//  SITIENS
//
//  Created by Modibo on 22/05/2025.
//

import SwiftUI
import Combine

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
    var nameBtm: String
    @State private var animeFrame: CGFloat = 1.0
    
    var body: some View {
        
        VStack {
            if nameBtm == "Start" {
                if  buttonLabel == "Démarrer"   {
                    Button {
                        timeInterval = timerhour
                        elapseBeforPause = 0
                        startDate = nil
                        timerIsReading = false
                        hydrationActivationViewModel.stopPlaying()
                        hydrationActivationViewModel.cancelNotification()
                        HydrationLiveActivity.endAll()
                        
                        if timerhour == 0 && timeInterval == 0 {
                            DispatchQueue.main
                                .asyncAfter(deadline: .now() + 0.2, execute: {
                                    withAnimation {
                                        showMessage = true
                                    }
                                })
                        }
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.gray)
                                .frame(width: 13, height: 13)
                                .shadow(radius: 10)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 125, height: 125)
                                .shadow(radius: 10)
                            
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
                            DispatchQueue.main
                                .asyncAfter(deadline: .now() + 0.2, execute: {
                                    withAnimation {
                                        showMessage = true
                                    }
                                })
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(fill)
                                .frame(width: 13, height: 13)
                                .shadow(radius: 10)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 125, height: 125)
                                .shadow(radius: 10)
                            
                            if  buttonLabel == "Arrêter" {
                                Circle()
                                    .fill(.red)
                                    .scaleEffect(animeFrame)
                                    .frame(width:  120, height:  120)
                                    .shadow(radius: 10)
                                    .animation(
                                        .easeIn(
                                            duration: 2)
                                        .repeatForever(),
                                        
                                        value: animeFrame
                                    )
                                    .onAppear{
                                        withAnimation {
                                            animeFrame = 1.5
                                        }
                                    }
                                    .onChange(of: animeFrame, {
                                        withAnimation {
                                            animeFrame = 1.0
                                        }
                                    })
                            }
                            
                            Circle()
                                .fill(fill)
                                .frame(width: 120, height: 120)
                                .shadow(radius: 10)
                            
                            Text(buttonLabel)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .accessibilityLabel("Bouton \(buttonLabel)")
                    .accessibilityHint(buttonLabel == "Démarrer" ? "Lance le minuteur" : "Met en pause le minuteur")
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
    var fill : Color {
        switch buttonLabel{
        case "Démarrer" :
            return .green
        case "Arrêter" :
            return .red
        default:
            return .gray
        }
    }
    
    func stopTimer() {
        cancellable?.cancel()
        if let start = startDate {
            let elapsedTime = Int(Date().timeIntervalSince(start))
            elapseBeforPause += elapsedTime
            UserDefaults.standard.set(elapseBeforPause, forKey: "elapseBeforPause")
        }
    }
    
    var buttonLabel: String {
        
        if timerIsReading && timeInterval != 0 && timeInterval != timerhour {
            return "Arrêter"
        } else {
            return "Démarrer"
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
            selectedItems: $selectedItems, nameBtm: "Start"
        )
        
        Start_timer(
            showMessage: $showMessage, hydrationActivationViewModel: hydrationActivationViewModel,
            timeInterval: $timeInterval,
            timerIsReading: $timerIsReading,
            cancellable: $cancellable,
            startDate: $startDate,
            elapseBeforPause: $elapseBeforPause,
            selectedItems: $selectedItems, nameBtm: "stop"
        )
    }
}
