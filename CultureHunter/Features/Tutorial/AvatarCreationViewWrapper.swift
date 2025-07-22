//
//  AvatarCreationViewWrapper.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 19/07/25.
//


import SwiftUI

struct HairSelectionViewWrapper: View {
    @ObservedObject var viewModel: AvatarViewModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            HairSelectionView(viewModel: viewModel)
                .allowsHitTesting(true)
                .navigationBarHidden(true)
            
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
                .background(Material.ultraThinMaterial)
            }
        }
    }
}

struct EyeColorViewWrapper: View {
    @ObservedObject var viewModel: AvatarViewModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            EyeColorView(viewModel: viewModel)
                .allowsHitTesting(true)
                .navigationBarHidden(true)
            
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
                .background(Material.ultraThinMaterial)
            }
        }
    }
}

struct CarnagioneViewWrapper: View {
    @ObservedObject var viewModel: AvatarViewModel
    let onComplete: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            CarnagioneView(viewModel: viewModel)
                .allowsHitTesting(true)
                .navigationBarHidden(true)
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
                .background(Material.ultraThinMaterial)
            }
        }
    }
}
