//
//  POIGeocoder.swift
//  CultureHunter
//
//  Created by Giovanni Adinolfi   on 04/07/25.
//
import Foundation
import CoreLocation

class POIGeocoder {
    static func geocode(poi: POI, completion: @escaping (MappedPOI?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(poi.address) { placemarks, _ in
            if let location = placemarks?.first?.location {
                let mapped = MappedPOI(title: poi.title, coordinate: location.coordinate)
                completion(mapped)
            } else {
                completion(nil)
            }
        }
    }
    
    static func geocode(pois: [POI], completion: @escaping ([MappedPOI]) -> Void) {
        var results: [MappedPOI] = []
        let group = DispatchGroup()
        for poi in pois {
            group.enter()
            geocode(poi: poi) { mapped in
                if let mapped = mapped {
                    results.append(mapped)
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(results)
        }
    }
}
