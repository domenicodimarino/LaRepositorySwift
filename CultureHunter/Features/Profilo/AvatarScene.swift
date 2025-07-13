//
//  AvatarScene.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//  Ottimizzato il 08/07/25
//

import SpriteKit

/// Scene che visualizza un avatar animato personalizzabile
final class AvatarScene: SKScene {
    // MARK: - Constants
    
    /// Conteggio dei frame per ciascuna animazione
    private static let animationFrameCounts: [AvatarAnimation: Int] = [
        .walk: 9,
        .idle: 2
    ]
    
    /// Intervallo di tempo tra i frame dell'animazione
    private static let animationFrameInterval: TimeInterval = 0.12
    
    // MARK: - Properties
    
    /// Dati dell'avatar attualmente visualizzato
    var avatar: AvatarData
    
    /// Dimensione base del personaggio in pixel
    var characterSize: Int = 128
    
    /// Direzione attuale dell'avatar
    var currentDirection: AvatarDirection = .down {
        didSet { if oldValue != currentDirection { updateTextures() } }
    }
    
    /// Animazione corrente
    var currentAnimation: AvatarAnimation = .idle {
        didSet { if oldValue != currentAnimation { resetAnimation() } }
    }
    
    /// Frame attuale dell'animazione corrente
    private(set) var currentFrame = 0
    
    // MARK: - Sprite Nodes
    
    private let bodyNode = SKSpriteNode()
    private let headNode = SKSpriteNode()
    private let hairNode = SKSpriteNode()
    private let eyesNode = SKSpriteNode()
    private let shirtNode = SKSpriteNode()
    private let pantsNode = SKSpriteNode()
    private let shoesNode = SKSpriteNode()
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var textureCache: [String: SKTexture] = [:]
    
        private let containerNode = SKNode()
    
    // MARK: - Initialization
    
    /// Crea una nuova scena dell'avatar
    /// - Parameters:
    ///   - size: Dimensione della scena
    ///   - avatar: Dati dell'avatar da visualizzare
    init(size: CGSize, avatar: AvatarData) {
        self.avatar = avatar
        super.init(size: size)
        scaleMode = .aspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
            backgroundColor = .clear
            
            // Aggiungi il container node alla scena
            addChild(containerNode)
            
            // Centra il container
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
    
    // MARK: - Node Configuration
    
    /// Configura le dimensioni dei nodi
    private func configureNodes() {
        let nodeSize = CGSize(width: characterSize, height: characterSize)
        
        // Invece di ripetere lo stesso codice, imposta tutte le dimensioni in un colpo solo
        for node in [bodyNode, headNode, hairNode, eyesNode, shirtNode, pantsNode, shoesNode] {
            node.size = nodeSize
        }
    }
    
    /// Posiziona e configura i nodi nell'ordine corretto
    private func setupNodes() {
            // Centro relativo al container (0,0) invece che alla scena
            let center = CGPoint.zero
            
            // Configurazione ordinata dei nodi con zPosition
            let nodeConfigs: [(node: SKSpriteNode, zPosition: CGFloat)] = [
                (bodyNode, 0),
                (pantsNode, 1),
                (shoesNode, 2),
                (shirtNode, 3),
                (headNode, 4),
                (eyesNode, 5),
                (hairNode, 6)
            ]
            
            // Applica configurazione e aggiungi al container
            for (node, zPosition) in nodeConfigs {
                node.position = center
                node.zPosition = zPosition
                containerNode.addChild(node)  // Aggiunto al container invece che alla scena
            }
            
            updateTextures()
        }
    
    // MARK: - Texture Management
    
    /// Genera il nome completo dell'asset
    private func assetName(base: String, gender: Gender, anim: String, dir: String, frame: Int) -> String {
        let genderPrefix = (gender == .male) ? "male_" : "female_"
        return "\(genderPrefix)\(base)_\(anim)_\(dir)_\(frame)"
    }
    
    /// Ottiene una texture dalla cache o la crea se non esiste
    private func getTexture(named name: String) -> SKTexture {
        if let cachedTexture = textureCache[name] {
            return cachedTexture
        }
        
        let texture = SKTexture(imageNamed: name)
        textureCache[name] = texture
        return texture
    }
    
    /// Aggiorna le texture di tutti i nodi
    func updateTextures() {
        let dir = currentDirection.rawValue
        let anim = currentAnimation.rawValue
        let frame = currentFrame
        let gender = avatar.gender
        
        // Ripristina i valori predefiniti per colore e blending
        [bodyNode, headNode, hairNode, eyesNode, shirtNode, pantsNode, shoesNode].forEach {
            $0.colorBlendFactor = 0.0
        }
        
        // Aggiorna le texture usando il caching
        bodyNode.texture = getTexture(named: assetName(base: avatar.skin, gender: gender, anim: anim, dir: dir, frame: frame))
        headNode.texture = getTexture(named: assetName(base: avatar.head, gender: gender, anim: anim, dir: dir, frame: frame))
        eyesNode.texture = getTexture(named: assetName(base: avatar.eyes, gender: gender, anim: anim, dir: dir, frame: frame))
        shirtNode.texture = getTexture(named: assetName(base: avatar.shirt, gender: gender, anim: anim, dir: dir, frame: frame))
        pantsNode.texture = getTexture(named: assetName(base: avatar.pants, gender: gender, anim: anim, dir: dir, frame: frame))
        shoesNode.texture = getTexture(named: assetName(base: avatar.shoes, gender: gender, anim: anim, dir: dir, frame: frame))
        
        // Gestione speciale dei capelli
        if avatar.hair == "none" {
            hairNode.texture = nil
            hairNode.isHidden = true
        } else {
            hairNode.isHidden = false
            hairNode.texture = getTexture(named: assetName(base: avatar.hair, gender: gender, anim: anim, dir: dir, frame: frame))
        }
    }
    
    // MARK: - Animation Control
    
    /// Ottiene il numero totale di frame per un'animazione
    private func totalFrames(for animation: AvatarAnimation) -> Int {
        return AvatarScene.animationFrameCounts[animation] ?? 1
    }
    
    /// Resetta l'animazione corrente al primo frame
    private func resetAnimation() {
        currentFrame = 0
        updateTextures()
    }
    
    /// Avvia l'animazione
    /// - Parameter animation: Tipo di animazione da avviare
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
    
    /// Interrompe l'animazione corrente
    func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Cambia l'animazione corrente
    /// - Parameter animation: Nuova animazione da eseguire
    func changeAnimation(to animation: AvatarAnimation) {
        startAnimation(for: animation)
    }
    
    /// Cambia la direzione dell'avatar
    /// - Parameter direction: Nuova direzione
    func changeDirection(to direction: AvatarDirection) {
        currentDirection = direction
    }
    
    // MARK: - Public API
    
    /// Aggiorna l'avatar visualizzato con nuovi dati
    /// - Parameter newAvatar: Nuovo avatar da visualizzare
    func updateAvatar(_ newAvatar: AvatarData) {
        self.avatar = newAvatar
        resetAnimation()
    }
    
    /// Pulisce la cache delle texture per liberare memoria
    func clearTextureCache() {
        textureCache.removeAll()
    }
}
