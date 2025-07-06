//
//  ComplexionColors.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 06/07/25.
//
import SwiftUI

// Definizione combinata
struct ComplexionColors {
    // Il modello di carnagione ora fa parte della stessa struttura
    struct Complexion: Identifiable, Hashable {
        let id = UUID()
        let assetName: String
        
        var color: Color {
            ComplexionColors.map[assetName] ?? .brown
        }
    }
    
    // Mappa colori
    static let map: [String: Color] = [
        "amber": Color(red: 0.98, green: 0.84, blue: 0.65),
        "light": Color(red: 0.98, green: 0.85, blue: 0.73),
        "black": Color(red: 0.45, green: 0.3, blue: 0.25),
        "bronze": Color(red: 0.8, green: 0.6, blue: 0.4),
        "brown": Color(red: 0.65, green: 0.45, blue: 0.3),
        "olive": Color(red: 0.85, green: 0.7, blue: 0.5),
        "taupe": Color(red: 0.75, green: 0.55, blue: 0.4)
    ]
    
    // Lista di tutte le carnagioni, già ordinate come preferisci
    static let all: [Complexion] = [
        Complexion(assetName: "light"),
        Complexion(assetName: "amber"),
        Complexion(assetName: "bronze"),
        Complexion(assetName: "brown"),
        Complexion(assetName: "black"),
        Complexion(assetName: "olive"),
        Complexion(assetName: "taupe")
    ]
    
    static func getColor(for name: String) -> Color {
        return map[name.lowercased()] ?? .brown
    }
    
    static func findComplexion(in assetName: String) -> Complexion? {
        for complexion in all {
            if assetName.contains(complexion.assetName) {
                return complexion
            }
        }
        return all.first { $0.assetName == "light" }
    }
}
