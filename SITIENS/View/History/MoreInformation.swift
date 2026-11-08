//
//  MoreInformation.swift
//  SITIENS
//
//  Created by Modibo on 30/08/2025.
//

import SwiftUI

struct MoreInformation: View {
    let managementHistory : [ManagementHistory]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            ForEach(managementHistory) { history in
                
                ScrollView {
                    VStack {
                        
                        Spacer()
                        
                        Text(history.name)
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        ZStack {
                            // Cercle de fond
                            Circle()
                                .fill(.blue.opacity(0.8))
                                .frame(height: 300)
                                .overlay( // ✅ contour arrondi noir
                                    Circle()
                                        .stroke(.black, lineWidth: 4)
                                        .blur(radius: 9)
                                )
                            
                            // Image au centre
                            Image("teste")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                                .shadow(color: .blue.opacity(0.8), radius: 15)
                        }
                        
                        VStack(alignment: .leading) {
                            
                            
                            HStack {
                                Image(systemName: "drop.fill")
                                    .resizable()
                                    .foregroundStyle(.blue)
                                    .frame(width: 30,height: 40)
                                
                                Spacer()
                                
                                Text(history.quantity)
                                    .foregroundStyle(.blue)
                                    .fontWeight(.bold)
                            }
                            
                            .padding()
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .resizable()
                                    .foregroundStyle(.blue)
                                    .frame(width: 40,height: 40)
                                
                                Spacer()
                                
                                Text(history.date)
                                    .foregroundStyle(.blue)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                withAnimation {
                                    dismiss()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Historique d'hydratation")
                                }
                                .foregroundStyle(.blue)
                            }
                        }
                    })
                    .navigationBarBackButtonHidden()
                    .padding()
                }
            }
            
            .padding()
            
        }
           

        
    }
}

#Preview {
    MoreInformation(
        managementHistory: [ManagementHistory(name: "Sports", quantity: "12.2L", date: "11/11/2029")]
    )
}
