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
    var cornerRadius: CGFloat = 0
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("🚨 Video not found: \(videoName)")
            return AVPlayerViewController()
        }
        
        let player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            player.play()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        applyRoundedCorners(uiViewController)
        makeBackgroundTransparent(uiViewController)
    }
    
    private func applyRoundedCorners(_ controller: AVPlayerViewController) {
        guard cornerRadius > 0 else { return }

        controller.view.layer.cornerRadius = cornerRadius
        controller.view.clipsToBounds = true

        if let contentOverlayView = controller.contentOverlayView {
            contentOverlayView.layer.cornerRadius = cornerRadius
            contentOverlayView.clipsToBounds = true
        }

        DispatchQueue.main.async {
            guard let videoLayer = findVideoLayer(in: controller.view) else { return }

            let maskLayer = CAShapeLayer()
            maskLayer.frame = videoLayer.bounds
            maskLayer.path = UIBezierPath(
                roundedRect: videoLayer.bounds,
                cornerRadius: self.cornerRadius
            ).cgPath

            videoLayer.mask = maskLayer
        }
    }


    private func findVideoLayer(in view: UIView) -> CALayer? {
        if let playerLayer = view.layer.sublayers?.first(where: { $0 is AVPlayerLayer }) {
            return playerLayer
        }
        
        for subview in view.subviews {
            if let found = findVideoLayer(in: subview) {
                return found
            }
        }
        
        return nil
    }
    
    private func makeBackgroundTransparent(_ controller: AVPlayerViewController) {
        controller.view.backgroundColor = .clear
        controller.contentOverlayView?.backgroundColor = .clear
        
        for subview in controller.view.subviews {
            subview.backgroundColor = .clear
            for subsubview in subview.subviews {
                subsubview.backgroundColor = .clear
            }
        }
    }
    
}

extension View {
    func videoBackground(_ videoName: String, cornerRadius: CGFloat = 0) -> some View {
        ZStack {
            FullscreenVideoPlayer(videoName: videoName, cornerRadius: cornerRadius)
            self
        }
    }
}
