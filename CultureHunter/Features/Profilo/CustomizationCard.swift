//
//  CustomizationCard.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 06/07/25.
//

import SwiftUI

/// Card generica per la personalizzazione che può contenere qualsiasi tipo di contenuto
struct CustomizationCard<Content: View>: View {
    // Proprietà comuni
    let isSelected: Bool
    let onSelect: () -> Void
    
    // Costruttore del contenuto interno (usando ViewBuilder)
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Sfondo card - comune a tutti
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 73, height: 98)
                    .background(
                        isSelected
                            ? Color(red: 0.49, green: 0.49, blue: 0.49)
                            : Color(red: 0.85, green: 0.85, blue: 0.85)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .inset(by: 3)
                            .stroke(.black, lineWidth: 3)
                    )
                
                // Contenuto personalizzato (diverso per ogni tipo di card)
                content()
            }
            .overlay(
                Group {
                    if isSelected {
                        Image("checkmarkIcon")
                            .resizable()
                            .frame(width: 26, height: 26)
                            .padding(4)
                            .offset(x: 10, y: -5)
                    }
                }, alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Implementazioni specializzate

/// Card specializzata per capelli
struct HairCard: View {
    let imageName: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        CustomizationCard(isSelected: isSelected, onSelect: onSelect) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
        }
    }
}

/// Card carnagione - Usa direttamente ComplexionColors.Complexion
struct ComplexionCard: View {
    let complexion: ComplexionColors.Complexion
    let isSelected: Bool
    let onSelect: () -> Void
    
    
    init(complexion: ComplexionColors.Complexion, isSelected: Bool, onSelect: @escaping () -> Void) {
            self.complexion = complexion
            self.isSelected = isSelected
            self.onSelect = onSelect
        }
    
    // Costruttore per compatibilità con codice esistente
    init(complexionName: String, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.complexion = ComplexionColors.all.first { $0.assetName == complexionName } ??
                          ComplexionColors.all.first!
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    var body: some View {
        CustomizationCard(isSelected: isSelected, onSelect: onSelect) {
            Circle()
                .fill(complexion.color)
                .frame(width: 55, height: 55)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 4)
                )
        }
    }
}

// MARK: - Previews

#Preview("Hair Card") {
    VStack {
        HairCard(imageName: "120 hair Plain black", isSelected: true, onSelect: {})
        HairCard(imageName: "120 hair Plain blonde", isSelected: false, onSelect: {})
    }
}

#Preview("Complexion Card") {
    VStack {
        ComplexionCard(complexionName: "light", isSelected: true, onSelect: {})
        ComplexionCard(complexionName: "amber", isSelected: false, onSelect: {})
        ComplexionCard(complexionName: "brown", isSelected: false, onSelect: {})
    }
}
