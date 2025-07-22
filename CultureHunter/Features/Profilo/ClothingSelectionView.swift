//
//  ClothingSelectionView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct ClothingSelectionView<T: View>: View {
    @ObservedObject var viewModel: AvatarViewModel
    let clothingType: ClothingType
    let onItemSelected: (ClothingItem) -> Void
    
    @ViewBuilder let itemCardBuilder: (ClothingItem, Bool, @escaping () -> Void) -> T
    
    @State private var selectedItem: ClothingItem?
    private let inventoryManager = InventoryManager.shared
    
    var availableItems: [ClothingItem] {
        inventoryManager.getAvailableItems(ofType: clothingType)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                AvatarPreviewHeader(viewModel: viewModel)
                
                Spacer(minLength: 30)
                
                if availableItems.isEmpty {
                    Text("Nessun \(clothingType.displayName) disponibile")
                        .font(.headline)
                        .padding()
                } else {
                    Text("\(clothingType.displayName.capitalized) disponibili")
                        .font(.headline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 73, maximum: 100), spacing: 16)], spacing: 16) {
                        ForEach(availableItems) { item in
                            itemCardBuilder(
                                item,
                                selectedItem?.id == item.id,
                                {
                                    selectedItem = item
                                    onItemSelected(item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Text("Per ottenere \(clothingType.isMasculine ? "altri" : "altre") \(clothingType.displayName), compra allo shop o completa le missioni")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
        }
        .navigationTitle("\(clothingType.isMasculine ? "I tuoi" : "Le tue") \(clothingType.displayName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupInitialSelection()
        }
    }
    
    private func setupInitialSelection() {
            let currentAssetName: String
            switch clothingType {
            case .shirt:
                currentAssetName = viewModel.avatar.shirt
            case .pants:
                currentAssetName = viewModel.avatar.pants
            case .shoes:
                currentAssetName = viewModel.avatar.shoes
            }
            
            let allItems = inventoryManager.getClothingItems(ofType: clothingType)
            selectedItem = allItems.first { $0.assetName == currentAssetName }
            
            if selectedItem == nil || !inventoryManager.isItemUnlocked(selectedItem!) {
                selectedItem = availableItems.first
            }
        }
}

struct AvatarPreviewHeader: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    var body: some View {
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
    }
}

struct ClothingCard: View {
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
