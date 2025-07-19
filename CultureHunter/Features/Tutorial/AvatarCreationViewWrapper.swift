//
//  AvatarCreationViewWrapper.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

// Wrapper per HairSelectionView
struct HairSelectionViewWrapper: View {
    @ObservedObject var viewModel: AvatarViewModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Usa HairSelectionView esistente
            HairSelectionView(viewModel: viewModel)
                .allowsHitTesting(true) // Manteniamo attiva la selezione
                .navigationBarHidden(true)
            
            // Pulsanti personalizzati del tutorial
            VStack {
                Spacer()
                HStack {
                    Button("Indietro") {
                        onBack()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Spacer()
                    
                    Button("Avanti") {
                        onComplete()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .background(Color.white.opacity(0.8))
            }
        }
    }
}

// Wrapper per EyeColorView
struct EyeColorViewWrapper: View {
    @ObservedObject var viewModel: AvatarViewModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Usa EyeColorView esistente
            EyeColorView(viewModel: viewModel)
                .allowsHitTesting(true)
                .navigationBarHidden(true)
            
            // Pulsanti personalizzati del tutorial
            VStack {
                Spacer()
                HStack {
                    Button("Indietro") {
                        onBack()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Spacer()
                    
                    Button("Avanti") {
                        onComplete()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .background(Color.white.opacity(0.8))
            }
        }
    }
}

// Wrapper per CarnagioneView
struct CarnagioneViewWrapper: View {
    @ObservedObject var viewModel: AvatarViewModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            // Usa CarnagioneView esistente
            CarnagioneView(viewModel: viewModel)
                .allowsHitTesting(true)
                .navigationBarHidden(true)
            
            // Pulsanti personalizzati del tutorial
            VStack {
                Spacer()
                HStack {
                    Button("Indietro") {
                        onBack()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Spacer()
                    
                    Button("Avanti") {
                        onComplete()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                .background(Color.white.opacity(0.8))
            }
        }
    }
}
