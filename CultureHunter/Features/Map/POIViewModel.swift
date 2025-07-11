import Foundation
import UIKit

class POIViewModel: ObservableObject {
    @Published var mappedPOIs: [MappedPOI] = []

    // MARK: - Geocoding
    func geocodeAll(pois: [POI]) {
        POIGeocoder.geocode(pois: pois) { mapped in
            DispatchQueue.main.async {
                self.mappedPOIs = self.mergeWithDiscoveredPOIs(mapped)
            }
        }
    }

    // MARK: - Scoperta POI
    func markPOIDiscovered(id: UUID, photo: UIImage, city: String, badgeManager: BadgeManager, nomeUtente: String) {
        guard let index = mappedPOIs.firstIndex(where: { $0.id == id }) else { return }
        let oldPOI = mappedPOIs[index]

        let nuovoTitolo: String
        if let place = PlacesData.shared.places.first(where: { $0.name == oldPOI.diaryPlaceName }) {
            nuovoTitolo = place.name
        } else {
            nuovoTitolo = "Monumento di \(nomeUtente)"
        }

        guard let photoPath = saveImageToDisk(photo, for: id) else { return }

        let now = Date()
        let updatedPOI = MappedPOI(
            id: oldPOI.id,
            title: nuovoTitolo,
            address: oldPOI.address,
            coordinate: oldPOI.coordinate,
            city: oldPOI.city,
            province: oldPOI.province,
            diaryPlaceName: oldPOI.diaryPlaceName,
            isDiscovered: true,
            discoveredTitle: nuovoTitolo,
            photoPath: photoPath,
            discoveredDate: now,
            imageName: oldPOI.imageName // <-- AGGIUNTO!
        )
        mappedPOIs[index] = updatedPOI
        mappedPOIs = Array(mappedPOIs)
        badgeManager.updateBadgeForDiscoveredPOI(city: city, poiID: oldPOI.id)
        persistDiscoveredPOI(id: id, photoPath: photoPath, title: nuovoTitolo, discoveredDate: now)
    }

    // MARK: - Persistance

    private let discoveredKey = "DiscoveredPOIs"

    private struct DiscoveredPOIData: Codable {
        let id: UUID
        let photoPath: String
        let title: String
        let discoveredDate: Date?
    }

    private func persistDiscoveredPOI(id: UUID, photoPath: String, title: String, discoveredDate: Date?) {
        var saved = loadPersistedDiscoveredPOIs()
        if let idx = saved.firstIndex(where: { $0.id == id }) {
            saved[idx] = DiscoveredPOIData(id: id, photoPath: photoPath, title: title, discoveredDate: discoveredDate)
        } else {
            saved.append(DiscoveredPOIData(id: id, photoPath: photoPath, title: title, discoveredDate: discoveredDate))
        }
        if let data = try? JSONEncoder().encode(saved) {
            UserDefaults.standard.set(data, forKey: discoveredKey)
        }
    }

    private func loadPersistedDiscoveredPOIs() -> [DiscoveredPOIData] {
        guard let data = UserDefaults.standard.data(forKey: discoveredKey),
              let pois = try? JSONDecoder().decode([DiscoveredPOIData].self, from: data)
        else { return [] }
        return pois
    }

    private func mergeWithDiscoveredPOIs(_ original: [MappedPOI]) -> [MappedPOI] {
        let discovered = loadPersistedDiscoveredPOIs()
        return original.map { poi in
            if let found = discovered.first(where: { $0.id == poi.id }) {
                return MappedPOI(
                    id: poi.id,
                    title: found.title,
                    address: poi.address,
                    coordinate: poi.coordinate,
                    city: poi.city,
                    province: poi.province,
                    diaryPlaceName: poi.diaryPlaceName,
                    isDiscovered: true,
                    discoveredTitle: found.title,
                    photoPath: found.photoPath,
                    discoveredDate: found.discoveredDate,
                    imageName: poi.imageName // <-- AGGIUNTO!
                )
            } else {
                return poi
            }
        }
    }

    // MARK: - Save image to disk
    private func saveImageToDisk(_ image: UIImage, for id: UUID) -> String? {
        let filename = "poi_\(id.uuidString).jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: url)
            return url.path
        }
        return nil
    }
}
