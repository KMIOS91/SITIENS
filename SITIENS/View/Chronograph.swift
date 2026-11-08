import SwiftUI
import Combine
import WidgetKit
import UIKit
import CoreData

// MARK: - HomeView : Chronomètre pour mesurer le temps restant avant une nouvelle hydradation
struct Chronograph: View {
    @State var timerIsReading = false
    @Bindable var hydrationActivationViewModel : HydrationActivationViewModel
    @State var timeInterval: Int = 0
    @AppStorage("timeInterval") var timeIntervalRaw: Int = 0
    @State var cancellable: AnyCancellable?
    @State var startDate: Date?
    @AppStorage("startDate") var startDateRaw: Date?
    @State var sheetPresented: Bool = false
    @State var selectedItems: String = ""
    @State var selectedHour : Int = 0
    @AppStorage("selectedItems") var selectedItemsRaw: String = ""
    @AppStorage("hour") var timerhour : Int = 0 {
        didSet{
            if timerhour < 60 {
                timerhour = 0
            }
        }
    }
    @State var showMessage: Bool = false
    @AppStorage("showMessage") var showMessageRaw: Bool = false
    @State var elapseBeforPause: Int = 0
    @AppStorage("elapseBeforPause") var elapseBeforPauseRaw: Int = 0
    @AppStorage("buttonLabel") var buttonLabel: String = ""
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
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
                
                if verticalSizeClass == .compact {
                    ScrollView([.vertical,.horizontal]) {
                        container()
                    }
                }else {
                    container()
                }
            }
            .toolbar(
                content: {
                    toolbarContent()
                }
            )
            .onAppear {
                //                UserDefaults.standard.removeObject(forKey: "hour")
                timeInterval = timeIntervalRaw
                selectedItems = selectedItemsRaw
                showMessage = false
                startDate = startDateRaw
                elapseBeforPause = elapseBeforPauseRaw
                
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
        // Sans durée choisie, 0/0 donnait NaN et l'anneau s'affichait plein.
        guard timerhour > 0 else { return 0 }
        return  CGFloat(timeInterval) / CGFloat(timerhour)
    }
    
    @ViewBuilder
    func container() -> some View {
        VStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("Hydratation")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Titre : Hydratation")
                
                Text("Temps restant")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Indication : Temps restant")
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
                                    lineWidth: verticalSizeClass == .compact ? 10 : 15,
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
                    .accessibilityLabel("Temps restant")
                    .accessibilityValue(hydrationActivationViewModel.formatTimer(timeInterval))
                
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Progression de l'hydratation")
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
                    role: .reset
                )
                .disabled(selectedItems.isEmpty)
                .accessibilityLabel("Bouton démarrer le minuteur")
                
                Start_timer(
                    showMessage: $showMessage, hydrationActivationViewModel: hydrationActivationViewModel,
                    timeInterval: $timeInterval,
                    timerIsReading: $timerIsReading,
                    cancellable: $cancellable,
                    startDate: $startDate,
                    elapseBeforPause: $elapseBeforPause,
                    selectedItems: $selectedItems,
                    role: .playPause
                )
                .disabled(selectedItems.isEmpty)
                .accessibilityLabel("Bouton arrêter le minuteur")
            }
            
            if showMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.orange)
                    Text("Veuillez bien sélectionner l'horaire")
                }
                .opacity(showMessage ? 1 : 0)
                .animation(
                    .easeOut(duration: 1.0),value: showMessage
                )
                .padding()
                .accessibilityLabel("Avertissement")
                .accessibilityHint("Veuillez bien sélectionner l’horaire")
            }
        }
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        var disableActive : Bool {
            timerIsReading && timeInterval != 0 && timeInterval != timerhour
        }
        var toogleEditMode : Bool  {
            colorScheme == .light
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation {
                    sheetPresented = true
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .frame(width: 32, height: 32, alignment: .center)
                    .contentShape(Rectangle())
                    .foregroundStyle(
                        (disableActive ? (toogleEditMode ? .gray :  .black)
                         :
                            (toogleEditMode ? Color("TextBackground") : .gray )) )
            }
            .accessibilityLabel("Bouton des réglages")
            .accessibilityHint("Appuyez pour modifier les paramètres du minuteur")
            .disabled(disableActive)
            .sheet(isPresented: $sheetPresented) {
                
            } content: {
                TimerSettings(
                    selectedItems: $selectedItems,
                    selectedHour: $timeInterval, hydrationActivationViewModel: hydrationActivationViewModel
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    Chronograph(hydrationActivationViewModel: HydrationActivationViewModel())
    
}
