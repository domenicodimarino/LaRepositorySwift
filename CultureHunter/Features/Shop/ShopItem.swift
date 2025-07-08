//
//  ShopItem.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 08/07/25.
//
import Foundation

// Modello per un articolo dello shop
struct ShopItem: Identifiable, Equatable {
    let id = UUID()
    let assetName: String
    let price: Int
    let type: ClothingType
    var isOwned: Bool
    
    // Implementazione efficiente di Equatable
    static func == (lhs: ShopItem, rhs: ShopItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed property per ottenere il nome visualizzabile
    var displayName: String {
        let components = assetName.components(separatedBy: " ")
        if components.count >= 3 {
            let itemType = components[2]
            let color = components.dropFirst(3).joined(separator: " ")
            return "\(itemType) \(color)"
        }
        return assetName
    }
}
