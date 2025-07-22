//
//  ShoesView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct ShoesView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    var body: some View {
        ClothingSelectionView(
            viewModel: viewModel,
            clothingType: .shoes,
            onItemSelected: { item in
                viewModel.setShoes(item.assetName)
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
