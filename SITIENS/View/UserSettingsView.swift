//
//  UserSettingsView.swift
//  SITIENS
//
//  Created by Modibo on 17/04/2025.
//

import SwiftUI

struct UserSettingsView: View {
    @State var profileType : [String] = ["Nourrissons","Femmes enceintes", "Personnes âgées","Sportifs","Enfants et adolescents","Travailleurs en environnement chaud","Personnes souffrant de maladies chroniques","Personnes en surpoids ou obèses","Voyageurs ou personnes en altitude","Personnes sous traitement médicamenteux"]
    @State var sizeOfGlace : [String] = ["Petit – 200 ml","Moyen – 300 ml",  "Grand – 500 ml"]
    @State var selectedProfileType : String = "nourrissons"
    @Binding var profil : String
    @Binding var glace : String
    @Environment(\.dismiss) var dismiss
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack (alignment: .leading, spacing: 12){
                        Text("Sélectionner un profil")
                            .font(.headline)
                        
                        CustomPicker(name: $profil, type: $profileType)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    
                    VStack (alignment: .leading, spacing: 12){
                        Text("Sélectionner un récipient")
                            .font(.headline)
                        CustomPicker(name: $glace, type: $sizeOfGlace)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            if !profil.isEmpty && !glace.isEmpty{
                                dismiss()
                            }
                        }
                        
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(height: 50)
                            Text("Valider")
                                .foregroundStyle(.white)
                        }
                    }
                    .disabled(profil.isEmpty || glace.isEmpty)
                    .padding()
                    .accessibilityLabel("Bouton Valider")
                    .accessibilityHint("Valide vos préférences de profil et de récipient")
                    .accessibilityAddTraits(.isButton)
                }
                .padding()
                .navigationTitle("Paramètres")
            }
        }
    }
}

#Preview {
    @Previewable @State var profilType : String = ""
    @Previewable @State var glace : String = ""
    UserSettingsView(profil: $profilType, glace: $glace)
}

struct CustomPicker: View {
    @Binding var name : String
    @Binding var type : [String]
    
    var body: some View {
        Picker(
            selection: $name,
            label:
                HStack{
                    Text(name.isEmpty ? "Sélectionner":name)
                        .foregroundStyle(name.isEmpty ? .gray:.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
        ) {
            ForEach(type,id: \.self) { profile in
                Text(profile)
                    .lineLimit(1)
            }
        }
        .pickerStyle(.navigationLink)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .accessibilityLabel(name)
        .accessibilityHint("Appuyez pour choisir une \(name.lowercased())")
       
    }
}
