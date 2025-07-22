//
//  AvatarSpriteKitView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//  Ottimizzato il 08/07/25.
//

import SwiftUI
import SpriteKit

struct AvatarSpriteKitView: UIViewRepresentable {
    @ObservedObject var viewModel: AvatarViewModel
    
    var size: CGSize = CGSize(width: 128, height: 128)
    
    var scale: CGFloat = 1.0
    
    var initialAnimation: AvatarAnimation = .idle
    
    var initialDirection: AvatarDirection = .down
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        
        skView.ignoresSiblingOrder = false
        skView.shouldCullNonVisibleNodes = true
        
        let scene = AvatarScene(size: size, avatar: viewModel.avatar)
        scene.currentAnimation = initialAnimation
        scene.currentDirection = initialDirection
        
        skView.presentScene(scene)
        
        context.coordinator.scene = scene
        
        scene.containerNode.setScale(scale)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? AvatarScene {
            print("🎭 AvatarSpriteKitView - Animation: \(initialAnimation), Direction: \(initialDirection)")
            
            let currentAvatar = context.coordinator.scene?.avatar
            let newAvatar = viewModel.avatar
            
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
        func withScale(_ scale: CGFloat) -> AvatarSpriteKitView {
            var view = self
            view.scale = scale
            return view
        }
    
    class Coordinator {
        var scene: AvatarScene?
        
        func cleanup() {
            scene?.stopAnimation()
            scene?.clearTextureCache()
            scene = nil
        }
        
        deinit {
            cleanup()
        }
    }
    
    func withSize(width: CGFloat, height: CGFloat) -> AvatarSpriteKitView {
        var view = self
        view.size = CGSize(width: width, height: height)
        view.scale = min(width, height) / 128.0
        return view
    }
    
    func withAnimation(_ animation: AvatarAnimation, direction: AvatarDirection = .down) -> AvatarSpriteKitView {
        var view = self
        view.initialAnimation = animation
        view.initialDirection = direction
        return view
    }
}
