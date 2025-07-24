import Foundation
import UIKit
import CoreData
import CoreLocation

class POIViewModel: ObservableObject {
    @Published var mappedPOIs: [MappedPOI] = []
    let persistenceManager = POIPersistenceManager.shared
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchAllPOIs()
    }

    /// Carica tutti i POI scoperti da CoreData
    func fetchAllPOIs() {
        let entities = persistenceManager.getAllPOIs(context: context)
        self.mappedPOIs = entities.compactMap { $0.asMappedPOI() }
        for poi in mappedPOIs {
                print("POI: \(poi.diaryPlaceName) - yearBuilt: \(poi.yearBuilt)")
            }
        print("📍 Caricati \(mappedPOIs.count) POI da CoreData, di cui \(mappedPOIs.filter { $0.isDiscovered }.count) scoperti")
    }

    /// Aggiorna la storia di un POI nella lista (e su CoreData)
    func updateHistory(for id: UUID, history: String?) {
        if let index = mappedPOIs.firstIndex(where: { $0.id == id }) {
            mappedPOIs[index].history = history
            persistenceManager.savePOIHistory(id: id, history: history, context: context)
        }
    }

    /// Segna un POI come scoperto (salva su CoreData e aggiorna la lista)
    func markPOIDiscovered(id: UUID, photo: UIImage, city: String, badgeManager: BadgeManager, nomeUtente: String) {
        guard let index = mappedPOIs.firstIndex(where: { $0.id == id }) else {
            print("❌ POI non trovato con ID: \(id)")
            return
        }

        let oldPOI = mappedPOIs[index]

        let nuovoTitolo: String
        if let place = PlacesData.shared.places.first(where: { $0.name == oldPOI.diaryPlaceName }) {
            nuovoTitolo = place.name
        } else {
            nuovoTitolo = "Monumento di \(nomeUtente)"
        }

        let photoPath = persistenceManager.savePOIDiscovery(
            id: id,
            photo: photo,
            city: city,
            title: nuovoTitolo,
            history: oldPOI.history,
            context: context
        )

        if photoPath == nil {
            print("❌ Impossibile salvare l'immagine per il POI: \(id)")
        }

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
            imageName: oldPOI.imageName,
            yearBuilt: oldPOI.yearBuilt,
        )

        mappedPOIs[index] = updatedPOI

        // Se la storia è assente, chiama Groq (o la tua funzione di fetch online)
        if mappedPOIs[index].history == nil {
            fetchHistoryForPOI(poi: updatedPOI) { storia in
                DispatchQueue.main.async {
                    self.updateHistory(for: updatedPOI.id, history: storia)
                }
            }
        }

        mappedPOIs = Array(mappedPOIs)

        badgeManager.updateBadgeForDiscoveredPOI(city: city, poiID: oldPOI.id, imageName: oldPOI.imageName ?? "", mappedPOIs: mappedPOIs)

        print("✅ POI scoperto e salvato: \(nuovoTitolo)")
    }

    func getDiscoveredPOIs() -> [MappedPOI] {
        return mappedPOIs.filter { $0.isDiscovered }
    }

    /// Rimuove la scoperta di un POI (da CoreData e dalla lista)
    func removePOIDiscovery(id: UUID) {
        persistenceManager.removePOIDiscovery(id: id, context: context)

        if let index = mappedPOIs.firstIndex(where: { $0.id == id }) {
            mappedPOIs[index].isDiscovered = false
            mappedPOIs[index].photoPath = nil
            mappedPOIs[index].discoveredTitle = nil
            mappedPOIs[index].discoveredDate = nil

            mappedPOIs = Array(mappedPOIs)
            print("🔄 UI aggiornata dopo rimozione POI")
        }
    }
}
extension POIEntity {
    func asMappedPOI() -> MappedPOI? {
        guard let id = id,
              let title = title,
              let city = city,
              let province = province,
              let diaryPlaceName = diaryPlaceName,
              let imageName = imageName else { return nil }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MappedPOI(
            id: id,
            title: title,
            address: "\(city), \(province)",
            coordinate: coordinate,
            city: city,
            province: province,
            diaryPlaceName: diaryPlaceName,
            isDiscovered: isDiscovered,
            discoveredTitle: discoveredTitle,
            photoPath: photoPath,
            discoveredDate: discoveredDate,
            imageName: imageName,
            yearBuilt: yearBuilt,
            history: history
        )
    }
}
