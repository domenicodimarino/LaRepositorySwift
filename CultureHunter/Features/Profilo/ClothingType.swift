//
//  ClothingType.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 07/07/25.
//


import Foundation
import SwiftUI

// Definizione di un tipo di vestito generico
enum ClothingType {
    case shirt
    case pants
    case shoes
    
    var assetPrefix: String {
        switch self {
        case .shirt: return "035 clothes"
        case .pants: return "020 legs"
        case .shoes: return "015 shoes"
        }
    }
    
    var displayName: String {
        switch self {
        case .shirt: return "magliette"
        case .pants: return "pantaloni"
        case .shoes: return "scarpe"
        }
    }
    var isMasculine: Bool {
            switch self {
            case .pants: return true  // "pantaloni" è maschile
            case .shirt, .shoes: return false  // "magliette" e "scarpe" sono femminili
            }
        }
}

// Modello generico per tutti i tipi di abbigliamento
struct ClothingItem: Identifiable, Hashable {
    let id = UUID()
    let assetName: String
    let type: ClothingType
    let disponibile: Bool
    
    // Funzione helper per ottenere il nome dell'asset completo
    var fullAssetName: String {
        return assetName
    }
}
