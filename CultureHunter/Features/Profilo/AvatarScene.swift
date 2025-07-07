//
//  AvatarScene.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//

import SpriteKit

// Mappa il numero di frame per ciascuna animazione
let animationFrameCounts: [AvatarAnimation: Int] = [
    .walk: 9,
    .idle: 2
]

class AvatarScene: SKScene {
    var avatar: AvatarData

    private var headNode = SKSpriteNode()
    private var bodyNode = SKSpriteNode()
    private var hairNode = SKSpriteNode()
    private var eyesNode = SKSpriteNode()
    private var shirtNode = SKSpriteNode()
    private var pantsNode = SKSpriteNode()
    private var shoesNode = SKSpriteNode()

    var currentDirection: AvatarDirection = .down
    var currentAnimation: AvatarAnimation = .idle
    var currentFrame = 0
    private var timer: Timer?
    
    var characterSize: Int = 128

    init(size: CGSize, avatar: AvatarData) {
        self.avatar = avatar
        super.init(size: size)
        scaleMode = .aspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        
        headNode.size = CGSize(width: characterSize, height: characterSize)
        bodyNode.size = CGSize(width: characterSize, height: characterSize)
        hairNode.size = CGSize(width: characterSize, height: characterSize)
        eyesNode.size = CGSize(width: characterSize, height: characterSize)
        shirtNode.size = CGSize(width: characterSize, height: characterSize)
        pantsNode.size = CGSize(width: characterSize, height: characterSize)
        shoesNode.size = CGSize(width: characterSize, height: characterSize)
        
        setupNodes()
        startAnimation(for: .idle)
    }

    func setupNodes() {
        // Tutti i nodi sovrapposti, centrati nella scena
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        bodyNode.position = center
        shirtNode.position = center
        pantsNode.position = center
        shoesNode.position = center
        headNode.position = center
        hairNode.position = center
        eyesNode.position = center

        // L'ordine di zPosition determina quali layer stanno sopra/sotto
        bodyNode.zPosition = 0
        pantsNode.zPosition = 1
        shoesNode.zPosition = 2
        shirtNode.zPosition = 3
        headNode.zPosition = 4
        eyesNode.zPosition = 5
        hairNode.zPosition = 6

        addChild(bodyNode)
        addChild(pantsNode)
        addChild(shoesNode)
        addChild(shirtNode)
        addChild(headNode)
        addChild(eyesNode)
        addChild(hairNode)

        updateTextures()
    }
    

    func totalFrames(for animation: AvatarAnimation) -> Int {
        animationFrameCounts[animation] ?? 1
    }

    func assetName(base: String, gender: Gender, anim: String, dir: String, frame: Int) -> String {
        let genderPrefix = (gender == .male) ? "male_" : "female_"
        return "\(genderPrefix)\(base)_\(anim)_\(dir)_\(frame)"
    }

    func updateTextures() {
        let dir = currentDirection.rawValue
        let anim = currentAnimation.rawValue
        let frame = currentFrame
        let gender = avatar.gender
            
        // Ripristina i valori predefiniti per colore e blending
        headNode.colorBlendFactor = 0.0
        bodyNode.colorBlendFactor = 0.0
        hairNode.colorBlendFactor = 0.0
        eyesNode.colorBlendFactor = 0.0
        shirtNode.colorBlendFactor = 0.0
        pantsNode.colorBlendFactor = 0.0
        shoesNode.colorBlendFactor = 0.0

        bodyNode.texture = SKTexture(imageNamed: assetName(base: avatar.skin, gender: gender, anim: anim, dir: dir, frame: frame))
        pantsNode.texture = SKTexture(imageNamed: assetName(base: avatar.pants, gender: gender, anim: anim, dir: dir, frame: frame))
        shoesNode.texture = SKTexture(imageNamed: assetName(base: avatar.shoes, gender: gender, anim: anim, dir: dir, frame: frame))
        shirtNode.texture = SKTexture(imageNamed: assetName(base: avatar.shirt, gender: gender, anim: anim, dir: dir, frame: frame))
        headNode.texture = SKTexture(imageNamed: assetName(base: avatar.head, gender: gender, anim: anim, dir: dir, frame: frame))
        eyesNode.texture = SKTexture(imageNamed: assetName(base: avatar.eyes, gender: gender, anim: anim, dir: dir, frame: frame))
        hairNode.texture = avatar.hair == "none" ? nil : SKTexture(imageNamed: assetName(base: avatar.hair, gender: gender, anim: anim, dir: dir, frame: frame))
    }

    func startAnimation(for animation: AvatarAnimation) {
        timer?.invalidate()
        currentAnimation = animation
        currentFrame = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let total = self.totalFrames(for: self.currentAnimation)
            self.currentFrame = (self.currentFrame + 1) % total
            self.updateTextures()
        }
    }

    func changeAnimation(to animation: AvatarAnimation) {
        startAnimation(for: animation)
    }

    // Chiamato quando cambia il personaggio da SwiftUI/ViewModel
    func updateAvatar(_ newAvatar: AvatarData) {
        self.avatar = newAvatar
        currentFrame = 0
        updateTextures()
    }
    
    func changeDirection(to direction: AvatarDirection){
        currentDirection = direction
        currentFrame = 0
        updateTextures()
    }

    deinit {
        timer?.invalidate()
    }
}
