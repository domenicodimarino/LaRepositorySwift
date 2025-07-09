import Foundation
import CoreLocation
import UIKit

class POIGeocoder {
    static func geocode(poi: POI, completion: @escaping (MappedPOI?) -> Void) {
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
                    diaryPlaceName: poi.diaryPlaceName, // <-- campo di collegamento!
                    isDiscovered: poi.isDiscovered,
                    discoveredTitle: poi.discoveredTitle,
                    photoPath: poi.photoPath // <-- salva path, non UIImage
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
