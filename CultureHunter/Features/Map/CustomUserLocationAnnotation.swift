//
//  CustomUserLocationAnnotation.swift
//  CultureHunter
//
//  Created by Domenico Di Marino on 11/07/25.
//

import MapKit
import SpriteKit

// Annotazione personalizzata per la posizione utente
class CustomUserLocationAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
        self.coordinate = coordinate
        super.init()
    }
}
