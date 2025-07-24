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

    let diaryPlaceName: String

    var isDiscovered: Bool
    var discoveredTitle: String?
    var photoPath: String?
    var discoveredDate: Date?
    let imageName: String

    // --- Nuovi campi dinamici ---
    var yearBuilt: String?     // Anno costruzione (opzionale)
    var history: String?       // Storia generata (opzionale)

    var photo: UIImage? {
            guard let fileName = photoPath else { return nil }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("POIPhotos/\(fileName)")
            return UIImage(contentsOfFile: fileURL.path)
        }
    
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
