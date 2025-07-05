//
//  AvatarSpriteKitView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 05/07/25.
//

import SwiftUI
import SpriteKit

struct AvatarSpriteKitView: UIViewRepresentable {
    @ObservedObject var viewModel: AvatarViewModel

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        let scene = AvatarScene(size: CGSize(width: 128, height: 128), avatar: viewModel.avatar)
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
        var scene: AvatarScene?
    }
}
struct AvatarSpriteKitView_Previews: PreviewProvider {
    static var previews: some View {
        let avatar = AvatarData(
            gender: .male,
            head: "100 head Human_male black",   // <-- controlla che esista davvero come base name
            hair: "120 hair Plain black",
            skin: "010 body Body_color light",
            shirt: "035 clothes TShirt white",
            pants: "020 legs Pants black",
            shoes: "015 shoes Basic_Shoes black",
            eyes: "105 eye_color Eye_Color blue"
        )
        AvatarSpriteKitView(viewModel: AvatarViewModel(avatar: avatar))
            .frame(width: 128, height: 128)
    }
}
