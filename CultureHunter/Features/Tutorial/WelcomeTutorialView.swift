//
//  WelcomeTutorialView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI
import SDWebImageSwiftUI
//40,70016° N, 14,70753° E
// Schermata di benvenuto
struct WelcomeTutorialView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            // Puoi usare una GIF animata anche qui
            AnimatedImage(name: "welcome_page.gif", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250)
            
            Text("Benvenuto!")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Text("Scopri la città, esplora punti di interesse, ottieni badge e personalizza il tuo avatar divertendoti!")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Immagini edifici in basso (opzionale)
            HStack(spacing: 24) {
                Image("church_icon") // Puoi mantenere immagini statiche dove preferisci
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Image("tower_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
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
                    videoName: "map_tutorial"
                )
            case .diary:
                tutorialPage(
                    title: "Il diario 📔",
                    description: "Qui puoi vedere tutti i punti di interesse registrati e quelli ancora da scoprire, divisi per città.",
                    videoName: "diario_tutorial"
                )
            case .poi:
                tutorialPage(
                    title: "Il punto di interesse 🏛️",
                    description: "Per ogni punto di interesse puoi leggere o ascoltare la sua storia, oltre a vedere la sua foto.",
                    videoName: "poi_tutorial"
                )
            case .badges:
                tutorialPage(
                    title: "I badge 🏅",
                    description: "Registrando tutti i punti di interesse di una città, puoi ottenere il suo badge!",
                    videoName: "badge_tutorial"
                )
            case .shop:
                tutorialPage(
                    title: "Lo shop 🛍️",
                    description: "Con le monete ottenute scoprendo i punti e completando le missioni, puoi personalizzare il tuo avatar!",
                    videoName: "shop_tutorial"
                )
            case .profile:
                tutorialPage(
                    title: "Il profilo 👤",
                    description: "Dalla schermata del profilo puoi cambiare il tuo nome, l'aspetto e abbigliamento dell'avatar, e anche cambiare l'orario della missione giornaliera",
                    videoName: "profilo_tutorial"
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
    
    private func tutorialPage(title: String, description: String, videoName: String) -> some View {
        VStack {
            
            Text(title)
                .font(.title.bold())
                .padding(.top)
            
            // Video player con bordo per garantire visibilità
            RoundedVideoContainer(videoName: videoName, cornerRadius: 0)
                .frame(height: 450)
                .clipShape(RoundedRectangle(cornerRadius: 40))


            
            
            Text(description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
            
            // GIF di celebrazione/completamento
            AnimatedImage(name: "road.gif", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250)
            
            Text("Ci siamo!")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Text("Adesso sei pronto a diventare un cacciatore di cultura!")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            // Immagini edifici in basso
            HStack(spacing: 24) {
                Image("church_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Image("tower_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
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
