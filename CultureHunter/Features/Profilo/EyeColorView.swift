//
//  EyeColorView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 06/07/25.
//
import SwiftUI

struct EyeColorView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    let allEyeColors = EyeColors.all
    
    @State private var selectedEyeColor: EyeColors.EyeColor?
    @State private var containerWidth: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .bottom) {
                    Image("room")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 308, height: 205)
                        .clipped()
                        .cornerRadius(16)
                    AvatarSpriteKitView(viewModel: viewModel)
                        .frame(width: 128, height: 128)
                }
                .padding(.top)
                .frame(maxWidth: .infinity)
                
                Spacer(minLength: 30)
                
                GeometryReader { proxy in
                    VStack(alignment: .center, spacing: 20) {
                        let width = proxy.size.width
                        
                        AdaptiveEyeColorGrid(
                            containerWidth: width,
                            eyeColors: allEyeColors,
                            selectedEyeColor: selectedEyeColor,
                            onSelectEyeColor: selectEyeColor
                        )
                    }
                    .onAppear {
                        containerWidth = proxy.size.width
                    }
                    .onChange(of: proxy.size.width) { oldWidth, newWidth in
                        containerWidth = newWidth
                    }
                    .frame(width: proxy.size.width)
                }
                .padding(.horizontal)
                .frame(minHeight: 350)
            }
        }
        .navigationTitle("Colore degli occhi")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let currentEyes = viewModel.avatar.eyes
            if let eyeColor = EyeColors.findEyeColor(in: currentEyes) {
                selectedEyeColor = eyeColor
            }
        }
    }
    
    private func selectEyeColor(_ eyeColor: EyeColors.EyeColor) {
        selectedEyeColor = eyeColor
        viewModel.setEyes(eyeColor.assetName)
    }
}

struct AdaptiveEyeColorGrid: View {
    let containerWidth: CGFloat
    let eyeColors: [EyeColors.EyeColor]
    let selectedEyeColor: EyeColors.EyeColor?
    let onSelectEyeColor: (EyeColors.EyeColor) -> Void
    
    let cardWidth: CGFloat = 73
    let minSpacing: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 20) {
            if eyeColors.count > 0 {
                HStack(spacing: getOptimalSpacing(cardCount: 3)) {
                    ForEach(0..<min(3, eyeColors.count), id: \.self) { index in
                        EyeColorCard(
                            eyeColor: eyeColors[index],
                            isSelected: selectedEyeColor?.id == eyeColors[index].id,
                            onSelect: { onSelectEyeColor(eyeColors[index]) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if eyeColors.count > 2 {
                HStack(spacing: getOptimalSpacing(cardCount: 2)) {
                    ForEach(3..<min(5, eyeColors.count), id: \.self) { index in
                        EyeColorCard(
                            eyeColor: eyeColors[index],
                            isSelected: selectedEyeColor?.id == eyeColors[index].id,
                            onSelect: { onSelectEyeColor(eyeColors[index]) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            
            if eyeColors.count > 3 {
                let remainingCount = min(eyeColors.count - 5, 3)
                HStack(spacing: getOptimalSpacing(cardCount: remainingCount)) {
                    ForEach(5..<min(8, eyeColors.count), id: \.self) { index in
                        EyeColorCard(
                            eyeColor: eyeColors[index],
                            isSelected: selectedEyeColor?.id == eyeColors[index].id,
                            onSelect: { onSelectEyeColor(eyeColors[index]) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private func getOptimalSpacing(cardCount: Int) -> CGFloat {
        let totalCardWidth = cardWidth * CGFloat(cardCount)
        let availableSpace = containerWidth - totalCardWidth
        
        if availableSpace < minSpacing * CGFloat(cardCount - 1) {
            return minSpacing
        }
        
        let spacing = availableSpace / CGFloat(cardCount + 1)
        return max(spacing, minSpacing)
    }
}
