//
//  BadgeManager.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation

class BadgeManager: ObservableObject {
    @Published var badges: [BadgeModel] = []
    
    // Inizializza con la lista delle città e i POI totali per ciascuna
    init() {
        badges = [
            BadgeModel(cityName: "Salerno", totalPOI: 10, certifiedPOI: 7, unlockedDate: nil),
            BadgeModel(cityName: "Cetara", totalPOI: 10, certifiedPOI: 2, unlockedDate: nil),
            // ...altre città
        ]
    }
    
    /// Chiamata quando l'utente certifica un nuovo POI in una città
    func certifyPOI(for city: String) {
        guard let index = badges.firstIndex(where: { $0.cityName == city }) else { return }
        badges[index].certifiedPOI += 1
        if badges[index].certifiedPOI >= badges[index].totalPOI, badges[index].unlockedDate == nil {
            badges[index].unlockedDate = Date()
        }
    }
    
    /// Resetta i badge (per test/demo)
    func reset() {
        for i in badges.indices {
            badges[i].certifiedPOI = 0
            badges[i].unlockedDate = nil
        }
    }
}
