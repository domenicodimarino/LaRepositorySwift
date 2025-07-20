//
//  RoundedVideoContainer.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 20/07/25.
//


import SwiftUI

import SwiftUI

struct RoundedVideoContainer: View {
    let videoName: String
    let cornerRadius: CGFloat

    var body: some View {
        FullscreenVideoPlayer(videoName: videoName, cornerRadius: cornerRadius)
            .aspectRatio(734.0 / 1530.0, contentMode: .fit) // proporzione reale del video
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.red, lineWidth: 0)
            )
    }
}
