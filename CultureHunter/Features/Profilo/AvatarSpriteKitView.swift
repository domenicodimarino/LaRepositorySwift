//
//  AvatarSpriteKitView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//  Ottimizzato il 08/07/25.
//

import SwiftUI
import SpriteKit

/// Componente SwiftUI che visualizza un avatar animato utilizzando SpriteKit
struct AvatarSpriteKitView: UIViewRepresentable {
    // MARK: - Properties
    
    /// ViewModel che contiene i dati dell'avatar
    @ObservedObject var viewModel: AvatarViewModel
    
    /// Dimensione personalizzabile della vista (default 128x128)
    var size: CGSize = CGSize(width: 128, height: 128)
    
    var scale: CGFloat = 1.0
    
    /// Animazione iniziale dell'avatar
    var initialAnimation: AvatarAnimation = .idle
    
    /// Direzione iniziale dell'avatar
    var initialDirection: AvatarDirection = .down
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> SKView {
        // Configurazione della vista SpriteKit
        let skView = SKView()
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        
        // Configurazioni di performance opzionali
        skView.ignoresSiblingOrder = false
        skView.shouldCullNonVisibleNodes = true
        
        // Creazione e configurazione della scena
        let scene = AvatarScene(size: size, avatar: viewModel.avatar)
        scene.currentAnimation = initialAnimation
        scene.currentDirection = initialDirection
        
        // Presentazione della scena
        skView.presentScene(scene)
        
        // Salvataggio del riferimento alla scena nel coordinator
        context.coordinator.scene = scene
        
        // Applica scala alla scena se necessario
        scene.containerNode.setScale(scale)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? AvatarScene {
            // Debug dell'animazione
            print("🎭 AvatarSpriteKitView - Animation: \(initialAnimation), Direction: \(initialDirection)")
            
            // Ottimizzazione: aggiorniamo solo se l'avatar è effettivamente cambiato
            let currentAvatar = context.coordinator.scene?.avatar
            let newAvatar = viewModel.avatar
            
            // Confrontiamo gli attributi rilevanti
            if currentAvatar?.gender != newAvatar.gender ||
               currentAvatar?.head != newAvatar.head ||
               currentAvatar?.hair != newAvatar.hair ||
               currentAvatar?.skin != newAvatar.skin ||
               currentAvatar?.shirt != newAvatar.shirt ||
               currentAvatar?.pants != newAvatar.pants ||
               currentAvatar?.shoes != newAvatar.shoes ||
               currentAvatar?.eyes != newAvatar.eyes {
                print("👕 Aggiornamento avatar")
                context.coordinator.scene?.updateAvatar(newAvatar)
            }
            
            // AGGIUNTA: Forza l'animazione ogni volta
            if scene.currentAnimation != initialAnimation {
                print("🔄 Cambio animazione da \(scene.currentAnimation) a \(initialAnimation)")
                scene.changeAnimation(to: initialAnimation)
            }
            
            if scene.currentDirection != initialDirection {
                print("🧭 Cambio direzione da \(scene.currentDirection) a \(initialDirection)")
                scene.changeDirection(to: initialDirection)
            }
        } else {
            print("❌ Scene non trovata in updateUIView")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    // Aggiungi un metodo per creare una vista ridimensionata
        func withScale(_ scale: CGFloat) -> AvatarSpriteKitView {
            var view = self
            view.scale = scale
            return view
        }
    
    // MARK: - Coordinator
    
    /// Coordinator per gestire la comunicazione tra SwiftUI e SpriteKit
    class Coordinator {
        /// Riferimento alla scena SpriteKit
        var scene: AvatarScene?
        
        /// Pulizia delle risorse quando la view viene dismessa
        func cleanup() {
            scene?.stopAnimation()
            scene?.clearTextureCache()
            scene = nil
        }
        
        deinit {
            cleanup()
        }
    }
    
    // MARK: - Public Methods
    
    /// Crea una nuova istanza con dimensioni personalizzate
    /// - Parameter width: Larghezza della vista
    /// - Parameter height: Altezza della vista
    /// - Returns: Una nuova istanza configurata
    func withSize(width: CGFloat, height: CGFloat) -> AvatarSpriteKitView {
        var view = self
        view.size = CGSize(width: width, height: height)
        return view
    }
    
    /// Crea una nuova istanza con animazione e direzione personalizzate
    /// - Parameter animation: Animazione iniziale
    /// - Parameter direction: Direzione iniziale
    /// - Returns: Una nuova istanza configurata
    func withAnimation(_ animation: AvatarAnimation, direction: AvatarDirection = .down) -> AvatarSpriteKitView {
        var view = self
        view.initialAnimation = animation
        view.initialDirection = direction
        return view
    }
}

// MARK: - Preview

struct AvatarSpriteKitView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview standard
            AvatarSpriteKitView(viewModel: createViewModel())
                .frame(width: 128, height: 128)
                .previewDisplayName("Avatar Standard")
            
            // Preview con animazione di camminata
            AvatarSpriteKitView(viewModel: createViewModel())
                .withAnimation(.walk)
                .frame(width: 128, height: 128)
                .previewDisplayName("Avatar in movimento")
            
            // Preview femminile
            AvatarSpriteKitView(viewModel: createFemaleViewModel())
                .frame(width: 128, height: 128)
                .previewDisplayName("Avatar femminile")
        }
        .background(Color.gray.opacity(0.2))
        .previewLayout(.sizeThatFits)
    }
    
    // Helper per creare un viewmodel maschile per il preview
    static func createViewModel() -> AvatarViewModel {
        let avatar = AvatarData(
            name: "Visitatore",
            gender: .male,
            head: "100 head Human_male black",
            hair: "120 hair Plain black",
            skin: "010 body Body_color light",
            shirt: "035 clothes TShirt blue",
            pants: "020 legs Pants black",
            shoes: "015 shoes Basic_Shoes black",
            eyes: "105 eye_color Eye_Color blue"
        )
        return AvatarViewModel(avatar: avatar)
    }
    
    // Helper per creare un viewmodel femminile per il preview
    static func createFemaleViewModel() -> AvatarViewModel {
        let avatar = AvatarData(
            name: "Visitatrice",
            gender: .female,
            head: "100 head Human_male black",
            hair: "120 hair Long blonde",
            skin: "010 body Body_color light",
            shirt: "035 clothes TShirt pink",
            pants: "020 legs Pants blue",
            shoes: "015 shoes Basic_Shoes red",
            eyes: "105 eye_color Eye_Color green"
        )
        return AvatarViewModel(avatar: avatar)
    }
}
