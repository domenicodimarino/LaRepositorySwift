//
//  ClothingSelectionView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

// View generica riutilizzabile per selezionare qualsiasi tipo di abbigliamento
struct ClothingSelectionView<T: View>: View {
    @ObservedObject var viewModel: AvatarViewModel
    let clothingType: ClothingType
    let onItemSelected: (ClothingItem) -> Void
    
    // Placeholder per la card personalizzata - consente personalizzazione per ogni tipo
    @ViewBuilder let itemCardBuilder: (ClothingItem, Bool, @escaping () -> Void) -> T
    
    @State private var selectedItem: ClothingItem?
    private let inventoryManager = InventoryManager.shared
    
    var availableItems: [ClothingItem] {
        inventoryManager.getAvailableItems(ofType: clothingType)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Avatar preview
                AvatarPreviewHeader(viewModel: viewModel)
                
                Spacer(minLength: 30)
                
                if availableItems.isEmpty {
                    Text("Nessun \(clothingType.displayName) disponibile")
                        .font(.headline)
                        .padding()
                } else {
                    // Titolo sezione
                    Text("\(clothingType.displayName.capitalized) disponibili")
                        .font(.headline)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Grid adattiva degli item
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
                
                // Messaggio informativo
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
            // Determina quale item è attualmente selezionato in base al tipo
            let currentAssetName: String
            switch clothingType {
            case .shirt:
                currentAssetName = viewModel.avatar.shirt
            case .pants:
                currentAssetName = viewModel.avatar.pants
            case .shoes:
                currentAssetName = viewModel.avatar.shoes
            }
            
            // Trova l'item corrispondente tra tutti gli item (non solo quelli disponibili)
            // Questo è importante nel caso in cui l'item corrente non sia più disponibile
            let allItems = inventoryManager.getClothingItems(ofType: clothingType)
            selectedItem = allItems.first { $0.assetName == currentAssetName }
            
            // Se non trovato o non è sbloccato, usa il primo disponibile
            if selectedItem == nil || !inventoryManager.isItemUnlocked(selectedItem!) {
                selectedItem = availableItems.first
            }
        }
}

// Component riutilizzabile per l'anteprima dell'avatar
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

// Card generica per gli articoli di abbigliamento
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
