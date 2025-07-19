//
//  PrimaryButtonStyle.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.black : Color.gray)
            .cornerRadius(25)
            .padding(.horizontal, 40)
            .opacity(configuration.isPressed && isEnabled ? 0.8 : 1.0)
            .disabled(!isEnabled)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.black)
            .cornerRadius(15)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}