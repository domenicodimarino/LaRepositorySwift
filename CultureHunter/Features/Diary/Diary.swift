//
//  Diary.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//

import Foundation

// Modello di dati ampliato per un luogo
struct Place: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String     // <-- Cambiato da imageURL a imageName
    let history: String
    let yearBuilt: String
    let location: String
}

// Database di luoghi con informazioni storiche
class PlacesData {
    static let shared = PlacesData()
    
    let places = [
        Place(
            name: "Casa Mia",
            imageName: "shirt_mission", // <-- nome asset tra virgolette!
            history: "Il Colosseo, originariamente noto come Anfiteatro Flavio, è un anfiteatro ovale situato nel centro di Roma. Costruito in calcestruzzo e sabbia, è il più grande anfiteatro mai costruito ed è considerato una delle più grandi opere dell'architettura e dell'ingegneria romana. La costruzione iniziò sotto l'imperatore Vespasiano nel 72 d.C. e fu completata sotto Tito nell'80 d.C. Poteva ospitare tra 50.000 e 80.000 spettatori ed era utilizzato per combattimenti di gladiatori e spettacoli pubblici.",
            yearBuilt: "72-80 d.C.",
            location: "Cava de' Tirreni, Italia"
        )
    ]
}
