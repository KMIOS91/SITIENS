import SwiftUI
import Combine
import WidgetKit
import UIKit
import CoreData

// MARK: - HomeView : Chronomètre pour mesurer le temps restant avant une nouvelle hydradation

struct Chronograph: View {
    @State var timerIsReading = false
       @State var hydrationActivationViewModel = HydrationActivationViewModel()
       @State var timeInterval: Int = 0
       @AppStorage("timeInterval") var timeIntervalRaw: Int = 0
       @State var cancellable: Cancellable?
       @State var startDate: Date?
       @AppStorage("startDate") var startDateRaw: Date?
       @State var sheetPresented: Bool = false
       @State var rotationInfiny: Bool = false
       @State var selectedItems: String = ""
       @AppStorage("selectedItems") var selectedItemsRaw: String = ""
       @AppStorage("hour") var timerhour: Int = 0
       @State var showMessage: Bool = false
       @AppStorage("showMessage") var showMessageRaw: Bool = false
       @State var elapseBeforPause: Int = 0
       @AppStorage("elapseBeforPause") var elapseBeforPauseRaw: Int = 0
       @AppStorage("buttonLabel") var buttonLabel: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // MARK: - Fond avec dégradé bleu/cyan
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("Hydratation")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("Temps restant")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    ZStack {
                        
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                            .frame(height: 300)
                            .overlay {
                                Circle()
                                    .trim(from: 0,to: progressWater())
                                    .stroke(
                                        style: StrokeStyle(
                                            lineWidth: 15,
                                            lineCap: .round,
                                            lineJoin: .round,
                                        )
                                    )
                                    .foregroundStyle(completed() ? .blue : .orange)
                                    .animation(
                                        .easeInOut(duration: 0.5),
                                        value: progressWater()
                                    )
                            }
                        
                        Text(hydrationActivationViewModel.formatTimer(timeInterval))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                        
                    }
                    
                    // MARK: - Bouton du cercle principal
                    HStack {
                        Start_timer(
                            showMessage: $showMessage, hydrationActivationViewModel: hydrationActivationViewModel,
                            timeInterval: $timeInterval,
                            timerIsReading: $timerIsReading,
                            cancellable: $cancellable,
                            startDate: $startDate,
                            elapseBeforPause: $elapseBeforPause,
                            selectedItems: $selectedItems,
                            nameBtm: "Start"
                        )
                        
                        Start_timer(
                            showMessage: $showMessage, hydrationActivationViewModel: hydrationActivationViewModel,
                            timeInterval: $timeInterval,
                            timerIsReading: $timerIsReading,
                            cancellable: $cancellable,
                            startDate: $startDate,
                            elapseBeforPause: $elapseBeforPause,
                            selectedItems: $selectedItems,
                            nameBtm: "stop"
                        )
                    }
                    
                    if showMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.orange)
                            Text("Veuillez bien selectionner l'horraire")
                        }
                        .opacity(showMessage ? 1 : 0)
                        .animation(
                            .easeOut(duration: 1.0),value: showMessage
                        )
                        .padding()
                    }
                }
                .toolbar(
                    content: {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation {
                                    sheetPresented = true
                                }
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                                    .rotationEffect(.degrees(rotationInfiny ? 360 : 0))
                                    .animation(
                                        .linear(duration: 2.9)
                                        .repeatForever(autoreverses: false),
                                        value: rotationInfiny
                                    )
                                    .onAppear{
                                        rotationInfiny = true
                                    }
                            }
                            .disabled(timerIsReading && timeInterval != 0 && timeInterval != timerhour)
                            .sheet(isPresented: $sheetPresented) {
                                
                            } content: {
                                TimerSettings(
                                    selectedItems: $selectedItems,
                                    selectedHour: $timeInterval, hydrationActivationViewModel: hydrationActivationViewModel
                                )
                            }
                        }
                    })
            }
            .onAppear {
                timeInterval = timeIntervalRaw
                selectedItems = selectedItemsRaw
                showMessage = false
                startDate = startDateRaw
                elapseBeforPause = elapseBeforPauseRaw

                print("elapseBeforPause après le appear -> \(elapseBeforPause)")
            }
            .onChange(of: timeInterval) {
                timeIntervalRaw = timeInterval
                              selectedItemsRaw = selectedItems
                              showMessageRaw = showMessage
                              startDateRaw = startDate
                elapseBeforPauseRaw = elapseBeforPause
            }
        }
    }
    
    func completed() -> Bool {
        return progressWater() == 1
    }
    
    func progressWater() -> CGFloat {
        return  CGFloat(timeInterval) / CGFloat(timerhour)
    }
}

// MARK: - Preview
#Preview {
    Chronograph()
}

