//
//  UserSettingsView.swift
//  SITIENS
//
//  Created by Modibo on 17/04/2025.
//

import SwiftUI

/// Choix du profil, du récipient et des besoins supplémentaires pour le suivi d'hydratation.
struct UserSettingsView: View {
    @Binding var profil: HydrationProfile?
    @Binding var glace: WaterContainer?
    @Binding var extraNeeds: Set<HydrationExtraNeed>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Style `.inline` : les options sont listées directement, avec une coche.
                    Picker("Profil", selection: $profil) {
                        ForEach(HydrationProfile.allCases) { profile in
                            Text(profile.name).tag(Optional(profile))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Profil")
                } footer: {
                    if let profil {
                        Text("Objectif : \(liters(profil.dailyLiters)) à boire par jour.")
                    }
                }

                Section("Récipient") {
                    Picker("Récipient", selection: $glace) {
                        ForEach(WaterContainer.allCases) { container in
                            Label {
                                Text(container.name)
                            } icon: {
                                Image(container.imageName)
                                    .resizable()
                                    .scaledToFit()
                            }
                            .tag(Optional(container))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    ForEach(HydrationExtraNeed.allCases) { need in
                        Toggle(isOn: binding(for: need)) {
                            Text(need.name)
                            Text(need.detail)
                        }
                    }
                } header: {
                    Text("Aujourd'hui")
                } footer: {
                    extraNeedsAdvice
                }

                Section {
                } footer: {
                    // Chaîne littérale : `Text` la lit comme une `LocalizedStringKey`,
                    // ce qui active le Markdown (le lien est cliquable).
                    Text("""
                    Repères de l'EFSA ([Autorité européenne de sécurité des aliments, 2010](https://doi.org/10.2903/j.efsa.2010.1459)) \
                    pour une personne en bonne santé, par température et activité physique modérées. \
                    Ils portent sur l'apport total en eau, boissons et aliments compris : l'objectif \
                    affiché correspond à la part à boire, environ 80 %. Avant 6 mois, un bébé ne boit \
                    que du lait. En cas de maladie (cœur, reins…) ou de traitement, demandez conseil à \
                    un professionnel de santé : certaines situations demandent au contraire de limiter l'eau.
                    """)
                }
            }
            .scrollContentBackground(.hidden)
            .background { AppBackground() }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider", systemImage: "checkmark") {
                        dismiss()
                    }
                    .disabled(profil == nil || glace == nil)
                }
            }
        }
    }

    /// Conseil et source de chaque besoin coché.
    /// `advice` et `sourceName` sont des variables `String` : `Text` les affiche telles quelles,
    /// sans Markdown. Le lien passe donc par une vue `Link`.
    @ViewBuilder
    private var extraNeedsAdvice: some View {
        let active = HydrationExtraNeed.allCases.filter(extraNeeds.contains)
        if active.isEmpty {
            Text("Ces situations ne changent pas l'objectif : elles affichent un conseil.")
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(active) { need in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(need.advice)
                        Link(need.sourceName, destination: need.sourceURL)
                            .font(.footnote)
                    }
                }
            }
        }
    }

    /// Un interrupteur par besoin : coché si le besoin fait partie de l'ensemble.
    private func binding(for need: HydrationExtraNeed) -> Binding<Bool> {
        Binding {
            extraNeeds.contains(need)
        } set: { isOn in
            if isOn {
                extraNeeds.insert(need)
            } else {
                extraNeeds.remove(need)
            }
        }
    }

    private func liters(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) L"
    }
}

#Preview {
    @Previewable @State var profile: HydrationProfile? = .woman
    @Previewable @State var container: WaterContainer? = .medium
    @Previewable @State var needs: Set<HydrationExtraNeed> = [.heat]
    UserSettingsView(profil: $profile, glace: $container, extraNeeds: $needs)
}
