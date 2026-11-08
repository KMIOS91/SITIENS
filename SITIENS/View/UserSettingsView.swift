//
//  UserSettingsView.swift
//  SITIENS
//
//  Created by Modibo on 17/04/2025.
//

import SwiftUI

/// Choix du profil et du récipient pour le suivi d'hydratation.
struct UserSettingsView: View {
    @Binding var profil: HydrationProfile?
    @Binding var glace: WaterContainer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 30) {
                    settingsCard("Sélectionner un profil") {
                        OptionPicker(title: "Profil", selection: $profil, options: HydrationProfile.allCases, label: \.name)
                    }

                    settingsCard("Sélectionner un récipient") {
                        OptionPicker(title: "Récipient", selection: $glace, options: WaterContainer.allCases, label: \.name)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Text("Valider")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Theme.water)
                    .controlSize(.large)
                    .disabled(profil == nil || glace == nil)
                    .padding()
                    .accessibilityHint("Valide vos préférences de profil et de récipient")
                }
                .padding()
                .navigationTitle("Paramètres")
            }
        }
    }

    /// Carte en verre (Liquid Glass) avec un titre.
    private func settingsCard(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

/// Picker générique pour une valeur optionnelle : fonctionne avec n'importe quelle liste d'options.
struct OptionPicker<Option: Hashable>: View {
    /// Nom affiché à gauche et lu par VoiceOver (« Profil », « Récipient »).
    let title: String
    @Binding var selection: Option?
    let options: [Option]
    let label: (Option) -> String

    var body: some View {
        // Avec le style `.navigationLink`, le Picker affiche lui-même la valeur choisie et le chevron.
        Picker(selection: $selection, label: Text(title)) {
            // Chaque valeur du Picker doit correspondre à un `tag` : on en prévoit un pour « rien ».
            if selection == nil {
                Text("Sélectionner").tag(Option?.none)
            }
            ForEach(options, id: \.self) { option in
                Text(label(option))
                    .lineLimit(1)
                    .tag(Option?.some(option))
            }
        }
        .pickerStyle(.navigationLink)
        .padding()
        .background(Color.primary.opacity(0.06), in: .rect(cornerRadius: 12))
        .accessibilityHint("Appuyez pour choisir")
    }
}

#Preview {
    @Previewable @State var profile: HydrationProfile? = nil
    @Previewable @State var container: WaterContainer? = .medium
    UserSettingsView(profil: $profile, glace: $container)
}
