//
//  ComplexionCard.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 06/07/25.
//
import SwiftUI

struct ComplexionCard: View {
    let complexionName: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    // Mappa dei colori di carnagione
    private let complexionColors: [String: Color] = [
        "amber": Color(red: 0.98, green: 0.84, blue: 0.65),
        "light": Color(red: 0.98, green: 0.85, blue: 0.73),
        "black": Color(red: 0.45, green: 0.3, blue: 0.25),
        "bronze": Color(red: 0.8, green: 0.6, blue: 0.4),
        "brown": Color(red: 0.65, green: 0.45, blue: 0.3),
        "olive": Color(red: 0.85, green: 0.7, blue: 0.5),
        "taupe": Color(red: 0.75, green: 0.55, blue: 0.4)
    ]

    var body: some View {
        Button(action: onSelect) {
            ZStack {
                // Sfondo card
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
                            .stroke(Color.black, lineWidth: 3)
                    )
                
                // Cerchio con colore carnagione
                Circle()
                    .fill(complexionColors[complexionName] ?? .brown)
                    .frame(width: 55, height: 55)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 4)
                    )
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

#Preview {
    VStack {
        HStack {
            ComplexionCard(complexionName: "light", isSelected: true, onSelect: {})
            ComplexionCard(complexionName: "amber", isSelected: false, onSelect: {})
        }
        HStack {
            ComplexionCard(complexionName: "brown", isSelected: false, onSelect: {})
            ComplexionCard(complexionName: "black", isSelected: false, onSelect: {})
        }
    }
}
