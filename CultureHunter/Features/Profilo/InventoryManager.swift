//
//  InventoryManager.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//

import Foundation

class InventoryManager {
    static let shared = InventoryManager()
    
    private let unlockedItemsKey = "unlockedItems"
    
    private let initiallyUnlockedItems = [
        "TShirt white",
        "TShirt black",
        "Basic_Shoes black",
        "Basic_Shoes white",
        "Pants black",
        "Pants white",
    ]
    
    private var allItems: [ClothingType: [ClothingItem]] = [:]
    
    private init() {
        allItems[.shirt] = createShirtItems()
        allItems[.pants] = createPantsItems()
        allItems[.shoes] = createShoesItems()
        
        ensureInitialItemsAreUnlocked()
    }
    
    func getClothingItems(ofType type: ClothingType) -> [ClothingItem] {
        return allItems[type] ?? []
    }
    
    func getAvailableItems(ofType type: ClothingType) -> [ClothingItem] {
        return getClothingItems(ofType: type).filter { isItemUnlocked($0) }
    }
    
    func isItemUnlocked(_ item: ClothingItem) -> Bool {
        let baseName = extractBaseName(from: item.assetName)
        let unlockedItems = getUnlockedItemsList()
        return unlockedItems.contains(baseName)
    }
    
    func unlockItem(_ item: ClothingItem) {
        let baseName = extractBaseName(from: item.assetName)
        var unlockedItems = getUnlockedItemsList()
        if !unlockedItems.contains(baseName) {
            unlockedItems.append(baseName)
            saveUnlockedItems(unlockedItems)
        }
    }
    
    func unlockItem(withAssetName assetName: String) {
        let baseName = extractBaseName(from: assetName)
        var unlockedItems = getUnlockedItemsList()
        if !unlockedItems.contains(baseName) {
            unlockedItems.append(baseName)
            saveUnlockedItems(unlockedItems)
        }
    }
    
    
    private func extractBaseName(from assetName: String) -> String {
        let components = assetName.components(separatedBy: " ")
        if components.count >= 3 {
            return components.dropFirst(2).joined(separator: " ")
        }
        return assetName
    }
    
    private func getUnlockedItemsList() -> [String] {
        return UserDefaults.standard.stringArray(forKey: unlockedItemsKey) ?? []
    }
    
    private func saveUnlockedItems(_ items: [String]) {
        UserDefaults.standard.set(items, forKey: unlockedItemsKey)
    }
    
    private func ensureInitialItemsAreUnlocked() {
        var currentUnlocked = getUnlockedItemsList()
        var changed = false
        
        for item in initiallyUnlockedItems {
            if !currentUnlocked.contains(item) {
                currentUnlocked.append(item)
                changed = true
            }
        }
        
        if changed {
            saveUnlockedItems(currentUnlocked)
        }
    }
    
    private func createShirtItems() -> [ClothingItem] {
        let prefix = ClothingType.shirt.assetPrefix
        let colorNames = ["white", "black", "blue", "bluegray", "brown",
                          "charcoal", "forest", "gray", "green", "lavender",
                          "leather", "maroon", "navy", "orange", "pink",
                          "purple", "red", "rose", "sky", "slate",
                          "tan", "teal", "walnut", "yellow"]
        
        return colorNames.map { color in
            ClothingItem(
                assetName: "\(prefix) TShirt \(color)",
                type: .shirt,
                disponibile: false
            )
        }
    }
    
    private func createPantsItems() -> [ClothingItem] {
        let prefix = ClothingType.pants.assetPrefix
        let colorNames = ["white", "black", "blue", "bluegray", "brown",
                          "charcoal", "forest", "gray", "green", "lavender",
                          "leather", "maroon", "navy", "orange", "pink",
                          "purple", "red", "rose", "sky", "slate",
                          "tan", "teal", "walnut", "yellow"]
        return colorNames.map { color in
            ClothingItem(
                assetName: "\(prefix) Pants \(color)",
                type: .shirt,
                disponibile: false
            )
        }
    }
    
    private func createShoesItems() -> [ClothingItem] {
        let prefix = ClothingType.shoes.assetPrefix
        let colorNames = ["white", "black", "blue", "brown",
                          "gray", "green",
                          "leather","navy", "pink",
                          "red", "slate",
                          "tan", "yellow"]
        
        return colorNames.map { color in
            ClothingItem(
                assetName: "\(prefix) Basic_Shoes \(color)",
                type: .shirt,
                disponibile: false
            )
        }
    }
}
