//
//  PrimaryButtonStyle.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.black)
            .cornerRadius(15)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
