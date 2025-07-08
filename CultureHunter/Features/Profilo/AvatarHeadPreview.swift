//
//  AvatarHeadPreview.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//  Ottimizzato il 08/07/25.
//

import SwiftUI
import SpriteKit

/// Componente che mostra un'anteprima della testa dell'avatar.
struct AvatarHeadPreview: View {
    let viewModel: AvatarViewModel
    
    // Consente di personalizzare le dimensioni dall'esterno
    var size: CGSize = CGSize(width: 60, height: 60)
    
    var body: some View {
        HeadOnlySpriteKitView(viewModel: viewModel, size: size)
            .frame(width: size.width, height: size.height)
            .cornerRadius(10)
            .background(Color.gray.opacity(0.1))
    }
}

/// Versione specializzata di SpriteKitView che mostra solo la testa dell'avatar
struct HeadOnlySpriteKitView: UIViewRepresentable {
    @ObservedObject var viewModel: AvatarViewModel
    
    // Configurazione
    let size: CGSize
    var yOffset: CGFloat = 15  // Offset verticale per centrare la testa
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = false
        skView.allowsTransparency = true
        
        // Creiamo la scena con le dimensioni specificate
        let scene = HeadOnlyScene(size: size, avatar: viewModel.avatar, yOffset: yOffset)
        skView.presentScene(scene)
        skView.backgroundColor = .clear
        context.coordinator.scene = scene
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Confrontiamo i valori rilevanti dell'avatar per determinare se aggiornare
        guard let scene = context.coordinator.scene else { return }
        let currentAvatar = scene.avatar
        let newAvatar = viewModel.avatar
        
        // Verifichiamo se ci sono cambiamenti rilevanti per la visualizzazione della testa
        if currentAvatar.gender != newAvatar.gender ||
           currentAvatar.head != newAvatar.head ||
           currentAvatar.hair != newAvatar.hair ||
           currentAvatar.eyes != newAvatar.eyes {
            scene.updateAvatar(newAvatar)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: HeadOnlyScene?
    }
}

/// Scena SpriteKit ottimizzata che mostra solo la testa dell'avatar
final class HeadOnlyScene: SKScene {
    // MARK: - Properties
    var avatar: AvatarData
    private let yOffset: CGFloat
    
    // Nodi per i layer dell'avatar
    private var headNode = SKSpriteNode()
    private var hairNode = SKSpriteNode()
    private var eyesNode = SKSpriteNode()
    
    // Parametri fissi per la visualizzazione
    private let fixedDirection: AvatarDirection = .down
    private let fixedAnimation: AvatarAnimation = .idle
    private let fixedFrame = 0
    
    // Cache per le texture
    private static var textureCache: [String: SKTexture] = [:]
    
    // MARK: - Lifecycle
    
    /// Inizializza una nuova scena per la preview della testa
    /// - Parameters:
    ///   - size: Dimensioni della scena
    ///   - avatar: Dati dell'avatar da visualizzare
    ///   - yOffset: Offset verticale per posizionare la testa
    init(size: CGSize, avatar: AvatarData, yOffset: CGFloat = 15) {
        self.avatar = avatar
        self.yOffset = yOffset
        super.init(size: size)
        
        // Ottimizzazioni di rendering
        scaleMode = .aspectFit
        backgroundColor = .clear
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Pulizia esplicita
        removeAllChildren()
        removeAllActions()
    }
    
    // MARK: - Setup
    
    private func setupNodes() {
        // Dimensioni proporzionali alla scena
        let characterSize = Int(max(size.width, size.height) * 2)
        
        configureNode(headNode, size: characterSize, zPosition: 1)
        configureNode(eyesNode, size: characterSize, zPosition: 2)
        configureNode(hairNode, size: characterSize, zPosition: 3)
        
        // Ordine di aggiunta (non influisce sull'ordine di visualizzazione quando zPosition è impostata)
        addChild(headNode)
        addChild(eyesNode)
        addChild(hairNode)
        
        updateTextures()
    }

    /// Configura un singolo nodo con dimensioni, posizione e zPosition
    private func configureNode(_ node: SKSpriteNode, size: Int, zPosition: CGFloat) {
        node.size = CGSize(width: size, height: size)
        
        // Centrato con offset
        let center = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - yOffset)
        node.position = center
        
        // Imposta esplicitamente la zPosition
        node.zPosition = zPosition
    }
    
    // MARK: - Texture Management
    
    /// Genera il nome dell'asset completo
    private func assetName(base: String, gender: Gender, anim: String, dir: String, frame: Int) -> String {
        let genderPrefix = (gender == .male) ? "male_" : "female_"
        return "\(genderPrefix)\(base)_\(anim)_\(dir)_\(frame)"
    }
    
    /// Ottiene una texture dalla cache o la crea se non esiste
    private func getTexture(named name: String) -> SKTexture? {
        // Usa la cache se disponibile
        if let cachedTexture = HeadOnlyScene.textureCache[name] {
            return cachedTexture
        }
        
        // Altrimenti crea e memorizza la nuova texture
        let texture = SKTexture(imageNamed: name)
        HeadOnlyScene.textureCache[name] = texture
        return texture
    }
    
    /// Aggiorna le texture di tutti i nodi
    private func updateTextures() {
        let dir = fixedDirection.rawValue
        let anim = fixedAnimation.rawValue
        let frame = fixedFrame
        let gender = avatar.gender
        
        // Aggiorna la texture della testa
        let headTextureName = assetName(base: avatar.head, gender: gender, anim: anim, dir: dir, frame: frame)
        headNode.texture = getTexture(named: headTextureName)
        
        // Aggiorna la texture degli occhi
        let eyesTextureName = assetName(base: avatar.eyes, gender: gender, anim: anim, dir: dir, frame: frame)
        eyesNode.texture = getTexture(named: eyesTextureName)
        
        // Gestione speciale dei capelli
        if avatar.hair == "none" {
            hairNode.texture = nil
            hairNode.isHidden = true
        } else {
            let hairTextureName = assetName(base: avatar.hair, gender: gender, anim: anim, dir: dir, frame: frame)
            hairNode.texture = getTexture(named: hairTextureName)
            hairNode.isHidden = false
        }
    }
    
    // MARK: - Public Interface
    
    /// Aggiorna l'avatar visualizzato
    func updateAvatar(_ newAvatar: AvatarData) {
        self.avatar = newAvatar
        updateTextures()
    }
    
    /// Pulisce la cache delle texture (da chiamare quando si liberano risorse)
    static func clearTextureCache() {
        textureCache.removeAll()
    }
}

// MARK: - Preview

#Preview {
    AvatarHeadPreview(viewModel: AvatarViewModel())
        .frame(width: 100, height: 100)
        .previewLayout(.sizeThatFits)
        .padding()
}
