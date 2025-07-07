//
//  EyeColorView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 06/07/25.
//
import SwiftUI

struct EyeColorView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    // Usiamo direttamente l'array predefinito
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
                
                // Layout adattivo basato sulla larghezza dello schermo
                GeometryReader { proxy in
                    VStack(alignment: .center, spacing: 20) {
                        let width = proxy.size.width
                        
                        // Determina la larghezza disponibile e crea le righe
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
                .frame(minHeight: 350) // Altezza minima per contenere la griglia
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
    
    // Costanti di layout
    let cardWidth: CGFloat = 73
    let minSpacing: CGFloat = 15
    
    var body: some View {
        VStack(spacing: 20) {
            // Prima sezione (3 card)
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
            
            // Seconda sezione (3 card)
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
            
            
            // Terza sezione sezione (il resto delle card)
            if eyeColors.count > 3 {
                let remainingCount = min(eyeColors.count - 5, 3) // Massimo 3 card nella seconda riga
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

#Preview {
    NavigationView {
        EyeColorView(viewModel: AvatarViewModel())
    }
}
