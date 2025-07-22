//
//  ShirtView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct ShirtView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    var body: some View {
        ClothingSelectionView(
            viewModel: viewModel,
            clothingType: .shirt,
            onItemSelected: { item in
                viewModel.setShirt(item.assetName)
            },
            itemCardBuilder: { item, isSelected, onSelect in
                ClothingCard(
                    imageName: item.assetName,
                    isSelected: isSelected,
                    onSelect: onSelect
                )
            }
        )
    }
}
