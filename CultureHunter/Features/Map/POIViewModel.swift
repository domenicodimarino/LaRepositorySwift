import Foundation
import UIKit

class POIViewModel: ObservableObject {
    @Published var mappedPOIs: [MappedPOI] = []

    func geocodeAll(pois: [POI]) {
        POIGeocoder.geocode(pois: pois) { mapped in
            DispatchQueue.main.async {
                self.mappedPOIs = mapped
            }
        }
    }

    func markPOIDiscovered(id: UUID, photo: UIImage, city: String, badgeManager: BadgeManager, nomeUtente: String) {
        let nuovoTitolo = "Monumento di \(nomeUtente)"
        if let index = mappedPOIs.firstIndex(where: { $0.id == id }) {
            let oldPOI = mappedPOIs[index]
            let updatedPOI = MappedPOI(
                id: oldPOI.id,
                title: nuovoTitolo,
                address: oldPOI.address,
                coordinate: oldPOI.coordinate,
                city: oldPOI.city,
                province: oldPOI.province,
                isDiscovered: true,
                discoveredTitle: nuovoTitolo,
                photo: photo
            )
            mappedPOIs[index] = updatedPOI
            mappedPOIs = Array(mappedPOIs) // Forza il refresh SwiftUI
            badgeManager.updateBadgeForDiscoveredPOI(city: city, poiID: oldPOI.id)
            print("POI aggiornato con foto:", updatedPOI.photo as Any)
        }
    }
}
