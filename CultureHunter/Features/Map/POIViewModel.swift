import Foundation
import UIKit

class POIViewModel: ObservableObject {
    @Published var mappedPOIs: [MappedPOI] = []
    private let persistenceManager = POIPersistenceManager.shared
    
    // MARK: - Inizializzazione
    
    init() {
        // Debug per verificare lo stato di UserDefaults
        print("🔐 Verifica UserDefaults all'avvio:")
        print("   - Chiave usata: \(persistenceManager.discoveredPOIsKey)")
        
        // Stampa tutte le chiavi in UserDefaults
        print("   - Chiavi disponibili:")
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            print("      * \(key)")
        }
        
        // Migra i dati esistenti
        persistenceManager.migrateExistingData()
    }
    
    // MARK: - Geocoding
    func geocodeAll(pois: [POI]) {
        POIGeocoder.geocode(pois: pois) { mapped in
            DispatchQueue.main.async {
                // Ora usiamo il persistence manager per applicare i dati salvati
                var mutableMapped = mapped
                self.persistenceManager.applyPersistedDataTo(mappedPOIs: &mutableMapped)
                self.mappedPOIs = mutableMapped
                
                print("📍 Caricati \(self.mappedPOIs.count) POI, di cui \(self.mappedPOIs.filter { $0.isDiscovered }.count) scoperti")
            }
        }
    }

    // MARK: - Scoperta POI
    func markPOIDiscovered(id: UUID, photo: UIImage, city: String, badgeManager: BadgeManager, nomeUtente: String) {
        guard let index = mappedPOIs.firstIndex(where: { $0.id == id }) else {
            print("❌ POI non trovato con ID: \(id)")
            return
        }
        
        let oldPOI = mappedPOIs[index]

        // Determina il titolo basato sul database Place
        let nuovoTitolo: String
        if let place = PlacesData.shared.places.first(where: { $0.name == oldPOI.diaryPlaceName }) {
            nuovoTitolo = place.name
        } else {
            nuovoTitolo = "Monumento di \(nomeUtente)"
        }

        // Usa il persistence manager per salvare i dati
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
        
        // Crea il POI aggiornato
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
        
        // Aggiorna la lista in memoria
        mappedPOIs[index] = updatedPOI
        
        // Forza l'aggiornamento della UI
        mappedPOIs = Array(mappedPOIs)
        
        // Aggiorna badge - RISOLUZIONE ERRORE QUI!
        badgeManager.updateBadgeForDiscoveredPOI(city: city, poiID: oldPOI.id, imageName: oldPOI.imageName ?? "")
        
        print("✅ POI scoperto e salvato: \(nuovoTitolo)")
    }
    
    // MARK: - Metodi di accesso ai dati
    
    // Ottieni tutti i POI scoperti
    func getDiscoveredPOIs() -> [MappedPOI] {
        return mappedPOIs.filter { $0.isDiscovered }
    }
    
    // Elimina un POI scoperto
    func removePOIDiscovery(id: UUID) {
        // Rimuovi i dati salvati nel persistence manager
        persistenceManager.removePOIDiscovery(id: id)
        
        // Aggiorna l'array in memoria
        if let index = mappedPOIs.firstIndex(where: { $0.id == id }) {
            mappedPOIs[index].isDiscovered = false
            mappedPOIs[index].photoPath = nil
            mappedPOIs[index].discoveredTitle = nil
            mappedPOIs[index].discoveredDate = nil
            
            // Forza l'aggiornamento della UI
            mappedPOIs = Array(mappedPOIs)
            print("🔄 UI aggiornata dopo rimozione POI")
        }
    }
}
