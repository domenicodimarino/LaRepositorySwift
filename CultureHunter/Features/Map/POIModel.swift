import Foundation
import CoreLocation
import UIKit

struct POI: Identifiable, Hashable {
    let id: UUID
    let street: String
    let streetNumber: String
    let city: String
    let province: String

    let diaryPlaceName: String
    var photoPath: String?
    var isDiscovered: Bool
    var discoveredTitle: String?
    var photo: UIImage?
    var discoveredDate: Date?
    var latitude: Double?
    var longitude: Double?
    let imageName: String // <-- aggiunto campo imageName

    var title: String {
        isDiscovered ? (discoveredTitle ?? "Punto di interesse") : "Punto di interesse"
    }
    var address: String {
        "\(street) \(streetNumber), \(city), \(province)"
    }
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    init(
        street: String,
        streetNumber: String,
        city: String,
        province: String,
        diaryPlaceName: String,
        isDiscovered: Bool = false,
        discoveredTitle: String? = nil,
        photo: UIImage? = nil,
        photoPath: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        discoveredDate: Date? = nil,
        imageName: String // <-- aggiunto parametro
    ) {
        self.id = UUID()
        self.street = street
        self.streetNumber = streetNumber
        self.city = city
        self.province = province
        self.diaryPlaceName = diaryPlaceName
        self.photoPath = photoPath
        self.isDiscovered = isDiscovered
        self.discoveredTitle = discoveredTitle
        self.photo = photo
        self.latitude = latitude
        self.longitude = longitude
        self.discoveredDate = discoveredDate
        self.imageName = imageName // <-- assegnazione
    }
}
