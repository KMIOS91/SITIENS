//
//  MoreInformation.swift
//  SITIENS
//
//  Created by Modibo on 30/08/2025.
//

import SwiftUI

/// Détail d'un objectif atteint.
struct MoreInformation: View {
    let entry: ManagementHistory

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.ringGradient)
                    .frame(width: 140, height: 140)
                    .glassEffect(.regular, in: .circle)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text(entry.quantityText)
                        .font(.system(size: 56, weight: .light, design: .rounded))
                        .monospacedDigit()
                    Text("Objectif atteint")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 0) {
                    DetailRow(title: "Profil", value: entry.name, systemImage: "person.fill")
                    Divider().padding(.leading, 52)
                    DetailRow(title: "Date", value: entry.dateText, systemImage: "calendar")
                }
                .glassEffect(.regular, in: .rect(cornerRadius: 20))
            }
            .padding(24)
        }
        .background { AppBackground() }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Ligne « icône · titre · valeur » de la carte de détail.
private struct DetailRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .foregroundStyle(Theme.water)
                .frame(width: 20)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        MoreInformation(entry: ManagementHistory(name: "Sportifs", quantity: "3,0 L", date: "08/11/2026"))
    }
}
