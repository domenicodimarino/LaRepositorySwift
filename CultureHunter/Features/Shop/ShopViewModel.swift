//
//  ShopViewModel.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 08/07/25.
//
import SwiftUI

// Gestore delle monete e degli acquisti
class ShopViewModel: ObservableObject {
    @Published var items: [ShopItem] = []
    
    private var avatarViewModel: AvatarViewModel
    let inventoryManager = InventoryManager.shared
    
    // Proprietà calcolate
    var coins: Int { avatarViewModel.getCoins() }
    
    // MARK: - Lifecycle
    
    init(avatarViewModel: AvatarViewModel) {
        self.avatarViewModel = avatarViewModel
        loadItems()
    }
    
    // MARK: - Item Management
    
    /// Carica tutti gli item disponibili nello shop
    func loadItems() {
        // Creazione degli array di colori per riutilizzo
        let shirtColors = ["blue", "bluegray", "brown", "charcoal", "forest", "gray",
                          "green", "lavender", "leather", "maroon", "navy", "orange",
                          "pink", "purple", "red", "rose", "sky", "slate", "tan",
                          "teal", "walnut", "yellow"]
        
        let pantsColors = shirtColors
        
        let shoesColors = ["blue", "brown", "gray", "green", "leather", "navy",
                          "pink", "red", "slate", "tan", "yellow"]
        
        // Creazione degli item con una funzione di utilità
        items = createItems(type: .shirt, style: "TShirt", colors: shirtColors) +
                createItems(type: .pants, style: "Pants", colors: pantsColors) +
                createItems(type: .shoes, style: "Basic_Shoes", colors: shoesColors)
        
        updateOwnedStatus()
    }
    
    /// Funzione helper per creare array di item con colori diversi
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
    
    /// Aggiorna lo stato di possesso degli item
    func updateOwnedStatus() {
        for i in items.indices {
            items[i].isOwned = inventoryManager.isItemUnlocked(ClothingItem(
                assetName: items[i].assetName,
                type: items[i].type,
                disponibile: true
            ))
        }
    }
    
    /// Tenta l'acquisto di un item
    /// - Parameter item: L'item da acquistare
    /// - Returns: `true` se l'acquisto ha avuto successo, `false` altrimenti
    func buyItem(_ item: ShopItem) -> Bool {
        // Verifica se l'utente possiede già l'item
        if item.isOwned {
            return false
        }
        
        // Prova a spendere le monete
        if !avatarViewModel.spendCoins(item.price) {
            return false
        }
        
        // Sblocca l'item nell'inventario
        inventoryManager.unlockItem(withAssetName: item.assetName)
        
        // Aggiorna lo stato dell'item
        if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index].isOwned = true
            }
        
        return true
    }
    
    /// Restituisce gli item filtrati per tipo
    /// - Parameter type: Il tipo di item da filtrare
    /// - Returns: Array di item del tipo specificato
    func items(ofType type: ClothingType) -> [ShopItem] {
        return items.filter { $0.type == type }
                    .sorted { !$0.isOwned && $1.isOwned }
    }
}
