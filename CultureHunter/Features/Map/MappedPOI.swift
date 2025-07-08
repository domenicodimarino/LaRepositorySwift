import Foundation
import CoreLocation
import UIKit

struct MappedPOI: Identifiable, Hashable {
    let id: UUID                    // copia l'id del POI originale!
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D

    // Campi aggiuntivi opzionali per compatibilità con POI
    let isDiscovered: Bool
    let discoveredTitle: String?
    let photo: UIImage?

    static func == (lhs: MappedPOI, rhs: MappedPOI) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
        // Nota: photo e discoveredTitle non vengono confrontati
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
        // Non includo photo e discoveredTitle perché UIImage non è Hashable
    }
}
