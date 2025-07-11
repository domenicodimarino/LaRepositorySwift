import MapKit
import SwiftUI
import SpriteKit

// Vista annotazione che mostra l'avatar
class CustomUserAnnotationView: MKAnnotationView {
    private var skView: SKView?
    private var avatarViewModel: AvatarViewModel
    private var scene: AvatarScene?  // MODIFICATO: UserLocationAvatarScene -> AvatarScene
    
    // Binding per direzione e movimento
    private var userHeading: Double = 0 {
        didSet {
            if oldValue != userHeading {
                updateScene()
            }
        }
    }
    
    private var isMoving: Bool = false {
        didSet {
            if oldValue != isMoving {
                updateScene()
            }
        }
    }
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, avatarViewModel: AvatarViewModel) {
        self.avatarViewModel = avatarViewModel
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Dimensione dell'annotazione
        let size = CGSize(width: 64, height: 64)
        self.frame = CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)
        
        // Offset per allineare i piedi dell'avatar alla posizione esatta
        self.centerOffset = CGPoint(x: 0, y: 2)
        
        // Configurazione SpriteKit
        let skView = SKView(frame: bounds)
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        
        // Crea la scena dell'avatar
        let scene = AvatarScene(
            size: size,
            avatar: avatarViewModel.avatar
        )
        
        scene.characterSize = 64
        
        // Configura animazione e direzione iniziale
        scene.currentAnimation = .idle
        scene.currentDirection = .down
        
        skView.presentScene(scene)
        self.addSubview(skView)
        self.skView = skView
        self.scene = scene
    }
    
    // Aggiorna la scena quando cambiano i dati
    private func updateScene() {
        guard let scene = scene else { return }
        
        // Determina direzione basata sull'heading
        let direction = directionFromHeading(userHeading)
        scene.currentDirection = direction
        
        // Cambia animazione
        let animation: AvatarAnimation = isMoving ? .walk : .idle
        if scene.currentAnimation != animation {
            scene.changeAnimation(to: animation)
        }
    }
    
    // Converte l'heading in una direzione
    private func directionFromHeading(_ heading: Double) -> AvatarDirection {
        let normalizedHeading = heading < 0 ? heading + 360 : heading
        
        switch normalizedHeading {
        case 315...360, 0..<45:
            return .up
        case 45..<135:
            return .right
        case 135..<225:
            return .down
        case 225..<315:
            return .left
        default:
            return .down
        }
    }
    
    // Metodi pubblici per aggiornare lo stato
    func updateHeading(_ heading: Double) {
        self.userHeading = heading
    }
    
    func updateMovingState(_ moving: Bool) {
        self.isMoving = moving
    }
    
    func updateAvatar() {
        scene?.updateAvatar(avatarViewModel.avatar)
    }
    
    // Pulizia risorse
    deinit {
        scene?.removeAllActions()
        scene?.removeAllChildren()
    }
    
    func updateAvatar(with newAvatar: AvatarData) {
            avatarViewModel = AvatarViewModel(avatar: newAvatar)  // Crea una nuova copia
            scene?.updateAvatar(newAvatar)
        }
}
