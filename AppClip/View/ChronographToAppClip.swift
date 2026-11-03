//
//  ChronographToAppClip.swift
//  AppClip
//
//  Created by Modibo on 02/08/2025.
//

import SwiftUI

struct ChronographToAppClip: View {
    @State var timerIsReading = false
    
    @State var timeInterval: Int = 0
    @State var sheetPresented: Bool = false
    @State var rotationInfiny: Bool = false
    @State var selectedItems: String = ""
    @State var showMessage: Bool = false
    @State var elapseBeforPause: Int = 0
    
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
                                    .stroke(
                                        style: StrokeStyle(
                                            lineWidth: 15,
                                            lineCap: .round,
                                            lineJoin: .round,
                                        )
                                    )
                                    .foregroundStyle(.orange)
                            }
                        
                        Text("00:00:00")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                        
                        
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Progression de l'hydratation")
                    // MARK: - Bouton du cercle principal
                    HStack {
                        BouttonStopAndStart()
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
                            .accessibilityLabel("Bouton des réglages")
                            .accessibilityHint("Appuyez pour modifier les paramètres du minuteur")
                            
                            
                            .sheet(isPresented: $sheetPresented) {
                                
                            } content: {
                                
                            }
                        }
                    })
            }
            
        }
    }
   
    
}

#Preview {
    ChronographToAppClip()
}
