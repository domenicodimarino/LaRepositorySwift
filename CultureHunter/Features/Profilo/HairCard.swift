//
//  HairCard.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//


import SwiftUI

struct HairCard: View {
    let imageName: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            ZStack {
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
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
            }
            .overlay(
                Group {
                    if isSelected {
                        Image("checkmarkIcon") // nome asset spunta
                            .resizable()
                            .frame(width: 26, height: 26)
                            .padding(4)
                            .offset(x:10, y: -5)
                    }
                }, alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
