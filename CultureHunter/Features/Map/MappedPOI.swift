import Foundation
import CoreLocation
import UIKit

struct MappedPOI: Identifiable, Hashable {
    let id: UUID
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D

    // Nuovi campi
    let city: String
    let province: String

    // Nuovi campi per interazione/foto
    let isDiscovered: Bool
    let discoveredTitle: String?
    let photo: UIImage?

    static func == (lhs: MappedPOI, rhs: MappedPOI) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
        // photo e discoveredTitle ignorati per uguaglianza
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
