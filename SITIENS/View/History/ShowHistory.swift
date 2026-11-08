//
//  ShowHistory.swift
//  SITIENS
//
//  Created by Modibo on 02/05/2025.
//

import SwiftUI
import CoreData

/// Liste des objectifs quotidiens atteints, avec recherche et suppression.
///
/// Cette vue est poussée par la `NavigationStack` de l'écran Hydratation :
/// elle n'en crée pas une deuxième, et garde donc le bouton retour standard d'iOS.
struct ShowHistory: View {
    @Bindable var historyViewModel: HistoryViewModel
    @State private var searchText = ""

    var body: some View {
        List {
            ForEach(entries, id: \.objectID) { entry in
                NavigationLink {
                    MoreInformation(entry: ManagementHistory(entry))
                } label: {
                    HistoryRow(entry: ManagementHistory(entry))
                }
            }
            // `entries` est filtrée : on transmet les entrées elles-mêmes, pas leurs positions.
            .onDelete { offsets in
                historyViewModel.deleteHistory(offsets.map { entries[$0] })
            }
        }
        .scrollContentBackground(.hidden)
        .background { AppBackground() }
        .overlay { emptyState }
        .navigationTitle("Historique")
        .searchable(text: $searchText, prompt: "Profil, quantité ou date")
        .toolbar {
            if !entries.isEmpty {
                EditButton()
            }
        }
        .onAppear { historyViewModel.reload() }
    }

    /// Entrées valides, filtrées par la recherche.
    private var entries: [History] {
        historyViewModel.history.filter { entry in
            guard let name = entry.name, !name.isEmpty,
                  let quantity = entry.quantity, !quantity.isEmpty else { return false }
            guard !searchText.isEmpty else { return true }
            // On cherche dans le texte affiché : « 3,0 L », « 8 nov. 2026 »…
            let shown = ManagementHistory(entry)
            return [shown.name, shown.quantityText, shown.dateText].contains {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    /// Message affiché quand la liste est vide : aucun objectif, ou aucun résultat de recherche.
    @ViewBuilder
    private var emptyState: some View {
        if entries.isEmpty {
            if searchText.isEmpty {
                ContentUnavailableView(
                    "Aucun objectif atteint",
                    systemImage: "drop",
                    description: Text("Chaque objectif quotidien atteint apparaîtra ici.")
                )
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        }
    }
}

/// Une ligne de l'historique : profil, date et quantité bue.
private struct HistoryRow: View {
    let entry: ManagementHistory

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "drop.fill")
                .font(.title3)
                .foregroundStyle(Theme.water)
                .frame(width: 40, height: 40)
                .background(Theme.water.opacity(0.12), in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(entry.dateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(entry.quantityText)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(Theme.water)
        }
        .padding(.vertical, 4)
        // VoiceOver lit la ligne d'un seul tenant : « Sportifs, 08/11/2026, 3,0L ».
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let viewModel = HistoryViewModel(viewContext: context)
    for index in 1...3 {
        let entry = History(context: context)
        entry.name = "Exemple \(index)"
        entry.date = "12/12/1998"
        entry.quantity = "3.0L"
        viewModel.history.append(entry)
    }
    return NavigationStack {
        ShowHistory(historyViewModel: viewModel)
    }
}
