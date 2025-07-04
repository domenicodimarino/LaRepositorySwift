import Foundation
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

    // Titolo visualizzato
    var title: String {
        isDiscovered ? (discoveredTitle ?? "Punto di interesse") : "Punto di interesse"
    }

    var address: String {
        "\(street) \(streetNumber), \(city), \(province)"
    }

    // Inizializzatore di default
    init(
        street: String,
        streetNumber: String,
        city: String,
        province: String,
        isDiscovered: Bool = false,
        discoveredTitle: String? = nil,
        photo: UIImage? = nil
    ) {
        self.id = UUID()
        self.street = street
        self.streetNumber = streetNumber
        self.city = city
        self.province = province
        self.isDiscovered = isDiscovered
        self.discoveredTitle = discoveredTitle
        self.photo = photo
    }
}
