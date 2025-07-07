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
                
                // Layout adattivo basato sulla larghezza dello schermo
                GeometryReader { proxy in
                    VStack(alignment: .center, spacing: 20) {
                        let width = proxy.size.width
                        
                        // Determina la larghezza disponibile e crea le righe
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
                .frame(minHeight: 350) // Altezza minima per contenere la griglia
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
    
    // Costanti di layout
    let cardWidth: CGFloat = 73
    let minSpacing: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 20) {
            // Prima sezione (2 card)
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
            
            // Seconda sezione (3 card)
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
            
            // Terza sezione (2 card o il resto)
            if complexions.count > 5 {
                let remainingCount = min(complexions.count - 5, 2) // Massimo 2 card nell'ultima riga
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
    
    // Calcola lo spazio ottimale tra le card in base alla larghezza disponibile
    private func getOptimalSpacing(cardCount: Int) -> CGFloat {
        // Spazio disponibile dopo aver sottratto la larghezza di tutte le card
        let totalCardWidth = cardWidth * CGFloat(cardCount)
        let availableSpace = containerWidth - totalCardWidth
        
        // Se non c'è abbastanza spazio, usa lo spazio minimo
        if availableSpace < minSpacing * CGFloat(cardCount - 1) {
            return minSpacing
        }
        
        // Calcola lo spazio equidistante
        let spacing = availableSpace / CGFloat(cardCount + 1)
        return max(spacing, minSpacing)
    }
}
