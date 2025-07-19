//
//  TutorialView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    // Array delle pagine del tutorial informativo
    let pages = [
        TutorialPage(
            type: .welcome,
            title: "Benvenuto!",
            description: "Scopri la città, esplora punti di interesse, guadagna badge e personalizza il tuo avatar.",
            imageName: "welcome_image",
            bottomImages: ["church_icon", "tower_icon"]
        ),
        // Aggiungi le altre pagine del tutorial informativo
    ]
    
    var body: some View {
        VStack {
            // Implementazione semplice
            Text("Tutorial informativo")
                .font(.largeTitle)
                .padding()
            
            Button("Chiudi") {
                isPresented = false
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
