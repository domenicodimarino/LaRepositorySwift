import Foundation
import CoreLocation
import UIKit

class POIGeocoder {
    static func geocode(poi: POI, completion: @escaping (MappedPOI?) -> Void) {
        // Se il POI ha già lat/lon, usale direttamente!
        if let lat = poi.latitude, let lon = poi.longitude {
            let mapped = MappedPOI(
                id: poi.id,
                title: poi.title,
                address: poi.address,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                city: poi.city,
                province: poi.province,
                diaryPlaceName: poi.diaryPlaceName,
                isDiscovered: poi.isDiscovered,
                discoveredTitle: poi.discoveredTitle,
                photoPath: poi.photoPath,
                discoveredDate: poi.discoveredDate,
                imageName: poi.imageName // <-- AGGIUNTO!
            )
            completion(mapped)
            return
        }
        // Se non ci sono coordinate, prova la geocodifica dell'indirizzo
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(poi.address, completionHandler: { placemarks, _ in
            if let location = placemarks?.first?.location {
                let mapped = MappedPOI(
                    id: poi.id,
                    title: poi.title,
                    address: poi.address,
                    coordinate: location.coordinate,
                    city: poi.city,
                    province: poi.province,
                    diaryPlaceName: poi.diaryPlaceName,
                    isDiscovered: poi.isDiscovered,
                    discoveredTitle: poi.discoveredTitle,
                    photoPath: poi.photoPath,
                    discoveredDate: poi.discoveredDate,
                    imageName: poi.imageName // <-- AGGIUNTO!
                )
                completion(mapped)
            } else {
                completion(nil)
            }
        })
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
