//
//  ContentView.swift
//  AppClip
//
//  Created by Modibo on 01/08/2025.
//

import SwiftUI

struct AppClipHomeView: View {
    @Binding var hasSeenIntro: Bool
    @State private var showSheet: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image("thirstyPicture")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 260, height: 260)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 4))
                            .shadow(color: .gray.opacity(0.4), radius: 10, x: 0, y: 5)
                            .accessibilityLabel("Image de présentation")
                        
                        VStack(alignment: .center, spacing: 16){
                            
                        Text("Boire de l’eau : quelle est la limite à ne pas dépasser ?")
                            .font(.title3)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("Titre de la page")
                        
                        Button {
                            withAnimation {
                                showSheet.toggle()
                            }
                        } label: {
                                Text("""
                                Il est fortement déconseillé de boire plus de 5 litres d’eau par jour... 
                                """)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal)
                        .accessibilityLabel("Navigation vers le détail de la question")
                        .accessibilityValue("Navigation vers le détail est : \(showSheet == true ? "active" : "incactive")")
                        
                        Button(action: {
                            withAnimation {hasSeenIntro = true }
                        }) {
                            Text("Ignorer")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Theme.water)
                        .controlSize(.large)
                        .padding(.horizontal)
                        .accessibilityLabel("Ignorer l'introduction")
                        .accessibilityValue(hasSeenIntro == true
                            ? "Introduction ignoré":""
                        )
                    }
                        Spacer()
                    }
            }
            .sheet(isPresented: $showSheet) {
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.top, 8)
                
                InfoDetailSheet(
                    sections: [
                        ("Insomnies et réveils nocturnes", moreText),
                        ("La potomanie : un trouble psychiatrique", potomanie),
                        ("Le coma hydrique : boire trop d’eau, trop vite", hydrique)
                    ],
                    dismissAction: { showSheet = false }
                )
            }
        }
    }
    
    // MARK: - Contenu à afficher dans la feuille
    private var accebilityLbale: String {
        return "n'avez pas encore ignor l'introduction"
    }
    private var moreText: String {
        """
        Si vous buvez trop d’eau avant de dormir, vous risquez de vous réveiller fréquemment. En effet, cela empêche la sécrétion de l’hormone antidiurétique nécessaire à un sommeil profond.
        """
    }
    
    private var potomanie: String {
        """
        La potomanie est un trouble psychiatrique caractérisé par une consommation excessive d’eau. Elle peut mener à de graves complications, dont un œdème cérébral ou un coma.
        """
    }
    
    private var hydrique: String {
        """
        Boire plus de 5 litres d’eau par jour peut entraîner un déséquilibre en sodium, provoquant une intoxication à l’eau, maux de tête, voire un coma potentiellement mortel.
        """
    }
}

// MARK: - Vue de feuille d'information
struct InfoDetailSheet: View {
    let sections: [(String, String)]
    let dismissAction: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Image("thirstyPicture")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(sections, id: \.0) { title, text in
                            InfoSection(title: title, text: text)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Les risques d’une surhydratation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: dismissAction) {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - Composant réutilisable pour les sections
struct InfoSection: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    @Previewable @State var hasSeenIntro: Bool = false
    AppClipHomeView(hasSeenIntro: $hasSeenIntro)
}
