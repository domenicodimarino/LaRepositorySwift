import Foundation
import CoreLocation
import UIKit

struct POI: Identifiable, Hashable {
    let id: UUID
    let street: String
    let streetNumber: String
    let city: String
    let province: String

    // Stato di scoperta
    var isDiscovered: Bool
    var discoveredTitle: String?
    var photo: UIImage?

    // Coordinate (opzionali)
    var latitude: Double?
    var longitude: Double?

    // Titolo visualizzato
    var title: String {
        isDiscovered ? (discoveredTitle ?? "Punto di interesse") : "Punto di interesse"
    }

    var address: String {
        "\(street) \(streetNumber), \(city), \(province)"
    }

    // Coordinate come CLLocationCoordinate2D (utile per MapKit)
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }

    // Inizializzatore di default
    init(
        street: String,
        streetNumber: String,
        city: String,
        province: String,
        isDiscovered: Bool = false,
        discoveredTitle: String? = nil,
        photo: UIImage? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = UUID()
        self.street = street
        self.streetNumber = streetNumber
        self.city = city
        self.province = province
        self.isDiscovered = isDiscovered
        self.discoveredTitle = discoveredTitle
        self.photo = photo
        self.latitude = latitude
        self.longitude = longitude
    }
}
