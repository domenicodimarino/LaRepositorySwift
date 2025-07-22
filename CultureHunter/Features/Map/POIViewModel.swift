import Foundation
import UIKit

class POIViewModel: ObservableObject {
    @Published var mappedPOIs: [MappedPOI] = []
    private let persistenceManager = POIPersistenceManager.shared
    
    
    init() {
        print("🔐 Verifica UserDefaults all'avvio:")
        print("   - Chiave usata: \(persistenceManager.discoveredPOIsKey)")
        
        print("   - Chiavi disponibili:")
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            print("      * \(key)")
        }
        
        persistenceManager.migrateExistingData()
    }
    
    func geocodeAll(pois: [POI]) {
        POIGeocoder.geocode(pois: pois) { mapped in
            DispatchQueue.main.async {
                var mutableMapped = mapped
                self.persistenceManager.applyPersistedDataTo(mappedPOIs: &mutableMapped)
                self.mappedPOIs = mutableMapped
                
                print("📍 Caricati \(self.mappedPOIs.count) POI, di cui \(self.mappedPOIs.filter { $0.isDiscovered }.count) scoperti")
            }
        }
    }
    
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
            title: nuovoTitolo
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
            imageName: oldPOI.imageName
        )
        
        mappedPOIs[index] = updatedPOI
        
        mappedPOIs = Array(mappedPOIs)
        
        badgeManager.updateBadgeForDiscoveredPOI(city: city, poiID: oldPOI.id, imageName: oldPOI.imageName ?? "")
        
        print("✅ POI scoperto e salvato: \(nuovoTitolo)")
    }
    
    func getDiscoveredPOIs() -> [MappedPOI] {
        return mappedPOIs.filter { $0.isDiscovered }
    }
    
    func removePOIDiscovery(id: UUID) {
        persistenceManager.removePOIDiscovery(id: id)
        
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
