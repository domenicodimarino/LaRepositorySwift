//
//  PantsView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import SwiftUI

struct PantsView: View {
    @ObservedObject var viewModel: AvatarViewModel
    
    var body: some View {
        ClothingSelectionView(
            viewModel: viewModel,
            clothingType: .pants,
            onItemSelected: { item in
                viewModel.setPants(item.assetName)
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

#Preview {
    NavigationView {
        PantsView(viewModel: AvatarViewModel())
    }
}
