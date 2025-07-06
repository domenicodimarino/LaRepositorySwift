//
//  EyeColors.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 06/07/25.
//
import SwiftUI

struct EyeColors {
    // Il modello per il colore degli occhi
    struct EyeColor: Identifiable, Hashable {
        let id = UUID()
        let assetName: String
        
        var color: Color {
            EyeColors.map[assetName] ?? .blue
        }
    }
    
    // Mappa colori degli occhi
    static let map: [String: Color] = [
        "blue": Color(red: 0.2, green: 0.5, blue: 0.8),
        "green": Color(red: 0.3, green: 0.6, blue: 0.3),
        "brown": Color(red: 0.5, green: 0.3, blue: 0.1),
        "gray": Color(red: 0.5, green: 0.5, blue: 0.5),
        "orange": Color(red: 0.9, green: 0.6, blue: 0.1),
        "purple": Color(red: 0.8, green: 0.1, blue: 0.8),
        "red": Color(red: 0.8, green: 0.1, blue: 0.1),
        "yellow": Color(red: 0.9, green: 0.9, blue: 0.1),
    ]
    
    // Lista di tutti i colori degli occhi
    static let all: [EyeColor] = [
        EyeColor(assetName: "blue"),
        EyeColor(assetName: "green"),
        EyeColor(assetName: "brown"),
        EyeColor(assetName: "gray"),
        EyeColor(assetName: "orange"),
        EyeColor(assetName: "purple"),
        EyeColor(assetName: "red"),
        EyeColor(assetName: "yellow")
    ]
    
    static func getColor(for name: String) -> Color {
        return map[name.lowercased()] ?? .blue
    }
    
    static func findEyeColor(in assetName: String) -> EyeColor? {
        for eyeColor in all {
            if assetName.contains(eyeColor.assetName) {
                return eyeColor
            }
        }
        return all.first { $0.assetName == "blue" }
    }
}
