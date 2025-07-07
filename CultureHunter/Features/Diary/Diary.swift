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
    let imageURL: String
    let history: String
    let yearBuilt: String
    let location: String
}

// Database di luoghi con informazioni storiche
class PlacesData {
    static let shared = PlacesData()
    
    let places = [
        Place(
            name: "Colosseo",
            imageURL: "https://www.rome.net/wp-content/uploads/2016/10/colosseum-tickets.jpg",
            history: "Il Colosseo, originariamente noto come Anfiteatro Flavio, è un anfiteatro ovale situato nel centro di Roma. Costruito in calcestruzzo e sabbia, è il più grande anfiteatro mai costruito ed è considerato una delle più grandi opere dell'architettura e dell'ingegneria romana. La costruzione iniziò sotto l'imperatore Vespasiano nel 72 d.C. e fu completata sotto Tito nell'80 d.C. Poteva ospitare tra 50.000 e 80.000 spettatori ed era utilizzato per combattimenti di gladiatori e spettacoli pubblici.",
            yearBuilt: "72-80 d.C.",
            location: "Roma, Italia"
        ),
        Place(
            name: "Torre Eiffel",
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Tour_Eiffel_Wikimedia_Commons_%28cropped%29.jpg/800px-Tour_Eiffel_Wikimedia_Commons_%28cropped%29.jpg",
            history: "La Torre Eiffel è una torre in ferro battuto situata sul Champ de Mars a Parigi. Prende il nome dal suo ingegnere, Gustave Eiffel, la cui azienda ha progettato e costruito la torre. Costruita dal 1887 al 1889 come ingresso principale dell'Esposizione Universale del 1889, inizialmente fu criticata da alcuni dei principali artisti e intellettuali francesi per il suo design, ma è diventata un'icona culturale globale della Francia.",
            yearBuilt: "1887-1889",
            location: "Parigi, Francia"
        ),
        Place(
            name: "Taj Mahal",
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Taj_Mahal%2C_Agra%2C_India_edit3.jpg/1200px-Taj_Mahal%2C_Agra%2C_India_edit3.jpg",
            history: "Il Taj Mahal è un mausoleo di marmo bianco avorio situato sulla riva meridionale del fiume Yamuna nella città di Agra. Fu commissionato nel 1632 dall'imperatore Mughal Shah Jahan per ospitare la tomba della sua moglie preferita, Mumtaz Mahal. La tomba è il pezzo centrale di un complesso di 17 ettari che comprende una moschea e una casa per gli ospiti ed è circondato da giardini formali delimitati su tre lati da un muro di cinta.",
            yearBuilt: "1632-1653",
            location: "Agra, India"
        ),
        Place(
            name: "Statua della Libertà",
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Statue_of_Liberty_7.jpg/800px-Statue_of_Liberty_7.jpg",
            history: "La Statua della Libertà è una figura colossale su Liberty Island a New York Harbor. La statua, un dono del popolo francese a quello americano, fu progettata dallo scultore francese Frédéric Auguste Bartholdi e costruita da Gustave Eiffel. La statua è un'icona della libertà e degli Stati Uniti, e fu un simbolo di benvenuto per gli immigrati che arrivavano via mare.",
            yearBuilt: "1875-1886",
            location: "New York, Stati Uniti"
        ),
        Place(
            name: "Grande Muraglia Cinese",
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/The_Great_Wall_of_China_at_Jinshanling-edit.jpg/1200px-The_Great_Wall_of_China_at_Jinshanling-edit.jpg",
            history: "La Grande Muraglia Cinese è una serie di fortificazioni fatte di pietra, mattoni, terra battuta, legno e altri materiali, costruite lungo un asse est-ovest attraverso i confini storici della Cina settentrionale per proteggere gli stati e gli imperi cinesi dagli attacchi delle varie tribù nomadi delle steppe dell'Eurasia. Diverse mura furono costruite a partire dal VII secolo a.C., e furono successivamente unite e ricostruite; la maggior parte dell'attuale muraglia fu costruita durante la dinastia Ming.",
            yearBuilt: "VII secolo a.C. - XVI secolo d.C.",
            location: "Cina"
        )
    ]
}
