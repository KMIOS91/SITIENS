//
//  WaterQuantityViewToAppClip.swift
//  AppClip
//
//  Created by Modibo on 02/08/2025.
//

import SwiftUI

struct WaterQuantityViewToAppClip: View {
    @AppStorage("updateHeight") var updateHeightRaw : Double = 0
    @AppStorage("progress")  var progressRaw: Double = 0
    @AppStorage("profilType") var profilTypeRaw: String = ""
    @AppStorage("glace") var glaceRaw: String = ""
    @State var updateHeight : CGFloat = 0
    @State var sheetPresented : Bool = false
    @State var rotationInfiny : Bool = false
    @State var profilType : String = ""
    @State var throwError : Bool = false
    @State var showMessage : Bool = false
    @State var progress : CGFloat = 0.0
    @State var startAnimation : CGFloat = 0
    @State private var isScaledUp = false
    @State var glace : String = ""
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack{
                    Text("Hydratation")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blue)
                        .padding()
                  
                    
                    Text("0,0L / 2,0L")
                        .foregroundStyle(.gray)
                        .font(.title2)
                    
                    GeometryReader { GeometryProxy in
                        let height = GeometryProxy.size.height
                        let width  = GeometryProxy.size.width
                        
                        ZStack{
                            
                            Image(systemName: "drop.fill")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.white)
                            
                            WaterWave(
                                progress: progress,
                                waveHeight:0.1,
                                offset: startAnimation
                            )
                            .fill(Color.blue)
                            .scaleEffect(x: isScaledUp ? 1.1:1,y:isScaledUp ? 1:1.1)
                            .overlay(
                                content: {
                                    CircleView(width: 15, height: 15, x: -20, y: 0)
                                    CircleView(width: 15, height: 15, x: 40, y: 30)
                                    CircleView(width: 25, height: 25, x: -30, y: 80)
                                    CircleView(width: 25, height: 25, x: 50, y: 70)
                                    CircleView(width: 10, height: 10, x: 40, y: 100)
                                    CircleView(width: 10, height: 10, x: -40, y: 50)
                                    
                                })
                            .mask {
                                Image(systemName: "drop.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(20)
                            }
                            .overlay(
                                alignment:.bottom
                            ){
                                Button {
                                   
                                } label: {
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size:45,weight:.bold))
                                        .foregroundStyle(.blue)
                                        .shadow(radius: 2)
                                        .padding(25)
                                        .background(
                                            Circle()
                                                .foregroundStyle(.white)
                                                .overlay(content: {
                                                    Circle()
                                                        .stroke(.blue,lineWidth:6)
                                                })
                                        )
                                }
                                .accessibilityLabel("Ajouter un verre d'eau")
                                .accessibilityHint("Ajoute la quantité d'eau choisie au suivi journalier")
                                .accessibilityAddTraits(.isButton)
                            }
                            
                            let percentFilled = (updateHeight / 300) * 100
                            
                            if progress > 1.0 {
                                Text("100 %")
                                    .foregroundStyle(updateHeight >= 150 ? .white: .blue)
                                    .font(.title)
                                    .offset(y:75)
                                //attention
                            }else {
                                Text("\(Int(percentFilled)) %")
                                    .foregroundStyle(Int(percentFilled) > 40 ? .white: .blue)
                                    .font(.title)
                                    .offset(y:75)
                            }
                        }
                        .frame(
                            width: width,
                            height: height,
                            alignment: .center
                        )
                        .onAppear{
                            updateHeight = CGFloat(updateHeightRaw)
                            progress = CGFloat(progressRaw)
                            profilType = profilTypeRaw
                            glace = glaceRaw
                            
                            withAnimation(
                                .linear(duration: 0.8)
                                .repeatForever(autoreverses: true)){
                                    startAnimation = 300
                                    isScaledUp = true
                                }
                        }
                    }
                    .frame(width: 350)

                    if updateHeight != 0 {
                        
                        Button {
                            withAnimation {
                                updateHeight = 0
                                progress = 0
                            }
                            
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(height: 50)
                                    .foregroundStyle(.orange)
                                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                                
                                
                                HStack {
                                    Text("Réinitialiser")
                                        .foregroundStyle(.white)
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding()
                        .accessibilityLabel("Réinitialiser le suivi")
                        .accessibilityHint("Remet le niveau d'eau et la progression à zéro")
                        .accessibilityAddTraits(.isButton)
                    }
                    
                    if throwError && profilType.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.orange)
                            Text("Veuillez bien sélectionner un profil")
                        }
                        .opacity(showMessage ? 1 : 0)
                        .animation(
                            .easeOut(duration: 1.0),value: showMessage
                        )
                    }
                    
                    if !glace.isEmpty {
                        VStack {
                            HStack{
                                ZStack {
                                    Circle()
                                        .frame(width: 70,height: 70)
                                        .foregroundStyle(.blue)
                                    
                                    Circle()
                                        .frame(width: 70,height: 60)
                                        .foregroundStyle(.white)
                                   
                                }
                            }
                            
                            
                            Text("X")
                            
                        }
                    }
                }
                .toolbar {
                    settingsToolbar
                    historyToolbar
                }
                .onChange(of: updateHeight) {
                    updateHeightRaw = Double(updateHeight)
                    progressRaw = Double(progress)
                    profilTypeRaw = profilType
                    glaceRaw = glace
                    
                    if updateHeight >= 300 {
                        
                  
                    }
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    
    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if progress == 0 {
                
                Button {
                    withAnimation {
                        sheetPresented = true
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .rotationEffect(.degrees(rotationInfiny ? 360 : 0))
                        .animation(
                            .linear(duration: 2.9)
                            .repeatForever(autoreverses: false),
                            value: rotationInfiny
                        )
                        .onAppear{
                            rotationInfiny = true
                        }
                }
                
                .sheet(isPresented: $sheetPresented) {
                    
                } content: {
                }
                
            }else{
                
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var historyToolbar :some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                
                
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
    }
}

struct WaterWave: Shape {
    var progress : CGFloat
    //Wague
    var waveHeight : CGFloat
    //Animation du début
    var offset : CGFloat
    // Aniamtion
    var animation : CGFloat {
        get{offset}
        set{offset = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            //Start
            path.move(to: .zero)
            
//            let waveAmplitude = waveHeight * rect.height
            let progressHeight : CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride(from: 0, to: rect.width, by: 2) {
                let x : CGFloat = value
                let sine : CGFloat = sin(Angle(degrees:  value + offset).radians)
                let y : CGFloat = progressHeight + (height * sine)
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}

struct CircleView: View {
    let width : CGFloat
    let height : CGFloat
    let x : CGFloat
    let y : CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(
                    width: width,
                    height: height
                )
                .offset(x: x, y: y)
        }
    }
}



#Preview {
    WaterQuantityViewToAppClip()
}
