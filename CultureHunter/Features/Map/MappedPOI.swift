import Foundation
import CoreLocation
import UIKit

struct MappedPOI: Identifiable, Hashable {
    let id: UUID
    let title: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let city: String
    let province: String

    // Collegamento al Diario
    let diaryPlaceName: String

    // Nuovi campi per interazione/foto
    let isDiscovered: Bool
    let discoveredTitle: String?
    let photoPath: String? // Persisti il path, non la UIImage
    let discoveredDate: Date? // <--- AGGIUNTO CAMPO DATA SCOPERTA
    let imageName: String // <-- nome asset

    var photo: UIImage? {
        guard let photoPath else { return nil }
        return UIImage(contentsOfFile: photoPath)
    }
    
    static func == (lhs: MappedPOI, rhs: MappedPOI) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
        // photo, discoveredTitle e discoveredDate ignorati per uguaglianza
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
