//
//  HairSelectionView.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//  Ottimizzato il 08/07/25.
//

import SwiftUI

struct Hair: Identifiable, Hashable {
    let id = UUID()
    let assetName: String
    let tipo: String
    var displayName: String {
        if assetName == "none" {
            return "Nessuna"
        }
        
        let components = assetName.components(separatedBy: " ")
        return components.count > 3 ? components.last ?? "" : ""
    }
}

struct HairCategory: Identifiable {
    let id: String
    let title: String
    let items: [Hair]
    
    init(title: String, items: [Hair]) {
        self.id = title
        self.title = title
        self.items = items
    }
}

struct HairSelectionView: View {

    @ObservedObject var viewModel: AvatarViewModel
    
    private let categories: [HairCategory]
    
    @State private var scrollToCategory: String? = nil
    
    
    init(viewModel: AvatarViewModel) {
        self.viewModel = viewModel
        
        let categoryOrder = ["Nessuna", "Corti", "Lunghi"]
        
        let allHairs = Self.loadHairs()
        
        self.categories = categoryOrder.map { tipo in
            let hairsInCategory = allHairs.filter { $0.tipo == tipo }
            return HairCategory(title: tipo, items: hairsInCategory)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                avatarPreviewSection
                
                ForEach(categories) { category in
                    HairCategorySection(
                        title: categoryTitle(for: category.title),
                        items: category.items,
                        selectedHair: viewModel.avatar.hair,
                        onSelect: { hair in
                            viewModel.setHair(hair.assetName)
                        }
                    )
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .navigationTitle("Capigliatura")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            findCurrentCategory()
        }
    }
    
    private var avatarPreviewSection: some View {
        ZStack(alignment: .bottom) {
            Image("hair salon")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 308, height: 205)
                .clipped()
                .cornerRadius(16)
            
            AvatarSpriteKitView(viewModel: viewModel)
                .frame(width: 128, height: 128)
        }
        .padding(.horizontal)
    }
    
    private static func loadHairs() -> [Hair] {
        let hairColors = ["black", "dark brown", "light brown", "blonde",
                          "ginger", "gold", "gray", "white",
                          "green", "pink", "purple", "red", "blue"]
        
        let noHair = [Hair(assetName: "none", tipo: "Nessuna")]
        
        let shortHair = hairColors.map { Hair(assetName: "120 hair Plain \($0)", tipo: "Corti") }
        let longHair = hairColors.map { Hair(assetName: "120 hair Long \($0)", tipo: "Lunghi") }
        
        return noHair + shortHair + longHair
    }
    
    private func findCurrentCategory() {
        let currentHair = viewModel.avatar.hair
        for category in categories {
            if category.items.contains(where: { $0.assetName == currentHair }) {
                scrollToCategory = category.id
                break
            }
        }
    }
    private func categoryTitle(for type: String) -> String {
        switch type {
        case "Nessuna": return "Nessuna capigliatura"
        case "Corti": return "Capelli corti"
        case "Lunghi": return "Capelli lunghi"
        default: return type
        }
    }
}

struct HairCategorySection: View {
    let title: String
    let items: [Hair]
    let selectedHair: String
    let onSelect: (Hair) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { hair in
                        HairCard(
                            imageName: hair.assetName,
                            isSelected: selectedHair == hair.assetName,
                            onSelect: { onSelect(hair) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
