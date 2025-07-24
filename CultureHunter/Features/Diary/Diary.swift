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
    let yearBuilt: String
    let location: String

}

class PlacesData {
    static let shared = PlacesData()

    let places: [Place] = [
        Place(
            name: "Punto prova casa mia",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1551-1565",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Torre di Cetara",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1551-1565",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Castello di Arechi",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "VII-IX secolo, ampliamenti successivi",
            location: "Salerno",
        ),
        Place(
            name: "Giardino della Minerva",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XIII secolo",
            location: "Salerno",
        ),
        Place(
            name: "Porto di Salerno",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "Epoca romana, ampliamenti recenti nel XX secolo",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa di San Giorgio",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "Origini paleocristiane, ricostruita tra X e XVII secolo",
            location: "Salerno",
        ),
        Place(
            name: "Piazza della Libertà",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "2011-2021",
            location: "Salerno",
        ),
        Place(
            name: "Museo Diocesano San Matteo",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "Sede XVII secolo, collezioni dal XII secolo",
            location: "Salerno",
        ),
        Place(
            name: "Duomo di Salerno",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1076-1085",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa di Saragnano",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "Origini medievali, ristrutturazioni successive",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa del Monte dei Morti",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVII secolo",
            location: "Salerno",
        ),
        Place(
            name: "Teatro Municipale Giuseppe Verdi",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1863-1872",
            location: "Salerno",
        ),
        Place(
            name: "Acquedotto Medievale",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "IX secolo",
            location: "Salerno",
        ),
        Place(
            name: "Museo dello Sbarco e Salerno Capitale",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "2012",
            location: "Salerno",
        ),
        Place(
            name: "Museo virtuale della scuola medica salernitana",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "2009",
            location: "Salerno",
        ),
        Place(
            name: "Museo archeologico provinciale di Salerno",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1939 (sede nell’ex convento di San Benedetto)",
            location: "Salerno",
        ),
        Place(
            name: "Chiesa della Santissima Annunziata",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XIV secolo (restauri XVII-XVIII sec.)",
            location: "Salerno",
        ),
        Place(
            name: "Parrocchia di San Pietro Apostolo",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "IX-X secolo (aspetto attuale XVII-XVIII secolo)",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Chiesa di Santa Maria di Costantinopoli",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVII secolo",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Chiesa di San Francesco",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVII secolo",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Fabbrica Nettuno",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1950",
            location: "Cetara, Salerno",
        ),
        Place(
            name: "Monumento ai Caduti",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1925",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Duomo di Cava",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XI secolo (rifacimenti XVII-XVIII secolo)",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di San Rocco",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVI secolo",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Giardini di San Giovanni",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVII secolo (riqualificati in epoca recente)",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di Maria Assunta in Cielo (Purgatorio)",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVII secolo",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Santuario Francescano S.Francesco e S.Antonio",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVI secolo",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di Santa Maria Incoronata dell'Olmo",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "Medioevo (aspetto attuale XVII-XVIII secolo)",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Abbazia della Santissima Trinità",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XI secolo",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa dell'Avvocatella",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XVII secolo",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Chiesa di San Lorenzo",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "Medioevo (successivi rifacimenti)",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Villa Comunale Falcone e Borsellino",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "XX secolo",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Stadio Arechi",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1988-1990",
            location: "Salerno",
        ),
        Place(
            name: "Casa del Dom",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "2018",
            location: "Cava de' Tirreni, Salerno",
        ),
        Place(
            name: "Università degli Studi di Salerno",
            imageName: "poi_locked",
            history: "",
            yearBuilt: "1860",
            location: "Fisciano, Salerno",
        ),
    ]
}
