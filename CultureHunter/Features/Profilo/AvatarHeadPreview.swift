//
//  AvatarHeadPreview.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//  Ottimizzato il 08/07/25.
//

import SwiftUI
import SpriteKit

struct AvatarHeadPreview: View {
    let viewModel: AvatarViewModel
    var size: CGSize
    
    var body: some View {
        HeadOnlySpriteKitView(viewModel: viewModel, size: size)
            .frame(width: size.width, height: size.height)
    }
}

struct HeadOnlySpriteKitView: UIViewRepresentable {
    @ObservedObject var viewModel: AvatarViewModel
        let size: CGSize
        
        func makeUIView(context: Context) -> SKView {
            let skView = SKView()
            skView.ignoresSiblingOrder = false
            skView.allowsTransparency = true
            
            let yOffset = size.height * 0.25
            
            let scene = HeadOnlyScene(size: size, avatar: viewModel.avatar, yOffset: yOffset)
            skView.presentScene(scene)
            skView.backgroundColor = .clear
            context.coordinator.scene = scene
            
            return skView
        }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        guard let scene = context.coordinator.scene else { return }
        let currentAvatar = scene.avatar
        let newAvatar = viewModel.avatar
        
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

final class HeadOnlyScene: SKScene {

    var avatar: AvatarData
    private let yOffset: CGFloat
    
    private var headNode = SKSpriteNode()
    private var hairNode = SKSpriteNode()
    private var eyesNode = SKSpriteNode()
    
    private let fixedDirection: AvatarDirection = .down
    private let fixedAnimation: AvatarAnimation = .idle
    private let fixedFrame = 0
    
    private static var textureCache: [String: SKTexture] = [:]
    
    init(size: CGSize, avatar: AvatarData, yOffset: CGFloat = 15) {
        self.avatar = avatar
        self.yOffset = yOffset
        super.init(size: size)
        
        scaleMode = .aspectFit
        backgroundColor = .clear
        
        setupNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeAllChildren()
        removeAllActions()
    }
    
    private func setupNodes() {
        let characterSize = Int(max(size.width, size.height) * 2)
                
                configureNode(headNode, size: characterSize, zPosition: 1)
                configureNode(eyesNode, size: characterSize, zPosition: 2)
                configureNode(hairNode, size: characterSize, zPosition: 3)
                
                addChild(headNode)
                addChild(eyesNode)
                addChild(hairNode)
                
                updateTextures()
    }

    private func configureNode(_ node: SKSpriteNode, size: Int, zPosition: CGFloat) {
        node.size = CGSize(width: size, height: size)
                
                let center = CGPoint(x: self.size.width / 2, y: (self.size.height / 2) - yOffset)
                node.position = center
                node.zPosition = zPosition
    }
    
    private func assetName(base: String, gender: Gender, anim: String, dir: String, frame: Int) -> String {
        let genderPrefix = (gender == .male) ? "male_" : "female_"
        return "\(genderPrefix)\(base)_\(anim)_\(dir)_\(frame)"
    }
    
    private func getTexture(named name: String) -> SKTexture? {
        if let cachedTexture = HeadOnlyScene.textureCache[name] {
            return cachedTexture
        }
        
        let texture = SKTexture(imageNamed: name)
        HeadOnlyScene.textureCache[name] = texture
        return texture
    }
    
    private func updateTextures() {
        let dir = fixedDirection.rawValue
        let anim = fixedAnimation.rawValue
        let frame = fixedFrame
        let gender = avatar.gender
        
        let headTextureName = assetName(base: avatar.head, gender: gender, anim: anim, dir: dir, frame: frame)
        headNode.texture = getTexture(named: headTextureName)
        
        let eyesTextureName = assetName(base: avatar.eyes, gender: gender, anim: anim, dir: dir, frame: frame)
        eyesNode.texture = getTexture(named: eyesTextureName)
        
        if avatar.hair == "none" {
            hairNode.texture = nil
            hairNode.isHidden = true
        } else {
            let hairTextureName = assetName(base: avatar.hair, gender: gender, anim: anim, dir: dir, frame: frame)
            hairNode.texture = getTexture(named: hairTextureName)
            hairNode.isHidden = false
        }
    }
    
    func updateAvatar(_ newAvatar: AvatarData) {
        self.avatar = newAvatar
        updateTextures()
    }
    
    static func clearTextureCache() {
        textureCache.removeAll()
    }
}
