import SwiftUI
import SpriteKit

struct CarSpriteKitView: View {
    let direction: AvatarDirection
    
    var body: some View {
        SpriteViewWrapper(direction: direction)
            .background(Color.clear) // Esplicita il background trasparente
    }
}

struct SpriteViewWrapper: UIViewRepresentable {
    let direction: AvatarDirection
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.backgroundColor = .clear
        view.allowsTransparency = true // Importante per la trasparenza
        
        let scene = SKScene(size: CGSize(width: 80, height: 80))
        scene.backgroundColor = .clear
        scene.scaleMode = .aspectFit
        
        let car = SKSpriteNode(imageNamed: imageNameForDirection())
        car.position = CGPoint(x: scene.size.width/2, y: scene.size.height/2)
        car.size = CGSize(width: scene.size.width * 0.9, height: scene.size.height * 0.9)
        scene.addChild(car)
        
        view.presentScene(scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene {
            (scene.children.first as? SKSpriteNode)?.texture = SKTexture(imageNamed: imageNameForDirection())
        }
    }
    
    private func imageNameForDirection() -> String {
        switch direction {
        case .up: return "car_n"
        case .right: return "car_e"
        case .down: return "car_s"
        case .left: return "car_w"
        }
    }
}

extension View {
    func withSize(width: CGFloat, height: CGFloat) -> some View {
        self
            .frame(width: width, height: height)
            .aspectRatio(contentMode: .fit)
    }
}
