//
//  AvatarScene.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//  Ottimizzato il 08/07/25
//

import SpriteKit

final class AvatarScene: SKScene {
    private static let animationFrameCounts: [AvatarAnimation: Int] = [
        .walk: 9,
        .idle: 2
    ]
    
    private static let animationFrameInterval: TimeInterval = 0.12
    
    var avatar: AvatarData
    
    var characterSize: Int = 128
    
    var currentDirection: AvatarDirection = .down {
        didSet { if oldValue != currentDirection { updateTextures() } }
    }
    
    var currentAnimation: AvatarAnimation = .idle {
        didSet { if oldValue != currentAnimation { resetAnimation() } }
    }
    
    private(set) var currentFrame = 0
    
    private let bodyNode = SKSpriteNode()
    private let headNode = SKSpriteNode()
    private let hairNode = SKSpriteNode()
    private let eyesNode = SKSpriteNode()
    private let shirtNode = SKSpriteNode()
    private let pantsNode = SKSpriteNode()
    private let shoesNode = SKSpriteNode()
    
    private var timer: Timer?
    private var textureCache: [String: SKTexture] = [:]
    
    let containerNode = SKNode()
    
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
            
            addChild(containerNode)
            
            containerNode.position = CGPoint(x: size.width/2, y: size.height/2)
            
            configureNodes()
            setupNodes()
            startAnimation(for: .idle)
        }
    
    deinit {
        stopAnimation()
        textureCache.removeAll()
        removeAllChildren()
        removeAllActions()
    }
    
    private func configureNodes() {
        let nodeSize = CGSize(width: characterSize, height: characterSize)
        
        for node in [bodyNode, headNode, hairNode, eyesNode, shirtNode, pantsNode, shoesNode] {
            node.size = nodeSize
        }
    }
    
    private func setupNodes() {
            let center = CGPoint.zero
            
            let nodeConfigs: [(node: SKSpriteNode, zPosition: CGFloat)] = [
                (bodyNode, 0),
                (pantsNode, 1),
                (shoesNode, 2),
                (shirtNode, 3),
                (headNode, 4),
                (eyesNode, 5),
                (hairNode, 6)
            ]
            
            for (node, zPosition) in nodeConfigs {
                node.position = center
                node.zPosition = zPosition
                containerNode.addChild(node)
            }
            
            updateTextures()
        }
    
    private func assetName(base: String, gender: Gender, anim: String, dir: String, frame: Int) -> String {
        let genderPrefix = (gender == .male) ? "male_" : "female_"
        return "\(genderPrefix)\(base)_\(anim)_\(dir)_\(frame)"
    }
    
    private func getTexture(named name: String) -> SKTexture {
        if let cachedTexture = textureCache[name] {
            return cachedTexture
        }
        
        let texture = SKTexture(imageNamed: name)
        textureCache[name] = texture
        return texture
    }
    
    func updateTextures() {
        let dir = currentDirection.rawValue
        let anim = currentAnimation.rawValue
        let frame = currentFrame
        let gender = avatar.gender
        
        [bodyNode, headNode, hairNode, eyesNode, shirtNode, pantsNode, shoesNode].forEach {
            $0.colorBlendFactor = 0.0
        }
        
        bodyNode.texture = getTexture(named: assetName(base: avatar.skin, gender: gender, anim: anim, dir: dir, frame: frame))
        headNode.texture = getTexture(named: assetName(base: avatar.head, gender: gender, anim: anim, dir: dir, frame: frame))
        eyesNode.texture = getTexture(named: assetName(base: avatar.eyes, gender: gender, anim: anim, dir: dir, frame: frame))
        shirtNode.texture = getTexture(named: assetName(base: avatar.shirt, gender: gender, anim: anim, dir: dir, frame: frame))
        pantsNode.texture = getTexture(named: assetName(base: avatar.pants, gender: gender, anim: anim, dir: dir, frame: frame))
        shoesNode.texture = getTexture(named: assetName(base: avatar.shoes, gender: gender, anim: anim, dir: dir, frame: frame))
        
        if avatar.hair == "none" {
            hairNode.texture = nil
            hairNode.isHidden = true
        } else {
            hairNode.isHidden = false
            hairNode.texture = getTexture(named: assetName(base: avatar.hair, gender: gender, anim: anim, dir: dir, frame: frame))
        }
    }
    
    private func totalFrames(for animation: AvatarAnimation) -> Int {
        return AvatarScene.animationFrameCounts[animation] ?? 1
    }
    
    private func resetAnimation() {
        currentFrame = 0
        updateTextures()
    }
    
    func startAnimation(for animation: AvatarAnimation) {
        stopAnimation()
        currentAnimation = animation
        currentFrame = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: AvatarScene.animationFrameInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let total = self.totalFrames(for: self.currentAnimation)
            self.currentFrame = (self.currentFrame + 1) % total
            self.updateTextures()
        }
    }
    
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    func changeAnimation(to animation: AvatarAnimation) {
        startAnimation(for: animation)
    }
    
    func changeDirection(to direction: AvatarDirection) {
        currentDirection = direction
    }
    
    func updateAvatar(_ newAvatar: AvatarData) {
        self.avatar = newAvatar
        resetAnimation()
    }
    
    func clearTextureCache() {
        textureCache.removeAll()
    }
}
