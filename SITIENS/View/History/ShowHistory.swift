//
//  ShowHistory.swift
//  SITIENS
//
//  Created by Modibo on 02/05/2025.
//

import SwiftUI
import CoreData

struct ShowHistory: View {
    @Bindable var historyViewModel : HistoryViewModel
    @Environment(\.dismiss) var dismiss
    var dateformatted = Date.now.formatted(date: .numeric, time: .shortened)
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
              
               showContainer()
                
            }
            .onAppear {
                Task {
                    try? historyViewModel.fetchHistory()
                }
            }
            .toolbar {
                // 🔙 Bouton retour
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Hydratation")
                        }
                        .foregroundStyle(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    @ViewBuilder
    func showContainer() -> some View {
        VStack(alignment: .center, spacing: 16) {
            
            Text("Historique d'hydratation")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
                .padding(.top, 10)
                .accessibilityLabel("Titre: Historique d'hydratation")
            
            List {
                Section {
                    ForEach(search, id: \.self) { historyManager in
                        if let name = historyManager.name,
                           let quantity = historyManager.quantity,
                           let date = historyManager.date,
                           !name.isEmpty,
                           !quantity.isEmpty {
                            
                            ZStack {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.blue.opacity(0.05))
                                        )
                                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        HStack {
                                            Text("\(name) :")
                                                .font(.headline)
                                                .foregroundStyle(.blue)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "drop.fill")
                                                    .foregroundColor(.white)
                                                
                                                Text("\(quantity)")
                                                    .foregroundColor(.white)
                                                    .font(.subheadline.bold())
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                }

                                NavigationLink {
                                    
                                    MoreInformation(managementHistory:[ManagementHistory(name: name,quantity: quantity,date: date)])
                                    
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            
                        }
                    }
                    .onDelete(perform:
                                historyViewModel.deleteHistory
                    )
                }
                .listStyle(.plain)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }
            .searchable(text: $searchText)
            .listStyle(.plain)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
    
    var search : [History]{
        
        if searchText.isEmpty {
            return historyViewModel.history
        }else{
            let water = historyViewModel.history
                .filter{
                    $0.name?.localizedCaseInsensitiveContains(searchText) == true ||
                    $0.quantity?.localizedCaseInsensitiveContains(searchText) == true ||
                    $0.date?.localizedCaseInsensitiveContains(searchText) == true
                }
            
            return  water
        }
    }
}

#Preview {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    // 2. Créer le ViewModel factice
    let viewModel: HistoryViewModel = {
        let vm = HistoryViewModel(viewContext: context)
        
        // Ajouter des objets factices
        for i in 1...3 {
            let h = History(context: context)
            h.name = "Exemple \(i)"
            h.date = "12/12/1998"
            h.quantity = "3.0L"
            vm.history.append(h)
        }
        return vm
    }()
    ShowHistory(
        historyViewModel: viewModel
    )
}

