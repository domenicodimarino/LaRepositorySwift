import SwiftUI
import SpriteKit

struct CarSpriteKitView: View {
    let direction: AvatarDirection
    let carDirection: CarDirection
    
    init(direction: AvatarDirection, carDirection: CarDirection? = nil) {
        self.direction = direction
        self.carDirection = carDirection ?? CarDirection.fromAvatarDirection(direction)
    }
    
    var body: some View {
        SpriteViewWrapper(direction: direction, carDirection: carDirection)
            .background(Color.clear)
    }
}

struct SpriteViewWrapper: UIViewRepresentable {
    let direction: AvatarDirection
    let carDirection: CarDirection
        
        init(direction: AvatarDirection, carDirection: CarDirection? = nil) {
            self.direction = direction
            self.carDirection = carDirection ?? CarDirection.fromAvatarDirection(direction)
        }
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.backgroundColor = .clear
        view.allowsTransparency = true
        
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
            return "car_\(carDirection.rawValue)"
        }
}

extension View {
    func withSize(width: CGFloat, height: CGFloat) -> some View {
        self
            .frame(width: width, height: height)
            .aspectRatio(contentMode: .fit)
    }
}
