//
//  WelcomeTutorialView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

// Schermata di benvenuto
struct WelcomeTutorialView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("welcome_image") // Sostituisci con la tua immagine
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            Text("Benvenuto!")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Text("Scopri la città, esplora punti di interesse, guadagna badge e personalizza il tuo avatar divertendoti!")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Immagini edifici in basso (opzionale)
            HStack(spacing: 24) {
                Image("church_icon") // Sostituisci con le tue immagini
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                
                Image("castle_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
            }
            .padding()
            
            Button("Inizia") {
                onNext()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
        }
    }
}

// Pagine informative sull'app
struct AppInfoTutorialView: View {
    let step: AppInfoStep
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    var body: some View {
        VStack {
            // Titolo e contenuto specifico per ogni passo
            switch step {
            case .map:
                tutorialPage(
                    title: "La mappa 🗺️",
                    description: "Guarda la mappa per scoprire punti di interesse, raggiungili e scatta una foto per registrarli.",
                    imageName: "map_screenshot"
                )
            case .diary:
                tutorialPage(
                    title: "Il diario 📔",
                    description: "Tutti i punti di interesse registrati sono visibili nel tuo diario.",
                    imageName: "diary_screenshot"
                )
            case .poi:
                tutorialPage(
                    title: "Il punto di interesse 🏛️",
                    description: "Per ogni punto di interesse puoi leggere o ascoltare la sua storia.",
                    imageName: "poi_screenshot"
                )
            case .badges:
                tutorialPage(
                    title: "I badge 🏅",
                    description: "Registrando tutti i punti di interesse di una città, puoi ottenere il suo badge!",
                    imageName: "badges_screenshot"
                )
            case .shop:
                tutorialPage(
                    title: "Lo shop 🛍️",
                    description: "Con le monete ottenute, puoi personalizzare il tuo avatar.",
                    imageName: "shop_screenshot"
                )
            case .profile:
                tutorialPage(
                    title: "Il profilo 👤",
                    description: "Dalla schermata del profilo puoi cambiare il tuo nome e l'aspetto dell'avatar.",
                    imageName: "profile_screenshot"
                )
            }
            
            // Navigazione
            HStack {
                Button("Indietro") {
                    onPrevious()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
                
                Button("Avanti") {
                    onNext()
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: true))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
    }
    
    private func tutorialPage(title: String, description: String, imageName: String) -> some View {
        VStack {
            Image(imageName) // Sostituisci con le tue immagini
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .cornerRadius(20)
                .padding()
            
            Text(title)
                .font(.title.bold())
            
            Text(description)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Indicatori pagina
            HStack(spacing: 8) {
                ForEach(0..<AppInfoStep.allCases.count, id: \.self) { index in
                    Circle()
                        .fill(step.rawValue == index ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

// Schermata finale
struct FinalTutorialView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("final_image") // Sostituisci con la tua immagine
                .resizable()
                .scaledToFit()
                .frame(height: 120)
            
            Text("Ci siamo!")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Text("Adesso sei pronto a diventare un cacciatore di cultura!")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Immagini edifici in basso (opzionale)
            HStack(spacing: 24) {
                Image("church_icon") // Sostituisci con le tue immagini
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                
                Image("castle_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
            }
            .padding()
            
            Button("Inizia ad esplorare!") {
                onComplete()
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom, 40)
        }
    }
}