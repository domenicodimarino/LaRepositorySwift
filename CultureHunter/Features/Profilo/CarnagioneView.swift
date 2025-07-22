//
//  CarnagioneView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//

import SwiftUI

struct CarnagioneView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    let allComplexions = ComplexionColors.all
    
    @State private var selectedComplexion: ComplexionColors.Complexion?
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
                        
                        AdaptiveComplexionGrid(
                            containerWidth: width,
                            complexions: allComplexions,
                            selectedComplexion: selectedComplexion,
                            onSelectComplexion: selectComplexion
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
        .navigationTitle("Carnagione")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let currentSkin = viewModel.avatar.skin
            if let complexion = ComplexionColors.findComplexion(in: currentSkin) {
                selectedComplexion = complexion
            }
        }
    }
    
    private func selectComplexion(_ complexion: ComplexionColors.Complexion) {
        selectedComplexion = complexion
        viewModel.setSkin(complexion.assetName)
    }
}

struct AdaptiveComplexionGrid: View {
    let containerWidth: CGFloat
    let complexions: [ComplexionColors.Complexion]
    let selectedComplexion: ComplexionColors.Complexion?
    let onSelectComplexion: (ComplexionColors.Complexion) -> Void
    
    let cardWidth: CGFloat = 73
    let minSpacing: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 20) {
            if complexions.count > 0 {
                HStack(spacing: getOptimalSpacing(cardCount: 2)) {
                    ForEach(0..<min(2, complexions.count), id: \.self) { index in
                        ComplexionCard(
                            complexion: complexions[index],
                            isSelected: selectedComplexion?.id == complexions[index].id,
                            onSelect: { onSelectComplexion(complexions[index]) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if complexions.count > 2 {
                HStack(spacing: getOptimalSpacing(cardCount: 3)) {
                    ForEach(2..<min(5, complexions.count), id: \.self) { index in
                        ComplexionCard(
                            complexion: complexions[index],
                            isSelected: selectedComplexion?.id == complexions[index].id,
                            onSelect: { onSelectComplexion(complexions[index]) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if complexions.count > 5 {
                let remainingCount = min(complexions.count - 5, 2)
                HStack(spacing: getOptimalSpacing(cardCount: remainingCount)) {
                    ForEach(5..<min(7, complexions.count), id: \.self) { index in
                        ComplexionCard(
                            complexion: complexions[index],
                            isSelected: selectedComplexion?.id == complexions[index].id,
                            onSelect: { onSelectComplexion(complexions[index]) }
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
