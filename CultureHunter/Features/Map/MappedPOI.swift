//
//  MappedPOI.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation
import CoreLocation

struct MappedPOI: Identifiable {
    let id: UUID            // copia l'id del POI originale!
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: MappedPOI, rhs: MappedPOI) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
