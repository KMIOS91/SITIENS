//
//  ContentView.swift
//  SITIENS
//
//  Created by Modibo on 07/04/2025.
//
import SwiftUI

// MARK: - HomeView : Vue d'accueil sur l'hydratation
struct HomeView: View {
    @State private var showSheet: Bool = false
    @Binding var hasSeenIntro: Bool
    @Environment(\.dismiss) var dismiss
    @State private var openIndicator : Bool = false
    
    var body: some View {
        NavigationStack {
            SettingNavigation(
                showSheet: $showSheet,
                hasSeenIntro: $hasSeenIntro,
                openIndicator: $openIndicator
            )
        }
    }
}


struct SettingNavigation: View {
    @Binding var showSheet: Bool
    @Binding var hasSeenIntro: Bool
    @Binding var openIndicator : Bool
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var moreText: String {
        """
        \(ShowMoreInformation.first_paragraphe.rawValue)\n
        \(ShowMoreInformation.second_paragraphe.rawValue)\n
        \(ShowMoreInformation.third_paragraphe.rawValue)\n
        \(ShowMoreInformation.last_paragraphe.rawValue)
        """
    }
    
    var body : some View {
        ZStack {
            // Dégradé de fond
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if verticalSizeClass == .compact {
                ScrollView {
                    mainContent()
                }
            }else {
                mainContent()
            }
        }
        .toolbar(
            content: {
                toolBarContent()
            })
        .sheet(isPresented: $showSheet) {
            MoreInfoSheet(content: moreText) {
                showSheet = false
            }
        }
    }
    
    @ViewBuilder
    func mainContent() -> some View {
        VStack(spacing: 24) {
            Spacer()
            // Image circulaire
                
                Image("WaterWallaper")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 260, height: 260)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 4))
                    .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 5)
                    .accessibilityLabel("Image de présentation")
                
            
            VStack(alignment: .center, spacing: 16) {

                Text("L'eau, un allié essentiel pour votre bien-être.")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                
                
                Button(action: {
                    withAnimation { hasSeenIntro = true }
                }) {
                    Label("Ignorer", systemImage: "arrowshape.turn.up.left")
                        .foregroundStyle(Color("ForegroundColorForTheText"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background {
                    ZStack{
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color("TextBackground"))
                            
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
    }
    
    @ToolbarContentBuilder
    func toolBarContent() -> some ToolbarContent{
        ToolbarItem(placement: .confirmationAction) {
            
            Button {
                withAnimation {
                    showSheet.toggle()
                }
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(Color("TextBackground"))
                    .onAppear{
                        openIndicator = true
                    }
            }
            .accessibilityLabel("Activation de la navigation vers l'information complémentaire")
            .accessibilityValue("Activation de la navigation est :\(showSheet == true ? "active" : "inactive")")
        }
    }
}

// MARK: - Vue de la feuille modale
struct MoreInfoSheet: View {
    let content: String
    let dismissAction: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image("WaterWallaper")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text(content)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color("TextBackground"))
                            .padding()
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Pourquoi s'hydrater ?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView(hasSeenIntro: .constant(false))
}

extension SettingNavigation {
    
    enum ShowMoreInformation: String, CaseIterable {
        
        case first_paragraphe =
            """
            Notre organisme est composé de 60 à 65 % d’eau. Cette eau permet d’assurer de nombreuses fonctions vitales du corps.
            Il est donc crucial de boire régulièrement et en quantité suffisante.
            """
        
        case second_paragraphe = "On recommande de boire entre 1,3 L et 2 L par jour, selon le poids et l’activité. Une perte de plus de 15 % du poids en eau met en jeu le pronostic vital."
        
        case third_paragraphe =
        """
        Chaque jour, nous perdons environ 2,6 L d’eau (urines, transpiration, respiration...).
        En consommant fruits et légumes, nous récupérons 1 L, et 30 cl sont produits par le métabolisme. Il reste donc à boire environ 1,5 L — soit 8 verres d’eau.
        """
        
        case last_paragraphe = "N’attendez pas d’avoir soif : buvez régulièrement en petites quantités pour rester bien hydraté."
    }
}

