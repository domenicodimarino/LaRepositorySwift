//
//  Diary.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 04/07/25.
//

import Foundation
import CoreLocation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let history: String
    let location: String

}

class PlacesData {
    static let shared = PlacesData()

    let places: [Place] = [
        Place(
            name: "Punto prova casa mia",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Torre di Cetara",
            imageName: "poi_locked",
            history: "",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Castello di Arechi",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Giardino della Minerva",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Porto di Salerno",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa di San Giorgio",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Piazza della Libertà",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Museo Diocesano San Matteo",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Duomo di Salerno",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa di Saragnano",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa del Monte dei Morti",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Teatro Verdi",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Acquedotto Medievale",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Museo dello Sbarco e Salerno Capitale",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Museo virtuale della scuola medica salernitana",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Museo archeologico provinciale di Salerno",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa della Santissima Annunziata",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Parrocchia di San Pietro Apostolo",
            imageName: "poi_locked",
            history: "",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Chiesa di Santa Maria di Costantinopoli",
            imageName: "poi_locked",
            history: "",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Chiesa di San Francesco",
            imageName: "poi_locked",
            history: "",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Fabbrica Nettuno",
            imageName: "poi_locked",
            history: "",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Monumento ai Caduti",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Duomo di Cava",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di San Rocco",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Giardini di San Giovanni",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di Maria Assunta in Cielo (Purgatorio)",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Santuario Francescano S.Francesco e S.Antonio",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di Santa Maria Incoronata dell'Olmo",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Abbazia della Santissima Trinità",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa dell'Avvocatella",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di San Lorenzo",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Villa Comunale Falcone e Borsellino",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Stadio Arechi",
            imageName: "poi_locked",
            history: "",
            location: "Salerno",
        ),
        Place(
            name: "Casa del Dom",
            imageName: "poi_locked",
            history: "",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "UNISA Edificio E",
            imageName: "poi_locked",
            history: "",
            location: "Fisciano, Salerno",
        ),
    ]
}
