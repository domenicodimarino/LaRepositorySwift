//
//  AvatarHeadPreview.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI
import SpriteKit

// Componente semplificato che mostra solo la testa dell'avatar
struct AvatarHeadPreview: View {
    let viewModel: AvatarViewModel
    
    var body: some View {
        HeadOnlySpriteKitView(viewModel: viewModel)
            .frame(width: 60, height: 60)
            .cornerRadius(10)
            .background(Color.gray.opacity(0.1))
    }
}

// Versione specializzata di SpriteKitView che mostra solo la testa
struct HeadOnlySpriteKitView: UIViewRepresentable {
    @ObservedObject var viewModel: AvatarViewModel
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = HeadOnlyScene(size: CGSize(width: 60, height: 60), avatar: viewModel.avatar)
        skView.presentScene(scene)
        skView.backgroundColor = .clear
        context.coordinator.scene = scene
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        context.coordinator.scene?.updateAvatar(viewModel.avatar)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: HeadOnlyScene?
    }
}

// Versione semplificata di AvatarScene che mostra solo la testa
class HeadOnlyScene: SKScene {
    var avatar: AvatarData
    
    // Solo i nodi che ci servono
    private var headNode = SKSpriteNode()
    private var hairNode = SKSpriteNode()
    private var eyesNode = SKSpriteNode()
    
    // Fissiamo l'animazione e la direzione
    private let fixedDirection: AvatarDirection = .down
    private let fixedAnimation: AvatarAnimation = .idle
    private let fixedFrame = 0
    
    init(size: CGSize, avatar: AvatarData) {
        self.avatar = avatar
        super.init(size: size)
        scaleMode = .aspectFit
        backgroundColor = .clear
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNodes() {
        // Impostazioni delle dimensioni
        let characterSize = 120
        let yOffset: CGFloat = 15  // Sposta la testa verso il basso per inquadrare meglio
        
        headNode.size = CGSize(width: characterSize, height: characterSize)
        hairNode.size = CGSize(width: characterSize, height: characterSize)
        eyesNode.size = CGSize(width: characterSize, height: characterSize)
        
        // Tutti i nodi sovrapposti, centrati nella scena con offset
        let center = CGPoint(x: size.width / 2, y: (size.height / 2) - yOffset)
        
        headNode.position = center
        hairNode.position = center
        eyesNode.position = center
        
        // L'ordine di zPosition determina quali layer stanno sopra/sotto
        headNode.zPosition = 1
        eyesNode.zPosition = 2
        hairNode.zPosition = 3
        
        addChild(headNode)
        addChild(eyesNode)
        addChild(hairNode)
        
        updateTextures()
    }
    
    func assetName(base: String, gender: Gender, anim: String, dir: String, frame: Int) -> String {
        let genderPrefix = (gender == .male) ? "male_" : "female_"
        return "\(genderPrefix)\(base)_\(anim)_\(dir)_\(frame)"
    }
    
    func updateTextures() {
        let dir = fixedDirection.rawValue
        let anim = fixedAnimation.rawValue
        let frame = fixedFrame
        let gender = avatar.gender
        
        headNode.texture = SKTexture(imageNamed: assetName(base: avatar.head, gender: gender, anim: anim, dir: dir, frame: frame))
        eyesNode.texture = SKTexture(imageNamed: assetName(base: avatar.eyes, gender: gender, anim: anim, dir: dir, frame: frame))
        
        // Gestire il caso speciale dei capelli "none"
        if avatar.hair == "none" {
            hairNode.texture = nil
        } else {
            hairNode.texture = SKTexture(imageNamed: assetName(base: avatar.hair, gender: gender, anim: anim, dir: dir, frame: frame))
        }
    }
    
    // Chiamato quando cambia il personaggio da SwiftUI/ViewModel
    func updateAvatar(_ newAvatar: AvatarData) {
        self.avatar = newAvatar
        updateTextures()
    }
}
