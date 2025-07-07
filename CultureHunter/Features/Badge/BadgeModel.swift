//
//  BadgeModel.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation

struct BadgeModel: Identifiable {
    let id = UUID()
    let cityName: String
    let totalPOI: Int
    var certifiedPOI: Int
    var unlockedDate: Date?   // nil se non ancora sbloccato
    
    var isUnlocked: Bool {
        certifiedPOI >= totalPOI
    }
    
    var progressText: String {
        "\(certifiedPOI)/\(totalPOI)"
    }
    
    // Rimuovi il prefisso "Badge/" e usa solo il nome immagine come in Assets
    var badgeImageName: String {
        let cityKey = cityName
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "'", with: "")
        return isUnlocked
            ? "badge_\(cityKey)_sbloccato"
            : "badge_\(cityKey)_bloccato"
    }
}
