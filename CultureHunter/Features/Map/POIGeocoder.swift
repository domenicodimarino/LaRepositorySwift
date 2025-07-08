import Foundation
import CoreLocation
import UIKit

class POIGeocoder {
    static func geocode(poi: POI, completion: @escaping (MappedPOI?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(poi.address) { placemarks, _ in
            if let location = placemarks?.first?.location {
                let mapped = MappedPOI(
                    id: poi.id,
                    title: poi.title,
                    address: poi.address,
                    coordinate: location.coordinate,
                    city: poi.city,          // <-- aggiungi questi due
                    province: poi.province,  // <-- aggiungi questi due
                    isDiscovered: poi.isDiscovered,
                    discoveredTitle: poi.discoveredTitle,
                    photo: poi.photo
                )
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
