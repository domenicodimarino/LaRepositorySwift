//
//  FullscreenVideoPlayer.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI
import AVKit

struct FullscreenVideoPlayer: UIViewControllerRepresentable {
    let videoName: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("🚨 Video non trovato: \(videoName)")
            return AVPlayerViewController()
        }
        
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        
        // Configura il loop
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        
        // Avvia la riproduzione con delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Renderizza lo sfondo trasparente (è necessario farlo qui per assicurarsi che venga applicato)
        makeBackgroundTransparent(uiViewController)
    }
    
    private func makeBackgroundTransparent(_ controller: AVPlayerViewController) {
        // Rendi trasparente il controller view
        controller.view.backgroundColor = .clear
        
        // Cerca il playerLayer per impostarne la trasparenza dello sfondo
        for subview in controller.view.subviews {
            // Rimuovi qualsiasi sfondo scuro nelle subview
            subview.backgroundColor = .clear
            
            // Cerca più a fondo nelle sottoviste
            for subsubview in subview.subviews {
                subsubview.backgroundColor = .clear
            }
        }
        
        // Imposta qualsiasi vista contenitore come trasparente
        if let contentOverlayView = controller.contentOverlayView {
            contentOverlayView.backgroundColor = .clear
        }
    }
}

// Vista di estensione per utilizzare facilmente il player
extension View {
    func videoBackground(_ videoName: String) -> some View {
        ZStack {
            FullscreenVideoPlayer(videoName: videoName)
            self
        }
    }
}
