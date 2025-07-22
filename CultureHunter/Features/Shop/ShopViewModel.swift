//
//  ShopViewModel.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 08/07/25.
//
import SwiftUI

class ShopViewModel: ObservableObject {
    @Published var items: [ShopItem] = []
    
    private var avatarViewModel: AvatarViewModel
    let inventoryManager = InventoryManager.shared
    
    var coins: Int { avatarViewModel.getCoins() }
    
    init(avatarViewModel: AvatarViewModel) {
        self.avatarViewModel = avatarViewModel
        loadItems()
    }
    
    func loadItems() {
        let shirtColors = ["blue", "bluegray", "brown", "charcoal", "forest", "gray",
                          "green", "lavender", "leather", "maroon", "navy", "orange",
                          "pink", "purple", "red", "rose", "sky", "slate", "tan",
                          "teal", "walnut", "yellow"]
        
        let pantsColors = shirtColors
        
        let shoesColors = ["blue", "brown", "gray", "green", "leather", "navy",
                          "pink", "red", "slate", "tan", "yellow"]
        
        items = createItems(type: .shirt, style: "TShirt", colors: shirtColors) +
                createItems(type: .pants, style: "Pants", colors: pantsColors) +
                createItems(type: .shoes, style: "Basic_Shoes", colors: shoesColors)
        
        updateOwnedStatus()
    }
    
    private func createItems(type: ClothingType, style: String, colors: [String]) -> [ShopItem] {
        return colors.map { color in
            ShopItem(
                assetName: "\(type.assetPrefix) \(style) \(color)",
                price: 20,
                type: type,
                isOwned: false
            )
        }
    }
    
    func updateOwnedStatus() {
        for i in items.indices {
            items[i].isOwned = inventoryManager.isItemUnlocked(ClothingItem(
                assetName: items[i].assetName,
                type: items[i].type,
                disponibile: true
            ))
        }
    }
    
    func buyItem(_ item: ShopItem) -> Bool {
        if item.isOwned {
            return false
        }
        
        if !avatarViewModel.spendCoins(item.price) {
            return false
        }
        
        inventoryManager.unlockItem(withAssetName: item.assetName)
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].isOwned = true
            }
        
        return true
    }
    
    func items(ofType type: ClothingType) -> [ShopItem] {
        return items.filter { $0.type == type }
                    .sorted { !$0.isOwned && $1.isOwned }
    }
}
