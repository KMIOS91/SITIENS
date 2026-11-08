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
                AppBackground()
                
                VStack(spacing: 30) {
                    VStack (alignment: .leading, spacing: 12){
                        Text("Sélectionner un profil")
                            .font(.headline)
                        
                        CustomPicker(title: "Profil", name: $profil, type: $profileType)
                    }
                    .padding()
                    // Carte en verre iOS 26 (Liquid Glass)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                    
                    VStack (alignment: .leading, spacing: 12){
                        Text("Sélectionner un récipient")
                            .font(.headline)
                        CustomPicker(title: "Récipient", name: $glace, type: $sizeOfGlace)
                    }
                    .padding()
                    // Carte en verre iOS 26 (Liquid Glass)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            if !profil.isEmpty && !glace.isEmpty{
                                dismiss()
                            }
                        }
                        
                    } label: {
                        Text("Valider")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.water)
                    .controlSize(.large)
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
    /// Nom lu par VoiceOver (« Profil », « Récipient »).
    let title: String
    @Binding var name : String
    @Binding var type : [String]
    
    var body: some View {
        // Avec le style `.navigationLink`, le Picker affiche lui-même la valeur choisie et le chevron :
        // l'étiquette n'a besoin que du titre.
        Picker(selection: $name, label: Text(title)) {
            ForEach(type,id: \.self) { profile in
                Text(profile)
                    .lineLimit(1)
            }
        }
        .pickerStyle(.navigationLink)
        .padding()
        .background(Color.primary.opacity(0.06), in: .rect(cornerRadius: 12))
        .accessibilityLabel(title)
        .accessibilityValue(name.isEmpty ? "Non sélectionné" : name)
        .accessibilityHint("Appuyez pour choisir")
       
    }
}
